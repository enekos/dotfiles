#!/usr/bin/env node
// diff-preview — render the current repo's diff as a self-contained HTML page
// and open it in the browser, using diff2html for the dark-themed layout.

import { spawnSync, spawn } from 'node:child_process'
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs'
import { tmpdir, hostname } from 'node:os'
import { join } from 'node:path'
import { createRequire } from 'node:module'
import { createServer } from 'node:http'
import { randomBytes, createHash } from 'node:crypto'

import { html as diff2htmlHtml } from 'diff2html'

const require_ = createRequire(import.meta.url)
const D2H_CSS = readFileSync(require_.resolve('diff2html/bundles/css/diff2html.min.css'), 'utf8')

// ────────────────────────── arg parsing ──────────────────────────

const args = process.argv.slice(2)
const opts = {
  base: undefined,
  target: 'auto', // auto | working | staged | head
  out: undefined,
  serve: false,
  port: 0,
  open: true,
  silent: false,
  auto: false,
  noFilter: false,
  help: false
}

while (args.length) {
  const a = args.shift()
  if (a === '--base' || a === '-b') opts.base = args.shift()
  else if (a === '--working') opts.target = 'working'
  else if (a === '--staged') opts.target = 'staged'
  else if (a === '--head') opts.target = 'head' // last commit + working tree
  else if (a === '--out' || a === '-o') opts.out = args.shift()
  else if (a === '--serve') opts.serve = true
  else if (a === '--port' || a === '-p') opts.port = Number(args.shift()) || 0
  else if (a === '--no-open') opts.open = false
  else if (a === '--silent' || a === '-q') opts.silent = true
  else if (a === '--auto') opts.auto = true
  else if (a === '--no-filter') opts.noFilter = true
  else if (a === '-h' || a === '--help') opts.help = true
  else {
    log(`unknown arg: ${a}`, 'err')
    process.exit(2)
  }
}

if (opts.help) {
  process.stdout.write(`diff-preview — render git diff as HTML and open in browser

usage:
  diff-preview                    diff base..HEAD plus working tree, open in browser
  diff-preview --working          only uncommitted (working tree vs HEAD)
  diff-preview --staged           only staged changes
  diff-preview --head             HEAD~1..HEAD + working tree
  diff-preview --base <ref>       override base branch (default: auto-detect)
  diff-preview --out <path>       write HTML to <path> instead of /tmp; don't open
  diff-preview --serve [-p N]     start localhost HTTP server (random or given port)
  diff-preview --no-open          don't auto-open in browser
  diff-preview --auto             skip silently if not in a git repo or no changes
  diff-preview --no-filter        don't drop lockfiles / generated files
  diff-preview -q                 silent mode
`)
  process.exit(0)
}

function log(msg, level = 'info') {
  if (opts.silent) return
  const stream = level === 'err' ? process.stderr : process.stdout
  stream.write(`diff-preview: ${msg}\n`)
}

// ────────────────────────── git helpers ──────────────────────────

function git(cwd, gitArgs, opts = {}) {
  const r = spawnSync('git', gitArgs, { cwd, encoding: 'utf8', maxBuffer: 128 * 1024 * 1024, ...opts })
  if (r.status !== 0) {
    const e = new Error(`git ${gitArgs.join(' ')} failed: ${r.stderr?.trim() || `exit ${r.status}`}`)
    e.code = r.status
    throw e
  }
  return r.stdout
}

function gitMaybe(cwd, gitArgs) {
  const r = spawnSync('git', gitArgs, { cwd, encoding: 'utf8', maxBuffer: 128 * 1024 * 1024 })
  return r.status === 0 ? r.stdout : undefined
}

function repoRoot(cwd) {
  const r = gitMaybe(cwd, ['rev-parse', '--show-toplevel'])
  return r?.trim()
}

function detectBase(cwd) {
  const head = gitMaybe(cwd, ['rev-parse', '--abbrev-ref', 'HEAD'])?.trim()
  const candidates = []
  if (head === 'master') candidates.push('origin/main', 'main')
  else if (head === 'main') candidates.push('origin/master', 'master')
  else candidates.push('origin/master', 'master', 'origin/main', 'main')
  for (const c of candidates) {
    if (gitMaybe(cwd, ['rev-parse', '--verify', c])) return c
  }
  return head // fallback: nothing to diff against; will produce empty patch
}

function computePatch(cwd) {
  const target = opts.target
  if (target === 'staged') return git(cwd, ['diff', '--cached'])
  if (target === 'working') return git(cwd, ['diff', 'HEAD'])
  const base = opts.base ?? detectBase(cwd)
  if (target === 'head') {
    return git(cwd, ['diff', 'HEAD~1', '--']) + git(cwd, ['diff', 'HEAD'])
  }
  // auto: merge-base(base, HEAD)..HEAD + uncommitted working tree changes
  const mergeBase = gitMaybe(cwd, ['merge-base', base, 'HEAD'])?.trim() || base
  const committed = git(cwd, ['diff', `${mergeBase}...HEAD`])
  const working = git(cwd, ['diff', 'HEAD'])
  return committed + (working ? '\n' + working : '')
}

function repoMeta(cwd) {
  const head = gitMaybe(cwd, ['rev-parse', '--abbrev-ref', 'HEAD'])?.trim() || 'HEAD'
  const remote = gitMaybe(cwd, ['remote', 'get-url', 'origin'])?.trim() || ''
  let repo = ''
  const ssh = remote.match(/^git@[^:]+:([^/]+)\/([^/]+?)(?:\.git)?\s*$/)
  if (ssh) repo = `${ssh[1]}/${ssh[2]}`
  else {
    const https = remote.match(/[/:]([^/]+)\/([^/]+?)(?:\.git)?\s*$/)
    if (https) repo = `${https[1]}/${https[2]}`
  }
  return { repo: repo || cwd, agentBranch: head }
}

// ────────────────────────── patch parsing + filter ──────────────────────────

const DEFAULT_IGNORED_PATTERNS = [
  'Cargo.lock',
  'package-lock.json',
  'yarn.lock',
  'pnpm-lock.yaml',
  'poetry.lock',
  'go.sum',
  'Pipfile.lock',
  'composer.lock',
  'Gemfile.lock',
  'uv.lock',
  '.pb.go',
  '.pb.h',
  '.pb.cc',
  '_pb2.py',
  '_pb2_grpc.py',
  '.generated.go',
  '.gen.go',
  '.generated.ts',
  '.gen.ts',
  '.g.dart',
  'generated.dart',
  'node_modules/',
  'vendor/',
  'target/',
  'build/',
  'dist/',
  'out/',
  '.next/',
  '.nuxt/',
  '__pycache__/',
  '.min.js',
  '.min.css',
  '__snapshots__/',
  '.snap'
]

function stripGitPrefix(s) {
  const t = s.startsWith('a/') ? s.slice(2) : s.startsWith('b/') ? s.slice(2) : s
  return t.replace(/[\t ]+$/, '')
}

function parseOneFile(slice) {
  let path, oldPath
  let isNew = false, isDeleted = false, isPureRename = false
  let additions = 0, deletions = 0
  let sawHunk = false, sawCombined = false
  for (const line of slice.split('\n')) {
    if (sawHunk) {
      if (line.startsWith('+') && !line.startsWith('+++')) additions++
      else if (line.startsWith('-') && !line.startsWith('---')) deletions++
      continue
    }
    if (line.startsWith('diff --cc ') || line.startsWith('diff --combined ')) { sawCombined = true; break }
    if (line.startsWith('--- ')) {
      const p = line.slice(4)
      if (p !== '/dev/null') oldPath = stripGitPrefix(p)
    } else if (line.startsWith('+++ ')) {
      const p = line.slice(4)
      if (p === '/dev/null') isDeleted = true
      else path = stripGitPrefix(p)
    } else if (line.startsWith('new file mode ')) isNew = true
    else if (line.startsWith('deleted file mode ')) isDeleted = true
    else if (line.startsWith('rename from ') || line.startsWith('rename to ')) isPureRename = true
    else if (line.startsWith('@@')) sawHunk = true
  }
  if (sawCombined) return undefined
  if (sawHunk) isPureRename = false
  const first = slice.split('\n', 1)[0] || ''
  const sep = first.indexOf(' b/')
  const headerB = sep !== -1 ? first.slice(sep + 3) : undefined
  const resolvedPath = path ?? oldPath ?? headerB
  if (!resolvedPath) return undefined
  return { path: resolvedPath, isNew, isDeleted, isPureRename, additions, deletions, body: `diff --git ${slice}` }
}

function parseUnifiedDiff(text) {
  const normalised = /\r\n/.test(text.slice(0, 4096)) ? text.replace(/\r\n/g, '\n') : text
  const pieces = []
  const splits = normalised.split('\ndiff --git ')
  const first = splits[0]
  if (first?.startsWith('diff --git ')) pieces.push(first.slice('diff --git '.length))
  else if (first && first.includes('diff --git ')) {
    for (const p of first.split('diff --git ')) if (p.trim()) pieces.push(p)
  }
  for (const p of splits.slice(1)) if (p.trim()) pieces.push(p)
  const out = []
  for (const slice of pieces) {
    const parsed = parseOneFile(slice)
    if (parsed) out.push(parsed)
  }
  return out
}

function isIgnored(path, patterns) {
  const lastSlash = path.lastIndexOf('/')
  const basename = lastSlash === -1 ? path : path.slice(lastSlash + 1)
  for (const pat of patterns) {
    if (pat.endsWith('/')) {
      const dir = pat.slice(0, -1)
      if (path === dir || path.startsWith(dir + '/') || path.includes(`/${dir}/`)) return true
    } else if (pat.startsWith('.')) {
      if (basename.endsWith(pat)) return true
    } else if (basename === pat || path.includes(pat)) return true
  }
  return false
}

// ────────────────────────── render ──────────────────────────

function escapeHtml(s) {
  return s.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c])
}

function renderHtml({ title, repo, baseBranch, agentBranch, files, dropped, stats, generatedAt }) {
  const patch = files.map(f => f.body).join('\n')
  const droppedList = dropped.length
    ? `<details class="dropped"><summary>${dropped.length} file(s) hidden (lockfiles / generated / vendored)</summary><ul>${dropped.map(p => `<li>${escapeHtml(p)}</li>`).join('')}</ul></details>`
    : ''
  const diffBody = files.length
    ? diff2htmlHtml(patch, { outputFormat: 'line-by-line', drawFileList: true, matching: 'lines', colorScheme: 'auto' })
    : '<div class="empty">No reviewable changes after filtering. The diff may be entirely generated / vendored content.</div>'
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(title)} · diff-preview</title>
<style>${D2H_CSS}</style>
<style>
  :root { --bg:#0d1117; --bg-elev:#161b22; --fg:#c9d1d9; --fg-mute:#8b949e; --border:#30363d; --add-fg:#56d364; --del-fg:#f85149; --link:#58a6ff; }
  @media (prefers-color-scheme: light) {
    :root { --bg:#ffffff; --bg-elev:#f6f8fa; --fg:#1f2328; --fg-mute:#59636e; --border:#d0d7de; --add-fg:#1a7f37; --del-fg:#cf222e; --link:#0969da; }
  }
  * { box-sizing: border-box; }
  html, body { margin:0; padding:0; background:var(--bg); color:var(--fg); font:13px/1.4 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif; }
  a { color:var(--link); text-decoration:none; } a:hover { text-decoration:underline; }
  main { padding:16px 24px 40px; max-width:1400px; margin:0 auto; }
  header.topbar { display:flex; justify-content:space-between; align-items:baseline; gap:16px; padding:16px 0; border-bottom:1px solid var(--border); margin-bottom:16px; flex-wrap:wrap; }
  header.topbar h1 { margin:0; font-size:20px; word-break:break-word; }
  header.topbar .sub { color:var(--fg-mute); font-size:13px; margin-top:4px; }
  header.topbar .sub code { font-family:ui-monospace,SFMono-Regular,Menlo,monospace; background:var(--bg-elev); padding:1px 5px; border-radius:3px; }
  .stats { font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:13px; white-space:nowrap; }
  .stats .plus { color:var(--add-fg); } .stats .minus { color:var(--del-fg); }
  .generated { color:var(--fg-mute); font-size:11px; }
  details.dropped { margin:16px 0; color:var(--fg-mute); font-size:12px; padding:8px 12px; background:var(--bg-elev); border:1px solid var(--border); border-radius:6px; }
  details.dropped ul { font-family:ui-monospace,SFMono-Regular,Menlo,monospace; padding-left:20px; margin:8px 0 0; }
  .empty { padding:40px; text-align:center; color:var(--fg-mute); border:1px dashed var(--border); border-radius:6px; }
</style>
</head>
<body>
<main>
  <header class="topbar">
    <div>
      <h1>${escapeHtml(title)}</h1>
      <div class="sub"><code>${escapeHtml(repo)}</code> · <code>${escapeHtml(agentBranch)}</code> → <code>${escapeHtml(baseBranch)}</code></div>
      <div class="generated">generated ${escapeHtml(generatedAt)}</div>
    </div>
    <div class="stats">${stats.files} file(s) · <span class="plus">+${stats.additions}</span> <span class="minus">-${stats.deletions}</span></div>
  </header>
  ${droppedList}
  ${diffBody}
</main>
</body>
</html>`
}

// ────────────────────────── output ──────────────────────────

function openInBrowser(target) {
  const cmd = process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'cmd' : 'xdg-open'
  const argv = process.platform === 'win32' ? ['/c', 'start', '', target] : [target]
  spawn(cmd, argv, { detached: true, stdio: 'ignore' }).unref()
}

function serveOnce(html, port) {
  const token = randomBytes(12).toString('hex')
  const expectedPath = `/preview/${token}`
  return new Promise((resolve, reject) => {
    const server = createServer((req, res) => {
      const path = req.url?.split('?')[0]
      if (req.method !== 'GET' || path !== expectedPath) {
        res.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' })
        res.end('not found\n')
        return
      }
      res.writeHead(200, {
        'content-type': 'text/html; charset=utf-8',
        'cache-control': 'no-store',
        'content-security-policy': "default-src 'none'; style-src 'unsafe-inline'; img-src data:;"
      })
      res.end(html)
    })
    server.once('error', reject)
    server.listen(port, '127.0.0.1', () => {
      const addr = server.address()
      const url = `http://127.0.0.1:${addr.port}/preview/${token}`
      resolve({ server, url })
    })
  })
}

// ────────────────────────── main ──────────────────────────

async function main() {
  const cwd = process.cwd()
  const root = repoRoot(cwd)
  if (!root) {
    if (opts.auto) process.exit(0)
    log('not a git repository', 'err')
    process.exit(1)
  }

  let patch
  try {
    patch = computePatch(root)
  } catch (e) {
    if (opts.auto) process.exit(0)
    log(e.message, 'err')
    process.exit(1)
  }

  if (!patch || !patch.trim()) {
    if (opts.auto) process.exit(0)
    log('no diff — nothing to preview')
    process.exit(0)
  }

  const parsed = parseUnifiedDiff(patch)
  const kept = []
  const dropped = []
  if (opts.noFilter) {
    kept.push(...parsed)
  } else {
    for (const f of parsed) {
      if (isIgnored(f.path, DEFAULT_IGNORED_PATTERNS)) dropped.push(f.path)
      else kept.push(f)
    }
  }
  const stats = kept.reduce(
    (acc, f) => ({ files: acc.files + 1, additions: acc.additions + f.additions, deletions: acc.deletions + f.deletions }),
    { files: 0, additions: 0, deletions: 0 }
  )

  const meta = repoMeta(root)
  const baseLabel =
    opts.target === 'working' ? 'HEAD'
    : opts.target === 'staged' ? 'index'
    : opts.target === 'head' ? 'HEAD~1'
    : (opts.base ?? detectBase(root))
  const subject = (gitMaybe(root, ['log', '-1', '--pretty=%s'])?.trim()) || meta.agentBranch
  const html = renderHtml({
    title: subject,
    repo: meta.repo,
    baseBranch: baseLabel,
    agentBranch: opts.target === 'working' ? 'working tree' : opts.target === 'staged' ? 'staged' : meta.agentBranch,
    files: kept,
    dropped,
    stats,
    generatedAt: new Date().toISOString()
  })

  if (opts.serve) {
    const { server, url } = await serveOnce(html, opts.port)
    log(`serving ${url}`)
    if (opts.open) openInBrowser(url)
    process.on('SIGINT', () => { server.close(() => process.exit(0)) })
    return
  }

  let outPath = opts.out
  if (!outPath) {
    const slug = createHash('sha1').update(root).digest('hex').slice(0, 8)
    const dir = join(tmpdir(), 'diff-preview')
    mkdirSync(dir, { recursive: true })
    outPath = join(dir, `${slug}.html`)
  }
  writeFileSync(outPath, html)
  log(`${kept.length} file(s) · +${stats.additions} -${stats.deletions}${dropped.length ? ` · ${dropped.length} hidden` : ''} → ${outPath}`)
  if (opts.open) openInBrowser(outPath)
}

main().catch(err => {
  log(err.message, 'err')
  process.exit(1)
})

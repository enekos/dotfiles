// opencode adapter for agentline: feeds the session to it as Claude Code's
// statusLine JSON every second and draws the two rows under the prompt.
import { Plugin } from "@opencode/plugin/tui"
import { createSignal, For } from "solid-js"
import { spawn } from "node:child_process"

const COMMAND = process.env.AGENTLINE_BIN ?? `${process.env.HOME}/.local/bin/agentline`
const REFRESH_MS = 1000
const BUDGET_MS = 900

type Segment = { text: string; fg?: string; dim?: boolean }

const BASIC = [
  "#000000", "#cd3131", "#0dbc79", "#e5e510", "#2472c8", "#bc3fbc", "#11a8cd", "#e5e5e5",
  "#666666", "#f14c4c", "#23d18b", "#f5f543", "#3b8eea", "#d670d6", "#29b8db", "#ffffff",
]
const hex = (r: number, g: number, b: number) =>
  "#" + [r, g, b].map((v) => v.toString(16).padStart(2, "0")).join("")

// agentline only emits reset, dim, and 24-bit / basic foregrounds
function parseAnsi(line: string): Segment[] {
  const out: Segment[] = []
  let style: Omit<Segment, "text"> = {}
  let last = 0
  const re = /\x1b\[([0-9;]*)m/g
  for (let m; (m = re.exec(line)); ) {
    if (m.index > last) out.push({ text: line.slice(last, m.index), ...style })
    last = re.lastIndex
    const p = m[1] === "" ? [0] : m[1].split(";").map(Number)
    for (let i = 0; i < p.length; i++) {
      const c = p[i]
      if (c === 0) style = {}
      else if (c === 2) style = { ...style, dim: true }
      else if (c === 22) style = { ...style, dim: false }
      else if (c >= 30 && c <= 37) style = { ...style, fg: BASIC[c - 30] }
      else if (c >= 90 && c <= 97) style = { ...style, fg: BASIC[c - 82] }
      else if (c === 39) style = { ...style, fg: undefined }
      else if (c === 38 && p[i + 1] === 2) {
        style = { ...style, fg: hex(p[i + 2], p[i + 3], p[i + 4]) }
        i += 4
      }
    }
  }
  if (last < line.length) out.push({ text: line.slice(last), ...style })
  return out
}

export default Plugin.define({
  id: "eneko.agentline",
  setup(ctx) {
    const [rows, setRows] = createSignal<Segment[][]>([])
    let running = false

    const payload = () => {
      const route: any = ctx.ui.router.current()
      const id: string | undefined = route?.type === "session" ? route.sessionID : undefined
      const location = ctx.location ?? ctx.data.location.default()
      const model: any = ctx.ui.model.current()
      let used_percentage: number | undefined
      if (id) {
        const messages: any[] = ctx.data.session.message.list(id) ?? []
        const cut = messages.findLastIndex((m) => m.type === "compaction" && m.status === "completed")
        const reply = messages.findLast((m, i) => m.type === "assistant" && m.tokens && i > cut)
        if (reply) {
          const t = reply.tokens
          const used = t.input + t.output + t.reasoning + t.cache.read + t.cache.write
          const limit = (ctx.data.location.model.list(location) ?? []).find(
            (x: any) => x.providerID === reply.model.providerID && x.id === reply.model.id,
          )?.limit.context
          if (limit) used_percentage = (used / limit) * 100
        }
      }
      return {
        session_id: id ?? `opencode-${process.pid}`,
        model: { id: model?.modelID, display_name: model?.modelID },
        effort: model?.variant ? { level: model.variant } : undefined,
        workspace: { current_dir: location?.directory },
        context_window: { used_percentage },
      }
    }

    const tick = () => {
      if (running) return
      running = true
      const child = spawn(COMMAND, [], {
        env: { ...process.env, AGENTLINE_PID: String(process.pid) },
        stdio: ["pipe", "pipe", "ignore"],
      })
      let out = ""
      child.stdout.on("data", (d) => (out += d))
      const timeout = setTimeout(() => child.kill(), BUDGET_MS)
      child.on("error", () => {
        clearTimeout(timeout)
        running = false
      })
      child.on("close", (code) => {
        clearTimeout(timeout)
        running = false
        if (code === 0) setRows(out.split("\n").filter(Boolean).slice(0, 2).map(parseAnsi))
      })
      child.stdin.on("error", () => {})
      child.stdin.end(JSON.stringify(payload()))
    }

    tick()
    const timer = setInterval(tick, REFRESH_MS)
    const dispose = ctx.ui.slot({
      after: "prompt.footer",
      render: () => (
        <box flexDirection="column" flexShrink={0} paddingLeft={1}>
          <For each={rows()}>
            {(row) => (
              <text>
                <For each={row}>
                  {(s) => (
                    <span style={{ fg: s.fg ?? (s.dim ? ctx.theme.text.muted : ctx.theme.text.base) }}>{s.text}</span>
                  )}
                </For>
              </text>
            )}
          </For>
        </box>
      ),
    })
    return () => {
      clearInterval(timer)
      dispose()
    }
  },
})

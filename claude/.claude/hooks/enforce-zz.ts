#!/usr/bin/env bun

/**
 * PreToolUse guard: block `cd <dir> && <command>` chains; require the `zz` jumper.
 *
 * Eneko's system uses `zz` (zoxide wrapper at ~/.local/bin/zz) for directory
 * navigation. The `cd <dir> && <command>` anti-pattern is disallowed system-wide
 * (see thinking-os/CLAUDE.md). This hook enforces it deterministically instead of
 * relying on the prompt, which was being ignored.
 *
 * Contract: reads the PreToolUse JSON on stdin. If the Bash command matches the
 * anti-pattern, emits a `permissionDecision: deny` and exits 0. The deny reason
 * carries the EXACT `zz` rewrite so the model's retry is one-shot and lands on
 * `zz` (not a `git -C`/`--manifest-path` workaround). Otherwise emits nothing.
 * ALWAYS exits 0 — a parse/read failure fails OPEN (command allowed), so a
 * broken guard can never wedge every Bash call.
 */

import { readFileSync } from "node:fs";
import { basename } from "node:path";

type PreToolUseInput = {
  tool_name?: string;
  tool_input?: { command?: string };
};

const PATTERN = /(?:^|[;|&(])\s*(?:cd|pushd)\s+\S+\s*&&/i;

const REWRITE = /^\s*(?:cd|pushd)\s+("[^"]+"|'[^']+'|\S+)\s*&&\s*([\s\S]+)$/i;

const COMPOUND_TAIL = /&&|\|\||[;|]/;

const unquote = (value: string): string => value.trim().replace(/^["']|["']$/g, "");

const suggest = (command: string): string | null => {
  const match = REWRITE.exec(command.trim());
  if (!match) return null;

  const dir = unquote(match[1]!);
  const rest = match[2]!.trim();
  if (!dir || !rest) return null;

  const query = basename(dir.replace(/\/+$/, "")) || dir;

  if (COMPOUND_TAIL.test(rest)) {
    return `zz ${query} bash -c '${rest.replaceAll("'", "'\\''")}'`;
  }
  return `zz ${query} ${rest}`;
};

const buildReason = (command: string): string => {
  const fix = suggest(command);
  const lines = [
    "Blocked: `cd <dir> && <command>` is disallowed on this system. Use the `zz` jumper.",
  ];
  if (fix) {
    lines.push(`Run this instead:\n  ${fix}`);
    lines.push(
      "(query is a zoxide match, not a path — shorten it if it's ambiguous; " +
        "use `zz -p <query>` to just resolve a path.)",
    );
  } else {
    lines.push(
      "Rewrite as `zz <query> <command>` " +
        "(or `zz <query>@<branch> <command>` for a worktree, " +
        "`zz -p <query>` to resolve a path).",
    );
  }
  return lines.join("\n");
};

const main = (): void => {
  let data: PreToolUseInput;
  try {
    data = JSON.parse(readFileSync(0, "utf8")) as PreToolUseInput;
  } catch {
    return;
  }

  if (data?.tool_name !== "Bash") return;

  const command = data.tool_input?.command ?? "";
  if (!PATTERN.test(command)) return;

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: buildReason(command),
      },
      systemMessage: "zz-enforce: use `zz <query> <command>` instead of `cd ... &&`.",
    }),
  );
};

main();
process.exit(0);

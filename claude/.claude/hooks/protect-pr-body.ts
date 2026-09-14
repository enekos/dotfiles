#!/usr/bin/env bun

import { readFileSync } from "node:fs";

type PreToolUseInput = {
  tool_name?: string;
  tool_input?: { command?: string };
};

const QUOTED_SPAN = /"[^"]*"|'[^']*'/g;
const SEGMENT_SPLIT = /&&|\|\||[;\n|]/;

const PR_EDIT = /\bgh\s+pr\s+edit\b/;
const PR_BODY_FLAG = /(?:^|\s)(?:--body|--body-file|-b|-F)(?:[=\s]|$)/;

const GH_API = /\bgh\s+api\b/;
const PULLS_PATH = /\/pulls\/\d+|\/pulls\b/;
const PATCH_METHOD = /(?:-X|--method)[=\s]+PATCH\b/i;
const API_BODY_FIELD = /(?:^|\s)(?:-f|-F|--field|--raw-field)[=\s]+body[=\s]/i;
const API_INPUT = /(?:^|\s)--input(?:[=\s]|$)/;

const OVERRIDE = /\bALLOW_PR_BODY=1\b/;

const REASON = `Blocked: this rewrites the body of an existing PR.

PR descriptions are written by Eneko once, at \`gh pr create\`. Iteration on an
open PR must never overwrite it — agents have clobbered hand-written
descriptions too many times.

Instead:
  - report iteration results as a NEW comment: \`gh pr comment <n> --body "..."\`
  - \`gh pr edit\` is fine for --title, --add-label, --add-reviewer, --base
  - if only part of the body needs to change, read it first
    (\`gh pr view <n> --json body -q .body\`), show Eneko the exact diff, and
    let him apply it

If Eneko explicitly asked for the description to be rewritten in this turn,
re-run the same command prefixed with \`ALLOW_PR_BODY=1\`. Never add that prefix
on your own initiative.`;

const segments = (command: string): string[] =>
  command
    .replace(QUOTED_SPAN, " QUOTED ")
    .split(SEGMENT_SPLIT)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

const editsPrBody = (command: string): boolean =>
  segments(command).some((segment) => {
    const edit = PR_EDIT.exec(segment);
    if (edit && PR_BODY_FLAG.test(segment.slice(edit.index + edit[0].length))) {
      return true;
    }
    const isPullsPatch =
      GH_API.test(segment) && PULLS_PATH.test(segment) && PATCH_METHOD.test(segment);
    return isPullsPatch && (API_BODY_FIELD.test(segment) || API_INPUT.test(segment));
  });

const main = (): void => {
  let data: PreToolUseInput;
  try {
    data = JSON.parse(readFileSync(0, "utf8")) as PreToolUseInput;
  } catch {
    return;
  }

  if (data?.tool_name !== "Bash") return;

  const command = data.tool_input?.command ?? "";

  if (OVERRIDE.test(command) || !editsPrBody(command)) return;

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: REASON,
      },
      systemMessage:
        "pr-body-guard: PR descriptions are Eneko's. Comment instead of rewriting the body.",
    }),
  );
};

main();
process.exit(0);

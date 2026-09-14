#!/usr/bin/env bun

/**
 * PreToolUse guard: agents never speak in a GitHub or Linear thread.
 *
 * A comment on a PR, issue, review thread or Linear ticket is published writing
 * with Eneko's name on it, read by colleagues who cannot tell an agent wrote it.
 * Findings belong in the terminal, in the wiki, or in a draft Eneko posts himself.
 *
 * Covers:
 *   Bash  — gh pr/issue comment, gh pr review, gh api + graphql writes to any
 *           comment/review endpoint, the same endpoints via curl, and the
 *           `linear issue comment add|update|delete` / `linear api` mutations.
 *   MCP   — the Linear server's comment and review-submission tools.
 *
 * Reading stays allowed: `gh pr view --comments`, `gh api .../comments` with no
 * write method, `linear issue comment list`. So is prose about all of the above:
 * quoted spans and heredoc bodies are masked before matching, so a commit
 * message or a doc that names these commands is not itself a comment. The mask
 * is lifted when the command line runs an interpreter (bash, ssh, python), where
 * a heredoc body IS the command.
 *
 * Escape hatch (Eneko's, never the agent's): export ALLOW_EXTERNAL_COMMENT=1 in
 * the environment Claude Code starts in, or `touch ~/.claude/allow-external-comment`
 * for a 15-minute window. Bash commands that try to do either from inside a
 * session are denied, so an agent cannot authorise itself.
 *
 * Contract: reads the PreToolUse JSON on stdin, emits a `permissionDecision:
 * deny` when it matches, otherwise nothing. ALWAYS exits 0 — a parse failure
 * fails OPEN, so a broken guard can never wedge every tool call.
 */

import { readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type PreToolUseInput = {
  tool_name?: string;
  tool_input?: { command?: string; file_path?: string };
};

const FILE_WRITE_TOOLS = new Set(["Write", "Edit", "NotebookEdit"]);

const SLIP_PATH = join(homedir(), ".claude", "allow-external-comment");
const SLIP_TTL_MS = 15 * 60 * 1000;
const OVERRIDE_VAR = "ALLOW_EXTERNAL_COMMENT";

const QUOTED_SPAN = /"[^"]*"|'[^']*'/g;
const SEGMENT_SPLIT = /&&|\|\||[;\n|]/;
const HEREDOC_BODY = /<<-?\s*(['"]?)([A-Za-z_][A-Za-z0-9_]*)\1[\s\S]*?^\s*\2\s*$/gm;
const INTERPRETER = /\b(?:bash|sh|zsh|ssh|python3?|node|bun|deno|perl|ruby)\b/;

const GH_COMMENT = /\bgh\s+(?:pr|issue)\s+comment\b/;
const GH_REVIEW = /\bgh\s+pr\s+review\b/;
const GH_API = /\bgh\s+api\b/;
const CURL = /\bcurl\b/;
const GITHUB_HOST = /\bapi\.github\.com\b/;
const COMMENT_ENDPOINT = /\/(?:comments|reviews)(?:\/|\b)/;
const GRAPHQL = /\bgraphql\b/;
const GITHUB_MUTATION =
  /\b(?:addComment|addDiscussionComment|addPullRequestReview(?:Comment|Thread)?|submitPullRequestReview|updateIssueComment|updatePullRequestReviewComment|deleteIssueComment|minimizeComment)\b/;

const LINEAR_CLI_COMMENT = /\blinear\s+(?:issue\s+)?comment\s+(?:add|update|delete|reply)\b/;
const LINEAR_API = /\blinear\s+api\b/;
const LINEAR_HOST = /\bapi\.linear\.app\b/;
const LINEAR_MUTATION =
  /\b(?:commentCreate|commentUpdate|commentDelete|commentResolve|issueCommentCreate)\b/;

const EXPLICIT_METHOD = /(?:-X|--method)[=\s]+([A-Za-z]+)/;
const GH_FIELD_FLAG = /(?:^|\s)(?:-f|-F|--field|--raw-field|--input)(?:[=\s]|$)/;
const CURL_BODY_FLAG = /(?:^|\s)(?:-d|--data(?:-raw|-binary|-urlencode)?|--json)(?:[=\s]|$)/;
const WRITE_METHODS = new Set(["POST", "PATCH", "PUT", "DELETE"]);

const OVERRIDE_ASSIGN = new RegExp(`${OVERRIDE_VAR}\\s*=`);
const SLIP_NAME = /allow-external-comment/;
const SLIP_WRITE_VERB = /\b(?:touch|tee|cp|mv|ln|install|truncate|dd|printf|echo)\b|>/;

const LINEAR_COMMENT_TOOLS = new Set([
  "save_comment",
  "save_diff_comment",
  "submit_diff_review",
  "delete_comment",
  "delete_diff_comment",
]);

const GITHUB_REASON = `Blocked: this posts an agent-written comment or review on GitHub.

Comments on a PR or issue go out under Eneko's account and read as his words
to everyone on the thread. An agent does not get that voice.

Instead:
  - report the finding in this session's output, or write it to the wiki
  - to hand Eneko something postable, print the exact body and let him send it
  - reading is untouched: \`gh pr view <n> --comments\`, \`gh api .../comments\`
    with no write method, \`gh pr diff\`

\`gh pr create\` is fine — opening a PR is not commenting on someone's thread.`;

const LINEAR_REASON = `Blocked: this posts an agent-written comment or review on Linear.

A Linear comment lands in the ticket's activity feed under Eneko's account and
notifies the whole team. An agent does not get that voice.

Instead:
  - report the finding in this session's output, or write it to the wiki
  - to hand Eneko something postable, print the exact body and let him send it
  - reading is untouched: list_comments, get_issue, \`linear issue comment list\`

Editing the issue itself (status, assignee, description) is not blocked.`;

const SELF_AUTH_REASON = `Blocked: this tries to lift the comment guard from inside the session.

\`${OVERRIDE_VAR}\` and ~/.claude/allow-external-comment are Eneko's switches,
not the agent's. If a comment genuinely needs to go out, say so and let him
either post it or open the window himself.`;

const overrideActive = (): boolean => {
  if (process.env[OVERRIDE_VAR] === "1") return true;
  try {
    return Date.now() - statSync(SLIP_PATH).mtimeMs < SLIP_TTL_MS;
  } catch {
    return false;
  }
};

const stripHeredocs = (command: string): string =>
  INTERPRETER.test(command.split("\n", 1)[0] ?? "")
    ? command
    : command.replace(HEREDOC_BODY, " HEREDOC ");

const segments = (command: string): string[] =>
  stripHeredocs(command)
    .replace(QUOTED_SPAN, " QUOTED ")
    .split(SEGMENT_SPLIT)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

const isWrite = (segment: string, bodyFlag: RegExp): boolean => {
  const method = EXPLICIT_METHOD.exec(segment);
  if (method) return WRITE_METHODS.has(method[1]!.toUpperCase());
  return bodyFlag.test(segment);
};

const commentsOnGithub = (command: string): boolean => {
  const raw = stripHeredocs(command);
  if (GRAPHQL.test(raw) && GITHUB_MUTATION.test(raw)) return true;
  return segments(command).some((segment) => {
    if (GH_COMMENT.test(segment) || GH_REVIEW.test(segment)) return true;
    if (!COMMENT_ENDPOINT.test(segment)) return false;
    if (GH_API.test(segment) && isWrite(segment, GH_FIELD_FLAG)) return true;
    return (
      CURL.test(segment) && GITHUB_HOST.test(segment) && isWrite(segment, CURL_BODY_FLAG)
    );
  });
};

const commentsOnLinear = (command: string): boolean => {
  const raw = stripHeredocs(command);
  if (LINEAR_MUTATION.test(raw) && (LINEAR_API.test(raw) || LINEAR_HOST.test(raw))) {
    return true;
  }
  return segments(command).some((segment) => LINEAR_CLI_COMMENT.test(segment));
};

const selfAuthorises = (command: string): boolean =>
  segments(command).some(
    (segment) =>
      OVERRIDE_ASSIGN.test(segment) ||
      (SLIP_NAME.test(segment) && SLIP_WRITE_VERB.test(segment)),
  );

const deny = (reason: string, note: string): void => {
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: reason,
      },
      systemMessage: note,
    }),
  );
};

const GITHUB_NOTE = "comment-guard: no agent comments on GitHub — report it here instead.";
const LINEAR_NOTE = "comment-guard: no agent comments on Linear — report it here instead.";

const main = (): void => {
  let data: PreToolUseInput;
  try {
    data = JSON.parse(readFileSync(0, "utf8")) as PreToolUseInput;
  } catch {
    return;
  }

  const tool = data?.tool_name ?? "";

  if (FILE_WRITE_TOOLS.has(tool)) {
    if (SLIP_NAME.test(data.tool_input?.file_path ?? "")) {
      deny(SELF_AUTH_REASON, "comment-guard: the override is Eneko's, not yours.");
    }
    return;
  }

  if (tool === "Bash") {
    const command = data.tool_input?.command ?? "";
    if (selfAuthorises(command)) {
      deny(SELF_AUTH_REASON, "comment-guard: the override is Eneko's, not yours.");
      return;
    }
    if (overrideActive()) return;
    if (commentsOnGithub(command)) deny(GITHUB_REASON, GITHUB_NOTE);
    else if (commentsOnLinear(command)) deny(LINEAR_REASON, LINEAR_NOTE);
    return;
  }

  if (tool.includes("linear") && LINEAR_COMMENT_TOOLS.has(tool.split("__").pop() ?? "")) {
    if (overrideActive()) return;
    deny(LINEAR_REASON, LINEAR_NOTE);
  }
};

main();
process.exit(0);

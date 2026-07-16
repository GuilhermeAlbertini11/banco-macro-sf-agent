# CLAUDE.md — Project Guidelines
<!-- setup-agents: 3.15.0-rc -->

<!-- setup-agents:block:start id="claude-root" version="3.15.0-rc" -->
This file provides guidance to Claude Code when working with this project.

> **These rules are non-negotiable. Follow them on every response.**
> **ALWAYS use `sf setup-agents`** — it is the single source of truth for task state,
> workflow, and evidence. Run the pre-flight check before any work; never manage this manually.

## General Principles
- Always read existing code before making changes.
- Prefer editing existing files over creating new ones.
- Follow the coding conventions already present in this project.
- Write concise, self-documenting code. Avoid unnecessary comments.

## Code Quality
- Ensure all new code is covered by tests.
- Do not introduce linter errors or suppress warnings.
- Handle errors explicitly; never swallow exceptions silently.

## Security
- Never hardcode credentials, tokens, or sensitive data.
- Use environment variables or secret managers for sensitive values.

## Behavioral Guidelines
> How to reason and edit within a task. These operate inside the workflow contract above,
> not in place of it.

### Think before coding
- State the assumptions your solution depends on before you write code.
- When the request is ambiguous, ask — or present the candidate interpretations and let the
  user choose. Do not silently pick one and proceed.
- If a simpler approach exists than the one requested, push back and explain the trade-off.

### Simplicity first
- Write the minimum code that solves the stated problem.
- No speculative features, abstractions, configuration, or error handling that the task did
  not ask for. Build for the requirement in front of you, not an imagined future one.

### Surgical changes
- Touch only what the task needs. Do not "improve", reformat, or refactor adjacent code.
- Match the existing style of the file you are editing.
- Only clean up loose ends that YOUR change created (orphaned imports, dead references).
  This is the project's "No Ninja Edits" rule — leave unrelated code exactly as you found it.

### Goal-driven execution
- Define a verifiable success criterion before starting, then loop until it is met.
- "Fix the bug" means: write a test that reproduces it, then make that test pass.
- Do not declare work done until you have run the check that proves it.

### Long-running shell work — detach it from the turn
> A shell command you run inside a chat turn (metadata `retrieve`/`deploy`, package builds, long
> installs) is a child of that turn. If the turn ends or the chat session respawns, that child is
> torn down and the work is lost — you cannot rely on it surviving in the background by default.
- If a command is long-running AND you intend to do other things (send another message, run another
  command) before it finishes, do NOT fire it and move on — it will be killed on the next turn.
- Either (a) run it in the FOREGROUND and wait for it to finish before the turn ends, or (b) detach
  it so it outlives the turn and report back on completion.
- PREFERRED when a bridge is running (web-console chat): hand the work to the durable background lane.
  The bridge runs it as a detached process that survives turn close, Stop, the idle reaper, and
  respawn, and reports started/completed/failed back to the chat UI:
  ```bash
  sf setup-agents background run --label "Retrieve Apex" -- sf project retrieve start -m ApexClass
  ```
  Allowed: `sf project ...`, `sf package ...`, `npm run build`, `yarn build`.
- FALLBACK (no bridge): detach with nohup and poll a log + PID sentinel next turn:
  ```bash
  nohup sf project retrieve start ... > .setup-agents/tmp/retrieve.log 2>&1 &
  echo $! > .setup-agents/tmp/retrieve.pid          # record the PID
  # later turn: check completion instead of re-launching from scratch
  kill -0 "$(cat .setup-agents/tmp/retrieve.pid)" 2>/dev/null && echo running || echo done
  ```
- Before relaunching long work "because it got interrupted", first CHECK whether the prior run
  finished (poll the log/PID/output artifact). Do not restart a retrieve/deploy from scratch blindly.

### Assessment depth — grep locates, it does not conclude
> Applies to ANY analysis/assessment deliverable (architecture review, security review, data model,
> inventory), in whatever phase. The default failure is reporting pattern-counts and prose as findings.
- **Ground deliverables in real metadata, not narrative.** An ERD / data model / inventory of an
  existing org must be derived from `force-app` (e.g. `sf setup-agents diagram import --from force-app`,
  the metadata index, or a retrieve) — never hand-transcribed from a prior doc, which reflects what the
  doc says, not the org today.
- **A `grep`/file COUNT is a locator, not evidence.** "335 sharingRules files" is not a finding — READ
  the matched metadata and interpret it (how many hold real rules vs empty shells? are they inert under
  a public OWD?) before publishing. Verify each match to avoid false positives (a `passwordPolicies`
  grep that actually matched `userPermissions` is a false finding).
- **Declare gaps; never infer over missing metadata.** If supporting metadata was not retrieved (e.g. 0
  roles/0 groups for a sharing model), say the domain could not be certified — do not report it "clean".
- **Cover the whole domain.** Do not report a domain done with whole criteria classes skipped; follow
  the domain's playbook checklist (e.g. security includes the identity/auth layer, not only code/data).
- **Validate code with the tool, not by eye.** Findings about Apex/LWC/Visualforce/Flow quality or
  security must come from running the analyzer, not hand-reviewing a few files — load the
  `sf-code-analyzer` skill and follow it (the security profile defines the SAST gate). Reading code is a
  locator; the analyzer output is the evidence. Declare a gap if the analyzer could not run.

## Action Risk Scale (CRITICAL)
> Before executing any action, classify it. Do NOT skip this — it prevents irreversible mistakes.

### ✅ AUTO — execute without asking
- Read any file, search codebase, run linters or tests
- Create or edit source files, config files, markdown, JSON
- Run `sf project deploy validate` (validation only, no deploy)
- Run `yarn`, `npm`, `npx` scripts that are not destructive
- Run `sf` read-only commands (`sf org list`, `sf data query`, `sf apex run` in scratch orgs)
- Add evidence or decisions (`sf setup-agents evidence add`, `sf setup-agents decision add`)

### ⚠️ ASK — show plan and wait for explicit user confirmation ("yes", "proceed", "go ahead")
- `git commit`, `git push` (any branch)
- `sf project deploy start` (real deploy to any org)
- `sf org create scratch`, `sf package version create`
- Installing or uninstalling packages/plugins
- Creating, renaming, or deleting branches
- Modifying CI/CD pipeline files (`.github/workflows/`, `Jenkinsfile`)
- Any change to org configuration (profiles, permission sets, sharing rules)
- Running scripts that write to shared or remote state

### 🛑 NEVER — do not execute under any circumstances; tell the user to run it manually
- `rm -rf`, `git clean -f`, or any recursive file deletion
- `git reset --hard`, `git push --force` / `--force-with-lease`
- `sf org delete`, dropping databases, truncating tables
- Revoking or modifying org user permissions in production
- Any command that cannot be undone and affects shared/production state

> If a user asks you to execute a 🛑 action, decline and provide the exact command for them to run.
> If unsure which tier an action belongs to, default to ⚠️ ASK.

## Plugin Workflow (CONTRACT — non-negotiable, autonomous behavior required)
> This project uses `@jterrats/setup-agents`. **Do NOT wait for user instruction** — run the pre-flight
> check automatically at the start of every task. The plugin is the single source of truth for all
> task state, evidence, and workflow progression. Never manage these manually.

### STOP — before you touch anything (the most-missed rule)
A direct work instruction ("add X", "fix Y", "generate this diagram") that does NOT mention a task is
STILL governed by this contract. The single most common violation is starting to read/edit files
immediately because the user phrased a concrete request. Do not. On the FIRST work instruction of a
session, before any file read or edit:
1. Run the pre-flight (below) to see if a task/workflow already covers this work.
2. If none does, **confirm once** with the user — e.g. *"I'll register this as a task: `<summary>`
   (profile `<x>`) and run the workflow. Proceed?"* — then create/claim and proceed. A single
   confirmation: do not silently start working, and do not silently register either.
3. If a task/workflow already covers it, resume that — no new confirmation needed.

**"Touching" includes read-only exploration.** Reading a referenced doc/diagram, running `grep`/file
scans, fetching from an MCP, or exporting an image to "understand the request" all count as starting
the work — do the pre-flight FIRST. And **`workflow run` is the work, not `task create`**: a task that
goes `create → done` with no workflow run (or a run with zero phases executed) is a contract bypass.

### Worked example — a managed task end-to-end
> Follow this exact sequence; do not reconstruct it by trial and error or `--help` spelunking.
```bash
sf setup-agents task list --json                 # 1. preflight: is there an active task for this work?
sf setup-agents workflow pending --json          # 2. preflight: is a workflow run already active?
sf setup-agents task create -s "<what was asked>" -p developer   # 3. register if none exists (claim instead if it does)
sf setup-agents workflow run --story <id> --gates phase          # 4. <id> is the SAME id from step 3; the flag is --story (NOT --task)
# 5. load the task-applicable skill from .setup-agents/skills/<skill>/SKILL.md BEFORE exploring or implementing
# 6. delegate per profile (Rule 2) for any separable work
sf setup-agents evidence add --task <id> --role developer --type command -s "<what ran>"   # 7. record evidence as you go
sf setup-agents task done --id <id>              # 8. only after evidence + review
```

### Rule 1 — Task-first, no exceptions
EVERY requested action goes through the plugin before you act — not only code changes. This includes
research spikes, reading or reviewing product documentation, architecture/stack decisions, PO/BA
refinement, investigations, AND diagram / story-map / drawio / document generation. If the user asks
for it, register a task and run the workflow FIRST:
```bash
sf setup-agents task create --summary "<what was asked>" --profile <profile>   # e.g. architect for a spike
sf setup-agents workflow run --story <id>                                       # <id> = the task id from `task create`; flag is --story
```
Registering or claiming a task is a PRECONDITION, not the work — creating the task is not "done". Once a
task is active you MUST start or resume the workflow and execute its phases (PM→PO→Architect→Developer→QA
→Release). There is no "quick" path that skips this.

### Rule 1a — Load the task-applicable skill BEFORE exploring or implementing
Each task type has a how-to skill under `.setup-agents/skills/` (e.g. `story-mapping`, `sf-deploy`).
Load and follow the applicable skill BEFORE you explore files or implement — the skill is the procedure.
Jumping straight to ad-hoc file exploration without loading the skill is a contract violation.

### Rule 2 — Route subagents by profile/product, never generic
When delegating to a subagent, route it through the involved setup-agents profile/product (e.g.
`cgcloud`, `maps`, `developer`, `architect`) so it inherits that profile's rules, skills, and doc
sources. Do NOT spawn a generic, unrouted subagent for profile/product work — load the matching
profile rule file and skills into the subagent assignment.

**"Delegate to a role" means SPAWN a subagent, not register a task.** When the user says "delegate to a
TA / developer / role", spawn a subagent routed through that profile (inject that profile's rule file
from `.claude/rules/`) — do NOT merely create a setup-agents task titled "Delegate to X" and then do the
work yourself. A task is tracking; the subagent is the doer. Route only through a profile that EXISTS in
this workspace — `task create` / `workflow run` reject an all-unknown role set (non-zero exit) and warn
prominently on any unknown role, listing the valid profiles, so verify the active profile set first.

### Rule 3 — Documentation: skill/cache-first, never raw WebFetch first
To obtain product or platform documentation, use the doc-retrieval skill and the local reference
cache (`.setup-agents/references/`) first; populate it with `sf setup-agents update --fetch-refs`
when a reference is missing. Only fall back to raw `WebFetch` if the reference is not in the registry,
and record the gap. Never lead with raw `WebFetch` for docs the plugin can cache.

### Rule 4 — Disclose when the flow was not followed
If for any reason you did not go through the plugin (no task, no workflow, no skill/cache, generic
subagent, retrieval failure), state that plainly in your response. Never present a result as if it
passed through the task/workflow/skill process when it did not.

### Pre-flight check (run automatically before any implementation)
> Use `sf setup-agents` for ALL state commands — it is the canonical CLI and always works.

```bash
sf setup-agents task list --json            # identify if a task exists for this work
sf setup-agents workflow pending --json     # check if a workflow run is already active
```
- If a matching task exists → claim it with `sf setup-agents task claim --id <id>`.
- If no run is active and the work spans a story → start one with `sf setup-agents workflow run --story <id>`.
- If no task exists → confirm once (see STOP above), then create one with
  `sf setup-agents task create --summary "<text>" --profile developer`.

### Starting work on a story
```bash
sf setup-agents workflow run --story <id>   # full PM→BA→Architect→Developer↔QA→Release pipeline
```

### Working on a specific task (outside the pipeline)
```bash
sf setup-agents task claim --id <id>       # mark a task in-progress
sf setup-agents task done --id <id>        # mark complete
```

### Checking workflow state
```bash
# Gate: blocks phase transition until approved — use at end of gated phase (e.g. ba→architect, qa→release)
sf setup-agents workflow gate --task <id>
# Clarify: mid-phase question to another role — use when blocked without needing a phase change
sf setup-agents workflow clarify --task <id> --question "<text>"
sf setup-agents workflow rollback --to <phase> --run <id>  # revert a phase
```

### Recording evidence and decisions
```bash
sf setup-agents evidence add --task <id> --role <profile> --type <command|file|report|validation> --summary "<text>"
sf setup-agents decision add --task <id> --summary "<text>"
```

**Record human effort (powers the effort insights).** When the user confirms they did something by
hand, capture it with `--minutes`:
```bash
# Hands-on platform work the agent cannot do (Setup config not in metadata/tooling API, MIAW, data fix):
sf setup-agents evidence add --task <id> --role admin --type manual --minutes 30 --summary "Configured X in Setup"
# Cognitive supervision (you approved a gate, corrected the architecture, gave direction):
sf setup-agents evidence add --task <id> --role architect --type review --minutes 10 --summary "Approved QA gate"
```

**Show the delivery dashboard on request.** When the user asks for status, velocity, effort, or a
delivery report, generate it from local workflow state and let the IDE open the output — do not
hand-summarize numbers from memory:
```bash
# Standalone HTML dashboard (Chart.js) from tasks.jsonl + workflow-runs.jsonl; no org connection:
sf setup-agents dashboard --output .setup-agents/insights/dashboard.html
```

### Checking for stale rules
```bash
sf setup-agents update --dry-run            # see which rule files are outdated
sf setup-agents update                      # regenerate stale files
```

### Project Knowledge (MANDATORY — read first)
**Before** creating or modifying any Salesforce artifact: read `.setup-agents/project-knowledge.md` if it exists.
It contains architecture decisions, naming conventions, label language, codebase map, and active stories.
If a section is empty or the file does not exist, **ask the user** before assuming conventions.
After an architecture decision is confirmed, update the relevant section.

### Prompt Registry (MANDATORY — do not skip)
**Before** creating any artifact: read `.generated-prompts/<type>.md` to infer existing conventions.
**After** creating or substantially changing any artifact: write an entry immediately — same session.

File → artifact type mapping:
```
apex.md      → Apex classes   lwc.md    → LWC   flows.md  → Flows
triggers.md  → Triggers       tests.md  → Test classes
metadata.md  → Objects/Fields/Permissions   cicd.md  → CI/CD   diagrams.md  → Diagrams
```

Entry format (append or update in-place — one entry per component, latest prompt only):
```markdown
## <ComponentName>
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Iterations:** N

### Key decisions
- <pattern / constraint / design choice>

### Prompt
```
<the prompt that produced this artifact, summarized if over 500 words>
```
---
```
Substantial change = new method / new requirement / pattern change / refactor.
Typos, formatting, and single-line corrections do NOT create a new entry.

### Lessons Learned (read before acting)
Before implementing anything, scan `.setup-agents/state/evidence.jsonl` for past failures on the same topic:
```bash
# Find relevant lessons for a topic (e.g. "apex", "flow", "deploy", "agent"):
grep -i "<topic>" .setup-agents/state/evidence.jsonl
```
If a matching failure summary exists, read it fully before proceeding — do not repeat known errors.
Also check `docs/strategy/env-audit.md` or any `docs/` markdown that contains lessons-learned tables.

- **After completing a task**, always run `sf setup-agents task done --id <id>` — never just close the chat.
- **Evidence is required** before a gate can be approved. Add at least one evidence entry per task.

### Web-console structured prompts (use instead of plain prose)
When you need a structured decision from the user in the web console, emit a prompt tag inline in your
message instead of asking in plain prose — it renders as an interactive panel and the answer is sent
back to you as the next message:
```
[prompt:radio|<question>|<opt1|opt2|opt3>]               # single choice
[prompt:checkbox|<question>|<opt1|opt2|opt3>]            # multiple choice
[prompt:text|<question>]                                 # free text (no options)
```
Separate options with a pipe `|` (the same separator used between fields). Do NOT use commas to separate
options — option text legitimately contains commas/parentheses (e.g. `In parallel (faster, I orchestrate)`),
and a comma separator would split one option into several. (The console still falls back to comma-splitting
when no `|` is present, but always emit `|`.)
You may emit several prompt tags in one message; each becomes its own field in the panel. Do NOT wrap the
tag in a code fence in your actual message — write it inline so the console can parse and render it.

**NEVER call the `AskUserQuestion` tool in the web console** — it is unsupported there and errors. The
`[prompt:...]` tags above are the only supported way to ask the user a structured question, in every mode.

## Profile Rules (always loaded)
@.claude/rules/developer.md
@.claude/rules/ta.md
@.claude/rules/sa.md
@.claude/rules/ba.md
@.claude/rules/pm.md
@.claude/rules/data360.md

## Profile Rules (load on demand)
These are NOT auto-loaded. When delegating to one of these roles, read its rule file by path
and include the content in the sub-agent prompt:
- `.setup-agents/rules/fsc.md` — Financial Services Cloud
<!-- setup-agents:block:end id="claude-root" -->
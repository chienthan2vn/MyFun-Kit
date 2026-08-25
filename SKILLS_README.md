# Superpowers Skills - Hướng Dẫn Sử Dụng

Tài liệu này giới thiệu toàn bộ **skills** trong `.claude/skills/`, bao gồm công dụng, các bước thực hiện, và artifacts được tạo ra. Đây là framework **Superpowers** — một bộ kỹ năng (skills) giúp điều phối phát triển phần mềm một cách có hệ thống và có trách nhiệm.

---

## Mục Lục

1. [Tổng Quan Framework](#tổng-quan-framework)
2. [Skills Danh Sách](#skills-danh-sách)
3. [Chi Tiết Từng Skill](#chi-tiết-từng-skill)
4. [Directory Structure](#directory-structure)
5. [Typical User Journeys](#typical-user-journeys)

---

## Tổng Quan Framework

Superpowers là một framework phát triển phần mềm theo hướng **context-driven development** — nghĩa là mỗi quyết định đều dựa trên ngữ cảnh (context) thực tế của dự án, không phải các giả định chung chung. Framework này được thiết kế để:

- **Giảm thiểu sai lầm** thông qua quy trình có kiểm tra (debugging hệ thống, TDD, verification)
- **Đảm bảo chất lượng** qua đánh giá (review) liên tục và kiểm chứng trước hoàn thành
- **Phối hợp đa công cụ** qua worktree, subagent, và các kỹ thuật chẩn đoán
- **Lưu lại học hỏi** qua ledger, patterns, và knowledge capture (Ralph-style)

### Nguyên Tắc Cốt Lõi

| Nguyên tắc | Mô tả |
|-----------|------|
| **Process trước Action** | Luôn kiểm tra skill áp dụng trước khi hành động |
| **Evidence trước Claims** | Chưa chạy lệnh xác minh → chưa được phép tuyên bố thành công |
| **Root Cause trước Fix** | Sửa triệu chứng là thất bại; phải tìm nguyên nhân gốc rễ |
| **Fresh Subagent per Task** | Mỗi task được thực hiện bởi một subagent mới, không kế thừa context cũ |
| **Worktree Isolation** | Luôn làm việc trong môi trường độc lập để tránh xung đột |
| **Human-in-the-Loop** | Con người là người ra quyết định cuối cùng (approval, merge, PR) |

---

## Skills Danh Sách

| # | Skill | Mô tả ngắn | Khi nào dùng | Artifacts chính |
|---|-------|-------------|--------------|-----------------|
| 1 | [using-superpowers](#1-usingsuperpowers) | Khởi động — thiết lập cách tìm và dùng skills | **Mỗi session đầu tiên** | Skills invocation plan |
| 2 | [brainstorming](#2-brainstorming) | Biến ý tưởng thành thiết kế (design doc) | Trước mọi creative/implementation work | `docs/superpowers/specs/*.md` |
| 3 | [writing-plans](#3-writing-plans) | Viết plan implementation chi tiết từ spec | Sau brainstorming (architectural path) | `docs/superpowers/plans/*.md` |
| 4 | [executing-plans](#4-executing-plans) | Thực thi plan trong session riêng | Khi plan đã có, cần review checkpoints | Todos, test runs |
| 5 | [subagent-driven-development](#5-subagent-driven-development) | Thực thi plan qua subagent mỗi task | Plan có tasks độc lập, trong cùng session | Ledger (`progress.md`), briefs, review packages |
| 6 | [dispatching-parallel-agents](#6-dispatching-parallel-agents) | Gửi nhiều subagent paralell | Khi có 2+ tasks độc lập, không shared state | Task summaries từ mỗi agent |
| 7 | [test-driven-development](#7-test-driven-development) | Viết test trước implementation (Red-Green-Refactor) | **Luôn** cho features, bug fixes, refactoring | Test files |
| 8 | [systematic-debugging](#8-systematic-debugging) | Tìm root cause trước khi fix | Bất kỳ bug, test failure, unexpected behavior | Root cause analysis, diagnostic logs |
| 9 | [verification-before-completion](#9-verification-before-completion) | Chạy lệnh xác minh trước khi claim thành công | Trước khi claim work done, commit, PR | Verification output |
| 10 | [finishing-a-development-branch](#10-finishing-a-development-branch) | Quyết định cách tích hợp work (merge/push/keep) | Khi implementation complete, tests green | Merged/PR'd branch, cleanup |
| 11 | [requesting-code-review](#11-requesting-code-review) | Gửi code reviewer subagent kiểm tra | Sau mỗi task, hoặc trước merge | Review reports |
| 12 | [receiving-code-review](#12-receiving-code-review) | Xử lý feedback từ code review | Khi nhận được feedback | Fixed code |
| 13 | [using-git-worktrees](#13-using-git-worktrees) | Tạo isolated workspace | Trước implementation work | Linked worktree |
| 14 | [writing-skills](#14-writing-skills) | Phát triển và test skill mới | Khi phát triển skills | Evals, pressure tests |

---

## Chi Tiết Từng Skill

### 1. Using Superpowers

**Mô tả:** Skill khởi động quan trọng nhất — thiết lập cách tìm và dùng các skills khác.

**Công dụng:**
- Nhắc nhở rằng phải invoke skill **trước** bất kỳ phản hồi nào, kể cả câu hỏi
- Đưa ra **Priority Order** giữa process skills và implementation skills
- Cảnh báo về các "Red Flags" khi rationalize bỏ qua skill

**Các bước:**
1. Kiểm tra xem skill nào áp dụng cho task hiện tại
2. Nếu có → invoke skill trước mọi thứ
3. Nếu nghi ngờ 1% skill áp dụng → **phải** invoke
4. Nếu có skill áp dụng → announce "Using [skill] to [purpose]"

**Artifacts:** Không tạo files mới — chỉ là quyết định invoke skill nào.

**Red Flags tránh:**
- "This is just a simple question" → Questions are tasks
- "I need more context first" → Skills tell you HOW to explore
- "I already know this skill" → Skills evolve, read current version

---

### 2. Brainstorming

**Mô tả:** Biến ý tưởng thành design sâu thẳng trước khi implementation.

**Three Paths:**

| Path | Khi nào | Đặặc trưng |
|------|---------|------------|
| **Spike** | Feasibility question ("can we...", "quick and dirty fine") | Output = answer, không giữ code. Cần approval, không có spec file |
| **Bounded** | Thay đổi code đã tồn tại (flag mới, endpoint nhỏ) | 1-2 câu hỏi, short design in chat. Approval trước implementation. Không có plan document |
| **Architectural** | Dự án mới, subsystem mới, restructure component fit | Full process: questions → approaches → design → spec → writing-plans |

**Iron Law:**
```
NO IMPLEMENTATION WITHOUT HUMAN APPROVAL
```

**Các bước (Architectural path):**

1. **Classify** request → spike/bounded/architectural
2. **Explore project context** — files, docs, recent commits
3. **Ask clarifying questions** — tối đa 5 câu, một câu mỗi message
4. **Propose 2-3 approaches** — kèm trade-offs, lead with recommendation
5. **Present design** — theo sections, scale theo complexity
6. **Design for isolation** — units nhỏ, well-defined interfaces, testable independently
7. **Write design doc** → `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
8. **Spec self-review** — placeholder scan, internal consistency, scope check, ambiguity check
9. **User review gate** — chờ user approve spec trước khi tiếp tục
10. **Transition** → invoke writing-plans skill

**Artifacts:**
- `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
- (Optional) `brainstorming/visual-companion.md` link nếu có visual question

**Workflow:**
```
Classify → Explore → Questions → Approaches → Design → 
Write Spec → Self-Review → User Review → Invoke writing-plans
```

**Red Flags:**
- "This is too simple to need a design" → Simple = short design, không phải no design
- "I'll call it bounded and skip the spec" → Đừng chọn label để skip work
- "It's bounded and the design is obvious" → Gate là approval, không phải design's length
- "It grew, but I'm almost done" → Hidden complexity upgrades path. Stop và re-classify

---

### 3. Writing Plans

**Mô tả:** Viết plan implementation chi tiết từ spec, chia thành tasks ăn được.

**Công dụng:**
- Map out files sẽ tạo/modify
- Task right-sizing (smallest unit worth review)
- Bite-sized steps (2-5 phút mỗi step)
- No placeholders

**Các bước:**

1. **Announce:** "I'm using the writing-plans skill..."
2. **Scope Check:** Nếu spec covers multiple subsystems → suggest chia thành separate plans
3. **File Structure:** Map files trước khi define tasks
4. **Task Structure:** Mỗi task có:
   - Files: Create/Modify/Test
   - Interfaces: Consumes/Produces
   - Steps: Write failing test → Run test → Write minimal code → Run test → Commit
5. **No Placeholders:** Mỗi step phải có actual content, code blocks
6. **Self-Review:**
   - Spec coverage: mỗi requirement có task nào implement?
   - Placeholder scan: không có "TBD", "TODO", "implement later"
   - Type consistency: function names/signature đồng nhất giữa tasks
7. **Execution Handoff:** Đề xuất 2 options:
   - Subagent-Driven (recommended)
   - Inline Execution

**Artifacts:**
- `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- Plan document với Global Constraints, Task Structure

**Plan Document Header (bắt buộc):**
```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
**Spec:** [path to spec]
**Global Constraints:** [project-wide requirements]
```

**Rule: No Placeholders**
- ❌ "TBD", "TODO", "implement later", "fill in details"
- ❌ "Add appropriate error handling" / "add validation" / "handle edge cases"
- ❌ "Write tests for the above" (không kèm actual test code)
- ❌ "Similar to Task N" (phải repeat code)
- ❌ Steps mô tả WHAT mà không show HOW (cần code blocks)

---

### 4. Executing Plans

**Mô tả:** Thực thi plan trong session riêng với review checkpoints.

**Công dụng:**
- Load plan, review critically, execute all tasks, report hoàn thành
- Phù hợp khi không thể dùng subagent (single session, cần checkpoint)

**Các bước:**

1. **Step 1: Load and Review Plan**
   - Ensure isolated workspace: `superpowers:using-git-worktrees`
   - Read plan file
   - Review critically — identify concerns trước khi start
   - Nếu concerns: raise with human partner
2. **Step 2: Execute Tasks** — mark in_progress → follow steps → mark completed
3. **Step 3: Complete Development** — invoke `finishing-a-development-branch`

**When to Stop and Ask:**
- Hit blocker (missing dependency, test fails, instruction unclear)
- Plan có critical gaps preventing starting
- Verification fails repeatedly

**Artifacts:** Todos, test runs, commit history

---

### 5. Subagent-Driven Development (SDD)

**Mô tả:** Thực thi plan bằng cách dispatch fresh subagent mỗi task, review sau mỗi task, và final whole-branch review ở cuối.

**Core Principle:** Fresh subagent per task + task review (spec + quality) + broad final review = high quality, fast iteration

**Workflow:**
```
Setup → Dispatch Implementer → Handle Report → Review Task → 
         Fix Loop (nếu cần) → Complete Task → ... → 
         Final Review → Finish
```

**Các bước chi tiết:**

#### Setup:
1. **Ensure worktree** — `superpowers:using-git-worktrees`
2. **Create ledger** — `# SDD ledger — plan: <plan file path>`
3. **Read plan once** — note context và Global Constraints
4. **Pre-flight review** — scan plan cho conflicts, write table to ledger

#### Per-Task Loop:

1. **Dispatch the implementer (subagent)**
   - Run `scripts/task-brief PLAN_FILE N` để lấy brief path
   - Dispatch với:
     - (1) One line: task fit trong project
     - (2) Brief path — "read this first — it is your requirements"
     - (3) Interfaces và decisions từ earlier tasks
     - (4) Resolution of ambiguity
     - (5) Report-file path và report contract
   - Implementer **không được dispatch subagents**

2. **Handle the report** — 4 statuses:
   - ✅ **DONE** → generate review package, dispatch reviewer
   - ⚠️ **DONE_WITH_CONCERNS** → read concerns, address trước khi review
   - ❓ **NEEDS_CONTEXT** → provide missing context, re-dispatch
   - 🚫 **BLOCKED** → 4 routes: context problem / more reasoning / break down / plan defect

3. **Review the task**
   - Run `scripts/review-package PLAN_FILE BASE HEAD` — in ra review package path
   - Dispatch task reviewer với: brief path + report path + review package path + global constraints
   - Reviewer verdicts: Spec ✅/❌ + Task Quality Approved/Not

4. **The Fix Loop** (trigger khi review báo spec ❌, finding Critical/Important, hoặc ⚠️ confirmed as real gap)
   - **Rounds 1-3:** Resume original implementer
   - **Rounds 4-5:** Fresh implementer với more capable model
   - Mỗi round: fix + re-run tests + re-review (scoped)
   - **Breaker (Round 5):** Adjudicate findings — park với ruling, hoặc rule load-bearing findings

5. **Complete the task**
   - Append completion line to ledger
   - Mark todo complete

#### Final Review:
1. Run `scripts/review-package PLAN_FILE MERGE_BASE HEAD`
2. Dispatch final code reviewer với `requesting-code-review/code-reviewer.md` template
3. Nếu có findings → ONE fix dispatch, ONE scoped re-review
4. Cleanup: delete plan workspace (`rm -rf <workspace>`)
5. Invoke `finishing-a-development-branch`

**Model Selection:**
- Mechanical tasks (1-2 files, complete spec) → cheap model
- Integration/judgment tasks → standard model
- Architecture/design tasks → most capable model
- Fix-loop escalation (rounds 4-5) → one tier above implementer

**Artifacts:**
- `<workspace>/progress.md` (ledger)
- `<workspace>/task-N-brief.md`
- `<workspace>/task-N-report.md`
- `<workspace>/review-package-*.md`

**Common Rationalizations:**
| Excuse | Reality |
|--------|---------|
| "Close enough on spec compliance" | Reviewer found spec gaps = not done |
| "I'll fix it myself" | Controller fixes pollute context, skip review |
| "One more round will converge" | Past cap, rounds don't converge — structural failure |
| "The reviewer will just find something new" | Scoped re-reviews verify fixes only |
| "Ledger bookkeeping is overhead" | Ledger survives compaction — controllers without one re-dispatch completed tasks |

---

### 6. Dispatching Parallel Agents

**Mô tả:** Gửi nhiều subagent cùng lúc để xử lý các tasks độc lập.

**Công dụng:**
- Tiết kiệm thời gian khi có nhiều failures độc lập
- Mỗi agent nhận scope rõ ràng, không kế thừa session context

**When to Use:**
- ✅ 3+ test files failing với different root causes
- ✅ Multiple subsystems broken independently
- ✅ Mỗi problem có thể hiểu without context từ others
- ✅ No shared state between investigations

**When NOT to Use:**
- ❌ Failures are related (fix one might fix others)
- ❌ Cần full system state
- ❌ Agents sẽ can thiệp nhau

**Các bước:**

1. **Identify Independent Domains** — group failures by problem domain
2. **Create Focused Agent Tasks** — mỗi agent nhận:
   - Specific scope (1 test file/subsystem)
   - Clear goal
   - Constraints (không đổi code khác)
   - Expected output format
3. **Dispatch in Parallel** — issue multiple Agent() calls trong cùng một response
4. **Review and Integrate** — đọc summaries, check conflicts, run full suite

**Agent Prompt Structure:**
- **Focused** — One clear problem domain
- **Self-contained** — All context needed
- **Specific about output** — What agent should return?

**Example Prompt Template:**
```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:
1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by:
   - Replacing arbitrary timeouts with event-based waiting
   - Fixing bugs in abort implementation if found
   - Adjusting test expectations if testing changed behavior

Do NOT just increase timeouts - find the real issue.

Return: Summary of what you found and what you fixed.
```

**Artifacts:** Task summaries từ mỗi agent, integrated diff

---

### 7. Test-Driven Development (TDD)

**Mô tả:** Viết test trước implementation, xem test fail, viết minimal code để pass.

**Iron Law:**
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

**Red-Green-Refactor Cycle:**

| Phase | Mô tả | Key Actions |
|-------|------|-------------|
| **RED** | Write failing test | One behavior, clear name, real code (no mocks nếu có thể) |
| **Verify RED** | Watch it fail correctly | Run test, confirm fails vì feature missing, không phải typo |
| **GREEN** | Write minimal code | Simplest code để pass test, không thêm features |
| **Verify GREEN** | Watch it pass | Run test, confirm pass, other tests vẫn pass |
| **REFACTOR** | Clean up | Remove duplication, improve names, extract helpers — giữ tests green |

**Các bước:**

1. **RED — Write Failing Test**
   - Một test, một behavior
   - Tên test mô tả behavior rõ ràng
   - Dùng real code, tránh mock
2. **Verify RED**
   - Chạy `npm test path/to/test.test.ts`
   - Xác nhận: test fails, failure message đúng, fail vì feature thiếu
3. **GREEN — Minimal Code**
   - Viết code đơn giản nhất để pass
   - Không thêm features, không refactor khác
4. **Verify GREEN**
   - Chạy lại test
   - Xác nhận: test pass, other tests vẫn pass, output sạch
5. **REFACTOR**
   - Dọn code sau khi green
   - Giữ tests green
6. **Repeat** — next failing test cho next feature

**Test Quality Checklist:**
- [ ] Every new function/method có test
- [ ] Watched mỗi test fail trước khi implement
- [ ] Mỗi test fail đúng lý do (feature missing, không phải typo)
- [ ] Viết minimal code để pass
- [ ] All tests pass
- [ ] Output sạch (không errors, warnings)
- [ ] Tests dùng real code (mocks chỉ khi không thể tránh)
- [ ] Edge cases và error cases covered

**Red Flags (STOP and Start Over):**
- Code before test
- Test after implementation
- Test passes immediately
- Can't explain why test failed
- Rationalizing "just this once"
- "I already manually tested it"

**Rules for Writing Good Tests:**
- Name the production change that would make test fail — trước khi viết test
- Assert trên real behavior, never mock behavior
- Keep test-only code trong test utilities, không phải production classes
- Understand dependency side effects trước khi mock

**Artifacts:** Test files (`*.test.*`)

---

### 8. Systematic Debugging

**Mô tả:** Tìm root cause trước khi fix — symptom fixes is failure.

**Iron Law:**
```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

**Four Phases (bắt buộc hoàn thành từng phase trước khi chuyển):**

#### Phase 1: Root Cause Investigation
1. **Read Error Messages Carefully** — đọc stack traces đầy đủ, note line numbers, file paths
2. **Reproduce Consistently** — có thể trigger reliably không? Exact steps?
3. **Check Recent Changes** — git diff, recent commits, new dependencies
4. **Gather Evidence in Multi-Component Systems** — log ở mỗi component boundary, verify environment/config propagation
5. **Trace Data Flow** — trace backward từ bad value về nguồn gốc (xem `root-cause-tracing.md`)

#### Phase 2: Pattern Analysis
1. **Find Working Examples** — đoạn code tương tự nhưng hoạt động
2. **Compare Against References** — đọc reference implementation COMPLETELY, đừng skim
3. **Identify Differences** — liệt kê mọi difference, dù nhỏ nhất
4. **Understand Dependencies** — config, environment, assumptions

#### Phase 3: Hypothesis and Testing
1. **Form Single Hypothesis** — "I think X is root cause vì Y"
2. **Test Minimally** — thay đổi nhỏ nhất để test, one variable at a time
3. **Verify** — worked → Phase 4; didn't work → new hypothesis
4. **When You Don't Know** — nói "I don't understand X", hỏi help, research thêm

#### Phase 4: Implementation
1. **Create Failing Test Case** — simplest reproduction, automated test nếu có thể
2. **Implement Single Fix** — fix root cause, ONE change, không "while I'm here"
3. **Verify Fix** — test passes, other tests không bị broken, issue thật sự resolved
4. **If Fix Doesn't Work:**
   - Count số fixes đã thử
   - < 3 → return Phase 1, re-analyze
   - ≥ 3 → **STOP** → Question architecture (Phase 4.5)

#### Phase 4.5: Question Architecture
**Dấu hiệu vấn đề architectural:**
- Mỗi fix lại tiết lộ shared state/coupling/problem khác ở nơi khác
- Fixes đòi hỏi "massive refactoring"
- Mỗi fix tạo symptom ở chỗ khác

**STOP and discuss với human partner** trước khi try thêm fixes nữa.

**Red Flags:**
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "Here are the main problems: [lists fixes without investigation]"

**Supporting Techniques (trong cùng thư mục):**
- `root-cause-tracing.md` — trace bugs backward qua call stack
- `defense-in-depth.md` — thêm validation ở multiple layers
- `condition-based-waiting.md` — thay thế timeout bằng condition polling

**Artifacts:** Root cause analysis, diagnostic logs, failing test

---

### 9. Verification Before Completion

**Mô tả:** Chạy lệnh xác minh trước khi claim work complete, fixed, passing.

**Iron Law:**
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

**Gate Function:**
```
BEFORE claiming bất kỳ status nào:

1. IDENTIFY: What command proves claim?
2. RUN: Execute FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Output confirm claim?
   - NO → State actual status with evidence
   - YES → State claim WITH evidence
5. ONLY THEN: Make the claim
```

**Claim ↔ Requires:**

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Requirements met | Line-by-line checklist | Tests passing |

**Red Flags:**
- Dùng "should", "probably", "seems to"
- Express satisfaction trước khi verification ("Great!", "Perfect!", "Done!")
- About to commit/PR mà chưa verify
- Trust agent success reports
- Relying on partial verification

**Key Patterns:**
```bash
# Tests
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"

# Regression tests (TDD Red-Green)
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)

# Build
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed"

# Requirements
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
```

**When To Apply:**
- TRƯỚC khi claim success/completion
- TRƯỚC khi commit/push/PR
- TRƯỚC khi delegate to agents

---

### 10. Finishing a Development Branch

**Mô tả:** Khi implementation complete, quyết định cách tích hợp work (merge/push/keep).

**Core Principle:** Verify tests → Detect environment → Present options → Execute choice → Clean up.

**Các bước:**

1. **Step 1: Verify Tests**
   - Chạy full test suite (`npm test`, `cargo test`, `pytest`, `go test ./...`)
   - Nếu tests fail → report failures, dừng lại
   - Nếu tests pass → tiếp tục

2. **Step 2: Detect Environment**
   ```bash
   GIT_DIR=$(git rev-parse --git-dir)
   GIT_COMMON=$(git rev-parse --git-common-dir)
   WORKTREE_PATH=$(git rev-parse --show-toplevel)
   ```
   - `GIT_DIR == GIT_COMMON` → Normal repo → Standard 3 options
   - `GIT_DIR != GIT_COMMON`, named branch → Standard 3 options, cleanup
   - `GIT_DIR != GIT_COMMON`, detached HEAD → Reduced 2 options (no merge)

3. **Step 3: Determine Base Branch** — confirm fork point

4. **Step 4: Present Options**
   - **Normal/named-branch:**
     1. Merge back to `<base-branch>` locally
     2. Push and create PR
     3. Keep branch as-is
   - **Detached HEAD:**
     1. Push as new branch and create PR
     2. Keep as-is

5. **Step 5: Execute Choice**
   - **Option 1 (Merge):** git checkout base → git pull → git merge → verify tests → cleanup worktree → branch -d
   - **Option 2 (PR):** git push -u origin HEAD → create PR → keep worktree
   - **Option 3 (Keep):** Report branch + worktree location

6. **Step 6: Cleanup Workspace** (Option 1 + discards)
   - `GIT_DIR == GIT_COMMON` → nothing to clean
   - `WORKTREE_PATH` under `.worktrees/` → `git worktree remove` + `prune`
   - Otherwise → leave in place (externally managed)

**Artifacts:** Merged/PR'd branch, cleaned-up workspace

---

### 11. Requesting Code Review

**Mô tả:** Gửi code reviewer subagent để kiểm tra trước khi cascade issues.

**Core Principle:** Review early, review often.

**When to Request:**
- ✅ Sau mỗi task trong subagent-driven development
- ✅ Sau khi hoàn thành major feature
- ✅ Trước khi merge to main
- ✅ Khi stuck (fresh perspective)
- ✅ Trước khi refactor
- ✅ Sau khi fix complex bug

**Cách thức:**

1. **Lấy git SHAs:**
   ```bash
   BASE_SHA=$(git rev-parse HEAD~1)  # hoặc origin/main
   HEAD_SHA=$(git rev-parse HEAD)
   ```

2. **Dispatch code reviewer subagent** — điền template tại `code-reviewer.md`:
   - `{DESCRIPTION}` — tóm tắt ngắn gì đã built
   - `{PLAN_OR_REQUIREMENTS}` — link/task number
   - `{BASE_SHA}` — starting commit
   - `{HEAD_SHA}` — ending commit

3. **Act on feedback:**
   - Critical: fix ngay
   - Important: fix trước khi proceed
   - Minor: note for later
   - Push back if reviewer wrong (với technical reasoning)

**Artifacts:** Review reports (strengths, issues, assessment)

**Key Rule:** Hand reviewer precisely crafted context — NEVER session history.

---

### 12. Receiving Code Review

**Mô tả:** Xử lý feedback từ code review một cách có hệ thống, không performative.

**Core Principle:** Verify trước khi implement. Technical correctness > social comfort.

**Response Pattern:**
```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate trong từ của bạn (hoặc hỏi)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

**Forbidden Responses:**
- ❌ "You're absolutely right!"
- ❌ "Great point!" / "Excellent feedback!"
- ❌ "Let me implement that now" (trước khi verify)
- ❌ Bất kỳ gratitude expression nào

**Preferred Responses:**
- ✅ "Fixed. [Brief description of what changed]"
- ✅ "Good catch - [specific issue]. Fixed in [location]."
- ✅ Just fix it và show trong code

**Source-Specific Handling:**

**Từ human partner (trusted):**
- Implement sau khi understand rõ
- Still ask nếu scope unclear
- Skip performative agreement
- Chuyển thẳng vào hành động

**Từ external reviewers:**
1. Check: Technically correct for THIS codebase?
2. Check: Breaks existing functionality?
3. Check: Reason cho current implementation?
4. Check: Works on all platforms/versions?
5. Check: Reviewer có full context không?

**Nếu suggestion sai:** Push back với technical reasoning

**Nếu không verify được:** "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

**Nếu conflicts với human partner's prior decisions:** Stop và discuss trước

**YAGNI Check:**
```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage
  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**Implementation Order (multi-item feedback):**
1. Clarify unclear items FIRST
2. Implement theo thứ tự:
   - Blocking issues (breaks, security)
   - Simple fixes (typos, imports)
   - Complex fixes (refactoring, logic)
3. Test mỗi fix riêng biệt
4. Verify no regressions

**Artifacts:** Fixed code

---

### 13. Using Git Worktrees

**Mô tả:** Tạo isolated workspace cho feature work, tránh ảnh hưởng workspace hiện tại.

**Core Principle:** Detect existing isolation → Use native tools → Fall back to git worktree. Never fight the harness.

**Các bước:**

1. **Step 0: Detect Existing Isolation**
   ```bash
   GIT_DIR=$(git rev-parse --git-dir)
   GIT_COMMON=$(git rev-parse --git-common-dir)
   BRANCH=$(git branch --show-current)
   ```
   - Submodule guard: `git rev-parse --show-superproject-working-tree`
   - `GIT_DIR != GIT_COMMON` (và không phải submodule) → Already in linked worktree → Skip đến Step 2

2. **Step 1: Create Isolated Workspace**
   - **Step 1a: Native Worktree Tools (preferred)** — nếu có công cụ native (EnterWorktree, /worktree, --worktree flag)
   - **Step 1b: Git Worktree Fallback** (chỉ khi Step 1a không áp dụng)
     - Directory priority: instruction preference → `.worktrees/` → `worktrees/`
     - **Safety:** `git check-ignore -q .worktrees` — phải ignored trước khi tạo
     - ```bash
       git worktree add "$path" -b "$BRANCH_NAME"
       cd "$path"
       ```

3. **Step 2: Project Setup** — auto-detect dependencies:
   ```bash
   if [ -f package.json ]; then npm install; fi
   if [ -f Cargo.toml ]; then cargo build; fi
   # Python, Go...
   ```

4. **Step 3: Verify Clean Baseline** — chạy tests để đảm bảo workspace sạch

**Quick Reference:**

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0) |
| In a submodule | Treat as normal repo (Step 0 guard) |
| Native worktree tool available | Use it (Step 1a) |
| No native tool | Git worktree fallback (Step 1b) |
| `.worktrees/` exists | Use it (verify ignored) |
| Directory not ignored | Add to .gitignore + commit |
| Permission error on create | Sandbox fallback, work in place |
| Tests fail during baseline | Report + ask |

**Artifacts:** Linked worktree, baseline test run

---

### 14. Writing Skills

**Mô tả:** Phát triển và test skill mới cho framework Superpowers.

**Công dụng:**
- Tạo skill mới cho các pattern lặp lại
- Áp dụng TDD ngay cả với skills
- Sử dụng `superpowers:writing-skills` để develop và test

**Các bước (theo đề xuất):**

1. **Phát hiện pattern** — skill nên giúp với 1 loại task cụ thể
2. **Viết skill** — sử dụng template, đưa ra rules/rationalizations/anti-patterns
3. **Test với subagents** — chạy skill qua nhiều sessions khác nhau
4. **Pressure testing** — adversarial pressure across sessions
5. **Eval evidence** — so sánh before/after, chứng minh cải thiện outcomes

**Key Guidance:**
- Skills are **code that shapes agent behavior**, không phải prose
- Mỗi skill có: overview, iron law, when to use, process, common rationalizations, red flags
- Đặc biệt quan trọng: Red Flags tables, rationalization lists, "human partner" language — đây là carefully-tuned content, sửa đổi cần evidence cải thiện

**Artifacts:** Skill files (`SKILL.md`, supporting reference files), eval results

---

## Directory Structure

```
.claude/
├── agents/                    # Custom subagent definitions
├── hooks/                     # Event-driven hooks
├── skills/                    # Superpowers skills framework
│   ├── brainstorming/
│   │   ├── SKILL.md
│   │   ├── visual-companion.md
│   │   ├── spec-document-reviewer-prompt.md
│   │   └── scripts/
│   ├── writing-plans/
│   │   ├── SKILL.md
│   │   └── plan-document-reviewer-prompt.md
│   ├── executing-plans/
│   │   └── SKILL.md
│   ├── subagent-driven-development/
│   │   ├── SKILL.md
│   │   ├── implementer-prompt.md
│   │   ├── task-reviewer-prompt.md
│   │   ├── re-review-prompt.md
│   │   └── scripts/
│   │       ├── sdd-workspace
│   │       ├── task-brief
│   │       └── review-package
│   ├── dispatching-parallel-agents/
│   │   └── SKILL.md
│   ├── test-driven-development/
│   │   ├── SKILL.md
│   │   └── writing-good-tests.md
│   ├── systematic-debugging/
│   │   ├── SKILL.md
│   │   ├── root-cause-tracing.md
│   │   ├── defense-in-depth.md
│   │   ├── condition-based-waiting.md
│   │   ├── CREATION-LOG.md
│   │   └── test-pressure-*.md
│   ├── verification-before-completion/
│   │   └── SKILL.md
│   ├── finishing-a-development-branch/
│   │   └── SKILL.md
│   ├── requesting-code-review/
│   │   ├── SKILL.md
│   │   └── code-reviewer.md
│   ├── receiving-code-review/
│   │   └── SKILL.md
│   ├── using-git-worktrees/
│   │   └── SKILL.md
│   ├── using-superpowers/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── codex-tools.md
│   │       ├── gemini-tools.md
│   │       ├── hermes-tools.md
│   │       ├── pi-tools.md
│   │       └── antigravity-tools.md
│   ├── writing-skills/
│   │   ├── SKILL.md
│   │   ├── testing-skills-with-subagents.md
│   │   ├── persuasion-principles.md
│   │   ├── anthropic-best-practices.md
│   │   └── examples/
│   │       └── CLAUDE_MD_TESTING.md
│   └── README.md  ← (file bạn đang đọc)
├── workflows/                 # Conductor workflows
├── new_skills/                # New skills being developed
└── settings.json              # Cấu hình Claude Code
```

---

## Typical User Journeys

### Journey 1: Greenfield Project (từ đầu)

```
1. using-superpowers → kiểm tra skill áp dụng
2. brainstorming → classify "architectural", propose approaches, write spec
3. writing-plans → create implementation plan với tasks
4. using-git-worktrees → create isolated workspace
5. For mỗi task:
     a. subagent-driven-development → dispatch implementer
     b. requesting-code-review → review task
     c. (nếu có issues) → fix loop
6. verification-before-completion → verify tests/build
7. finishing-a-development-branch → merge hoặc tạo PR
```

### Journey 2: Fix Bug Trong Codebase Tồn Tại

```
1. systematic-debugging → find root cause
   - Phase 1: Read errors, reproduce, check changes
   - Phase 2: Compare working examples
   - Phase 3: Form hypothesis, test minimally
   - Phase 4: Create failing test, fix, verify
2. test-driven-development → write regression test
3. verification-before-completion → verify fix
4. requesting-code-review → (tùy chọn) ask review
   hoặc self-review nếu nhỏ
```

### Journey 3: Multi-Session Development

```
1. brainstorming → write spec, save to docs/
2. writing-plans → write plan với tasks, save to docs/
3. using-git-worktrees → tạo workspace cho feature branch
4. subagent-driven-development → thực thi plan
    - Ledger ở <workspace>/progress.md ghi lại tiến trình
    - Resume từ ledger nếu context bị lost
5. finishing-a-development-branch → merge hoặc PR
```

### Journey 4: Parallel Investigation (nhiều failures độc lập)

```
1. dispatching-parallel-agents → dispatch nhiều subagent
   - Mỗi agent một failure domain
   - Prompt cụ thể: scope, goal, constraints, output format
2. Review từng agent's results
3. Check conflicts giữa các fixes
4. Run full test suite để integrate

Ví dụ:
  Agent 1 → Fix auth tests
  Agent 2 → Fix payment tests  
  Agent 3 → Fix logging tests
```

### Journey 5: Code Review Feedback

```
1. Nhận được feedback từ reviewer
2. receiving-code-review:
   - READ: Đọc toàn bộ feedback không react
   - UNDERSTAND: Restate trong từ bạn
   - VERIFY: Check against codebase
   - EVALUATE: Technically sound?
   - RESPOND: Technical ack hoặc reasoned pushback
   - IMPLEMENT: One item at a time, test mỗi cái
3. verification-before-completion → chạy tests
```

### Journey 6: Tạo Skill Mới

```
1. writing-skills → develop skill structure
2. test-writing-skills-with-subagents → chạy skill
   qua nhiều sessions để collect evidence
3. Pressure testing → adversarial testing
4. So sánh before/after với eval evidence
5. Nếu improve outcomes → có thể merge vào core
```

---

## Skill Interaction Flow

```
using-superpowers
    ↓ (always check first)
brainstorming  ──────────────→ writing-plans
    ↓ (architectural path)         ↓
                               using-git-worktrees
                                    ↓
    subagent-driven-development  OR  executing-plans
         ↓                               ↓
    requesting-code-review     verification-before-completion
         ↓                               ↓
    receiving-code-review    finishing-a-development-branch
         ↓
verification-before-completion
```

**Lưu ý:** `systematic-debugging` và `test-driven-development` có thể được invoke ở bất kỳ thời điểm nào khi cần. `dispatching-parallel-agents` được dùng khi có nhiều independent investigations.

---

## Key Concepts

### The Approval Gate
**Iron Rule của brainstorming:** Không ai được bắt đầu implementation cho đến khi human partner đã approve design. Điều này áp dụng cho mọi task — từ simple config change đến full architecture.

### Fresh Context Principle
Subagents trong SDD luôn nhận **fresh context** — chỉ brief path, report path, interfaces, và global constraints. Không bao giờ paste session history vào dispatch prompt.

### Evidence-Based Claims
Verification-before-completion yêu cầu: **Evidence trước khi claim thành công.** Chưa run lệnh xác minh → chưa được claim "tests pass" hay "bug fixed".

### The Ledger Pattern
Trong SDD, progress được tracking qua ledger file (`progress.md`) chứ không phải chỉ memory. Điều này quan trọng vì context có thể bị lost sau compaction.

### Model Selection Strategy
- Mechanical tasks (1-2 files, complete spec) → dùng model rẻ (cheap tier)
- Integration tasks → model trung bình
- Architecture/design → model mạnh nhất
- Fix-loop rounds 4-5 → one tier above implementer

---

*Generated for the Superpowers framework at `/home/merlin/project/myfun-kit/`*
*Date: 2026-08-26*
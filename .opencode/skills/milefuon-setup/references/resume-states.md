# Resume State Machine — milefuon-setup

Maps `milefuon/setup_state.json` → resume point.

| `last_successful_step` | Meaning | Next action on resume |
|------------------------|---------|-----------------------|
| *(file missing)* | Fresh project, no setup yet | Section 1.1 (Pre-init Overview) |
| `""` (empty string) | Pre-init done, discovery pending | Section 2.0 (Project Discovery) |
| `"product"` | `product.md` approved and written | Section 2.2 (tech-stack.md) |
| `"tech_stack"` | `tech-stack.md` approved and written | Section 2.3 (workflow.md) |
| `"workflow"` | `workflow.md` approved and written | Section 2.4 (Scaffold) |
| `"complete"` | Setup fully finished | HALT — announce "Project already initialized. Run milefuon-newtrack." |
| any other value | Corruption or unknown state | HALT — announce "Unrecognized setup state: <value>. Manual repair required." |

## State Transition Diagram

```
(missing) ──→ 1.1 Overview ──→ 2.0 Discovery ──→ 2.1 product.md ──→ [state: product]
                                                                          │
                                                                          ▼
                                                              2.2 tech-stack.md ──→ [state: tech_stack]
                                                                                            │
                                                                                            ▼
                                                                                2.3 workflow.md ──→ [state: workflow]
                                                                                                              │
                                                                                                              ▼
                                                                                                  2.4 Scaffold ──→ [state: complete]
                                                                                                                            │
                                                                                                                            ▼
                                                                                                                  2.5 AGENTS.md + Finalize
```

## State File Format

```json
{"last_successful_step": "<value>"}
```

Only one key. Written after each Section 2.x approval gate passes. Never written partially — atomic write per section.

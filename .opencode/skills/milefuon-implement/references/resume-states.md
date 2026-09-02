# Resume State Machine — milefuon-implement

Maps `milefuon/tracks/<track_id>/implement_state.json` → resume point.

## State File Format

```json
{
  "current_phase": "<phase_name>",
  "current_phase_index": 0,
  "current_task_index": 0,
  "completed_phases": ["<phase_name>"],
  "last_updated": "<ISO8601>",
  "status": "<status>"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `current_phase` | string | Name of the current phase being executed |
| `current_phase_index` | number | Zero-based index of current phase in plan.md |
| `current_task_index` | number | Zero-based index of current task within the phase |
| `completed_phases` | string[] | Names of phases fully completed |
| `last_updated` | string | ISO8601 timestamp of last state update |
| `status` | string | One of `starting`, `in_progress`, `completed` |

## Status Values

| `status` | Meaning | Next action on resume |
|----------|---------|-----------------------|
| `starting` | Just created, no task executed yet | Start from §4.1 Phase Graph |
| `in_progress` | Actively executing a task | Resume from `current_phase` / `current_task_index` |
| `completed` | All phases done (should have been deleted) | Should not exist — if found, treat as completed |

## State Transitions

```
(missing) ──→ Create {starting, phase:"", idx:0} ──→ §4.1 Phase Graph
                                                        │
                                         ┌──────────────┘
                                         ▼
                              Task in_progress ──→ Update {current_phase, phase_index, task_index, in_progress}
                                         │
                                         ▼
                              Task [x] + learnings ──→ Next task (task_index++)
                                         │
                              Phase done ──→ completed_phases.push(phase) ──→ task_index=0 ──→ Check next ready phases
                                         │
                              All phases done ──→ Delete implement_state.json ──→ §5.0 Finalize
```

## Recovery Protocol

1. **File missing:** Fresh implementation — create initial state with `status: starting`
2. **File exists, valid JSON:** Resume from `current_phase_index` / `current_task_index`
3. **File exists, empty or corrupted JSON:** Announce "Corrupted implement state file detected at milefuon/tracks/<track_id>/implement_state.json. Delete the file to restart implementation." → **HALT**
4. **Parallel state exists:** If `parallel_state.json` exists alongside `implement_state.json`, the parallel phase was interrupted — re-read `parallel_state.json` to resume workers or reset to sequential

## Parallel State File

`milefuon/tracks/<track_id>/parallel_state.json` — only exists during parallel execution:

```json
{
  "phase": "<phase_name>",
  "execution_mode": "parallel",
  "started_at": "<ISO8601>",
  "workers": [
    {
      "worker_id": "worker_0_task_name",
      "task": "<task_description>",
      "task_index": 0,
      "files": ["path/to/file"],
      "depends_on": [],
      "status": "in_progress",
      "started_at": "<ISO8601>",
      "completed_at": null,
      "commit_sha": null
    }
  ],
  "file_locks": {"path/to/file": "worker_0_task_name"},
  "completed_workers": 0,
  "total_workers": 2
}
```

Deleted after phase aggregation (§4.3 c7). If found on resume without active workers, delete and re-execute phase.

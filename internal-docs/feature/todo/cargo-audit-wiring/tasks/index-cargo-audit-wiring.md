# Cargo Audit Wiring — Task Index

| Story ID | Story Title | Phase | Status | Parallel-safe | Dependencies | Modules |
|----------|-------------|-------|--------|---------------|--------------|---------|
| 01-001 | Add audit target to nx-target-rust partial | 01 | [x] Done | true | — | nx-partials |
| 01-002 | Wire cargo audit into package rust justfile validate + add outdated | 01 | [x] Done | true | — | package-rust, justfile |
| 01-003 | Wire cargo audit into CLI rust justfile quality/release + add outdated + audit target | 01 | [x] Done | true | — | cli-rust, justfile |
| 02-001 | Add cargo audit security job to CLI rust CI workflow | 02 | [x] Done | true | 01-003 | cli-rust, ci |
| 02-002 | Update README docs to reflect audit in validation | 02 | [x] Done | true | 01-002, 01-003 | docs |

## Phase Summary

- **Phase 01**: Core wiring — nx partial, justfiles (3 parallel stories)
- **Phase 02**: CI + documentation (2 parallel stories, depend on Phase 01)

## Notes

- Total stories: 5
- All stories completed
- All Phase 01 stories were parallel-safe (different files, no conflicts)

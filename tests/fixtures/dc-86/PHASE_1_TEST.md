# Phase 1: Test Matrix

| Behavior | FR | Partition | Layer | Test ref | Pinned line |
|----------|----|-----------|-------|----------|-------------|
| Valid nickname is stored | FR-1 | normal | endpoint | - | - |
| Request without session is rejected | FR-1 | permission | endpoint | - | - |
| Length limits 3 and 20 are inclusive | FR-2 | boundary | unit | - | - |
| Space or uppercase is rejected | FR-2 | invalid | unit | - | - |
| Nickname taken in a different case is rejected | FR-3 | invalid | integration | - | - |
| Response carries a request id header | - | normal | endpoint | - | - |

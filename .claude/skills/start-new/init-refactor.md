# init-refactor Instructions

Instructions for initializing refactoring work through target analysis and dependency mapping.

## Step-by-Step Questions

Use AskUserQuestion tool for each step sequentially:

### Step 1: 대상
```
Question: "리팩토링 대상은 무엇인가요?"
Header: "리팩토링 대상"
→ Free text (파일, 모듈, 클래스, 함수 등)
```

### Step 2: 문제점
```
Question: "현재 어떤 문제가 있나요?"
Header: "문제점"
Options:
  - label: "중복 코드 (DRY 위반)"
    description: "같은 로직이 여러 곳에 반복됨"
  - label: "긴 메서드/클래스 (SRP 위반)"
    description: "하나의 단위가 너무 많은 책임을 가짐"
  - label: "복잡한 조건문"
    description: "if/switch 문이 복잡하게 중첩됨"
  - label: "강한 결합도"
    description: "모듈간 의존성이 높음"
  - label: "테스트 어려움"
    description: "유닛 테스트 작성이 어려움"
multiSelect: true
```

### Step 3: 목표 상태
```
Question: "리팩토링 후 기대하는 상태는?"
Header: "목표"
→ Free text (목표 아키텍처, 패턴 등)
```

### Step 4: 동작 변경
```
Question: "기존 동작이 변경되어도 괜찮나요?"
Header: "동작 변경"
Options:
  - label: "동작 유지 필수"
    description: "순수 리팩토링, 기능 변경 없음"
  - label: "일부 변경 가능"
    description: "개선을 위해 동작 변경 허용"
multiSelect: false
```

### Step 5: 테스트 현황
```
Question: "관련된 테스트가 있나요?"
Header: "테스트"
Options:
  - label: "있음"
    description: "테스트 커버리지 확보됨"
  - label: "일부 있음"
    description: "부분적으로 테스트 존재"
  - label: "없음"
    description: "테스트 먼저 작성 필요"
multiSelect: false
```

### Step 6: 의존 모듈
```
Question: "이 코드를 사용하는 다른 모듈이 있나요?"
Header: "의존성"
Options:
  - label: "없음/모름"
    description: "다른 모듈에서 사용 안함 또는 파악 필요"
→ Or free text via "Other"
```

---

## Analysis Phase

**MANDATORY**: After gathering user requirements (Steps 1-6), execute analysis phases.

Read `_analysis.md` for the common analysis workflow (Steps A-E).

### Refactor-Specific Analysis

#### Step B: Codebase Investigation (Refactor Focus)

1. **Target Code Analysis**
   - Read target files specified in Step 1
   - Analyze current structure and identify code smells
   - Document current behavior for preservation

2. **Usage Analysis**
   - Grep for all usages of target code (functions, classes, modules)
   - Build dependency graph: who calls this? what does this call?
   - Identify all affected modules

3. **Test Coverage Check**
   - Find existing tests for target code
   - Assess coverage level
   - Identify missing test cases needed before refactoring

4. **Pattern Analysis**
   - Identify current patterns in use
   - Compare against codebase conventions
   - Document target patterns for refactoring

Output: Dependency map and coverage assessment

#### Step C: Conflict Detection (Refactor Focus)

For refactoring, detect conflicts between:

1. **Refactoring vs Callers**
   - Will signature changes break callers?
   - Are there external dependencies (other packages, APIs)?

2. **Refactoring vs Behavior Preservation**
   - If "동작 유지 필수" selected: verify behavior can be preserved
   - Identify behavioral changes that would require user approval

3. **Refactoring vs Parallel Work**
   - Check for other branches modifying same files
   - Run: `git log --all --oneline -- {target_file}`

Document all conflicts and get user resolution via AskUserQuestion.

#### Step D: Edge Case Generation (Refactor Focus)

Generate edge cases for refactored code:

1. **Behavioral Equivalence Cases**
   - Cases that verify old and new behavior match
   - Critical paths that must work identically

2. **New Pattern Cases**
   - Cases that exercise new code structure
   - Cases that validate improved design

3. **Regression Cases**
   - Cases from existing bugs or known issues
   - Cases that ensure old problems don't resurface

Present to user for confirmation.

---

## Refactoring Safety Notes

- If test coverage is low: recommend writing tests BEFORE refactoring
- If dependency graph is complex: suggest incremental refactoring phases
- If behavior preservation is critical: require approval for any behavioral change

---

## Branch Keyword

**Auto-generate from conversation context:**
- Extract core target from answers (Step 1)
- Format: `refactor/{keyword}`
- Examples:
  - refactor/user-service
  - refactor/extract-api-client
  - refactor/simplify-auth-flow

---

## SPEC.md Content

Create SPEC.md with refactor-specific format:

- **Target** (from Step 1)
- **Current Problems** (from Step 2)
- **Goal State** (from Step 3)
- **Behavior Change Policy** (from Step 4)
- **Test Coverage** (from Step 5)
- **Dependencies** (from Step 6)
- **XP Principle Reference** (auto-added based on problems)
- **Analysis Results**:
  - Related Code (dependency map)
  - Conflicts Identified (with resolutions)
  - Edge Cases (behavioral equivalence, new pattern, regression)
  - Test Coverage Assessment

---

## Output

1. Refactor branch `refactor/{keyword}` created and checked out
2. Directory `claude_works/{subject}/` created
3. `claude_works/{subject}/SPEC.md` created with all sections above

# Code Smell Catalog

Detailed catalog of code smells to look for during Phase 2 (Identify Issues)
of the evolutionary refactor workflow. Grouped by the standard Refactoring
catalog (Fowler) plus an AI-specific group.

## Bloaters

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Long Method** | A method exceeds ~50 LOC or does several things | Extract Method, Replace Temp with Query, Substitute Algorithm |
| **Long Parameter List** | More than ~3-4 params; callers struggle to get order right | Introduce Parameter Object, Preserve Whole Object, Replace Parameter with Method Call |
| **Primitive Obsession** | Domain concepts represented as primitives (string userId, int cents) | Replace Data Value with Object, Replace Type Code with Class, introduce branded/primitive types |
| **Data Clumps** | Same group of fields/params travels together everywhere | Extract Class, Introduce Parameter Object |

## Object-Orientation Abusers

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Alternative Classes with Different Interfaces** | Two classes do the same job with different method names | Rename Method, Extract Superclass, move toward a common interface |
| **Refused Bequest** | Subclass uses only a fraction of parent's interface | Replace Inheritance with Delegation, Push Down Field/Method |
| **Switch Statements** | Repeated `switch`/`if-else` on the same type code | Replace Conditional with Polymorphism, Replace Type Code with Subclasses/State-Strategy |
| **Temporary Field** | Object fields set only in specific contexts (then null otherwise) | Extract Class, Introduce Null Object |

## Change Preventers

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Divergent Change** | One class changes for many different reasons | Extract Class (split by responsibility) |
| **Parallel Inheritance Hierarchies** | Adding a subclass on one side forces adding one on the other | Move Method/Field, Extract Superclass, collapse hierarchies |
| **Shotgun Surgery** | One logical change requires touching many classes | Move Method/Field, Inline Class, Extract Class to consolidate |

## Dispensables

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Comments** | Comments explain *what* instead of *why* | Extract Method, Rename Method — let code explain itself; keep comments for intent |
| **Data Class** | Class with only fields and getters/setters, no behavior | Move Method into the class, Encapsulate Field, Hide Method |
| **Lazy Class** | Class does too little to justify its existence | Inline Class, Collapse Hierarchy |
| **Duplicate Code** | Same logic in multiple places | Extract Method, Extract Superclass, Extract Subclass, Form Template Method |
| **Dead Code** | Unused fields, methods, classes, imports | Delete it; rely on git history |
| **Speculative Generality** | Abstractions/hookpoints for "someday" needs | Collapse Hierarchy, Inline Class, Remove Setting Method |

## Couplers

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Feature Envy** | Method talks more to another class than its own | Move Method, Extract Method then Move |
| **Incomplete Library Class** | Library class missing needed behavior | Introduce Foreign Method, Introduce Local Extension |
| **Middle Man** | Class just delegates to another | Remove Middle Man, Inline Method, Replace Delegation with Inheritance |
| **Inappropriate Intimacy** | Two classes know too much about each other's internals | Move Method, Extract Class, Replace Delegation with Inheritance |
| **Message Chains** | `a.getB().getC().getD()` style calls | Hide Delegate, Extract Method then Move |

## AI-Specific Smells

| Smell | Symptoms | Remediation |
|-------|----------|-------------|
| **Full-Cycle Prompts** | User input + AI with access to private data + output to user, with no guardrails | Add input validation, output filtering, and redaction between stages |
| **Heavy Prompts Without Preprocessing** | Every request goes to the high-reasoning model | Insert a lightweight classifier model to screen and route |
| **Not Wired for Evals** | No eval harness, no golden cases, no regression detection | Add evals/ with golden cases and run on every change |
| **AI Used Where Deterministic Code Suffices** | Probabilistic method used for a problem with a known deterministic solution | Replace with the deterministic solution; reserve AI for genuinely probabilistic tasks |

## Security & Compliance Smells (Cross-Cutting)

- Using a dependency when a direct implementation would be simpler and safer
- Using a dependency with an incompatible license
- Accepting user input without taint-tracking / branded types
- Logging or embedding secrets; not using single-use guard types for secrets

## See Also

- [Legacy Code Techniques](legacy-code-techniques.md) — Michael Feathers' techniques for refactoring code without tests.
- [Refactor Checklist](refactor-checklist.md) — pre/during/post refactor checklists and prioritization procedure.

## Sources

- Migrated from `src/current/rules/software-dev/general/code-plan-refactor.md` (Code Smells section)

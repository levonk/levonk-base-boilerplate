# Input Modes

The skill accepts three input modes. The mode determines the workflow and
which references are relevant.

## Mode 1: From Requirements Document

The user provides a PRD, user stories, or acceptance criteria.

### Workflow

1. Read the requirements document.
2. Extract UI requirements (see
   [Requirements Extraction](requirements-extraction.md)).
3. Generate coverage tests from requirements (see
   [Coverage Test Generation](coverage-test-generation.md)).
4. Derive usability tasks from user stories (see
   [Usability Task Definition](usability-task-definition.md)).
5. Generate usability test specs from tasks (see
   [Usability Test Generation](usability-test-generation.md)).
6. Wire CI (see [CI Integration](ci-integration.md)).
7. Run coverage tests. Run usability tests if keys are available.
8. Report gaps and usability results.

### When to Use

- Greenfield project with a PRD
- Existing project with documented requirements but no UI/UX tests
- Adding UI/UX tests to a project that has requirements but only unit tests

## Mode 2: From Existing Test Suite

The user has existing Playwright/Appium tests. The skill audits them for
coverage gaps and adds missing tests.

### Workflow

1. Run `project-detection` to identify the test framework.
2. Inventory existing tests — what UI elements and flows do they cover?
3. Interview the user for requirements not covered by existing tests.
4. Generate coverage tests for the gaps.
5. Derive usability tasks from user stories or user input.
6. Generate usability test specs.
7. Wire CI.
8. Report: existing coverage, new coverage added, usability tests added.

### When to Use

- Project has Playwright/Appium tests but no requirements coverage or
  usability testing
- Project has tests but they are brittle selector-based tests that should
  be supplemented with accessibility-tree-based coverage tests
- User wants to add the usability dimension to an existing test suite

## Mode 3: From Scratch

No requirements document exists. The skill interviews the user.

### Workflow

1. Interview the user (see
   [Requirements Extraction — From-Scratch Mode](requirements-extraction.md#from-scratch-mode)).
2. Extract UI requirements from the interview answers.
3. Generate coverage tests.
4. Extract usability tasks from the interview answers.
5. Generate usability test specs.
6. Wire CI.
7. Run coverage tests. Run usability tests if keys are available.
8. Report.

### Interview Questions

1. "What are the main screens in your application?"
2. "What can a user do on each screen?"
3. "What are the critical user tasks — the top 3-5 things a user must
   accomplish?"
4. "Are there any conditional states (empty, error, loading, admin-only)?"
5. "What platform(s) does the application target — web, iOS, Android?"
6. "Is the application running locally for testing? What URL/port?"

### When to Use

- Greenfield project with no formal requirements document
- Existing project where requirements are implicit (in the team's heads)
- Rapid prototyping where formal requirements are deferred

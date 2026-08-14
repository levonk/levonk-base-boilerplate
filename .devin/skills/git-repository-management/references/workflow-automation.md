# Git Workflow Automation

## Automated Commit Organization

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
  
  - repo: https://github.com/commitizen-tools/commitizen
    rev: v3.2.2
    hooks:
      - id: commitizen
        stages: [commit-msg]
  
  - repo: local
    hooks:
      - id: run-tests
        name: Run tests
        entry: npm test
        language: system
        pass_filenames: false
        always_run: true
```

### Commit Message Validation
```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // New feature
        'fix',      // Bug fix
        'docs',     // Documentation
        'style',    // Formatting
        'refactor', // Code refactoring
        'test',     // Tests
        'chore',    // Maintenance
        'perf',     // Performance
        'ci',       // CI/CD
        'build',    // Build system
        'release'   // Release management
      ]
    ],
    'subject-case': [2, 'never', ['start-case', 'pascal-case', 'upper-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'type-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'scope-empty': [1, 'never'],
    'body-max-line-length': [2, 'always', 72],
    'footer-max-line-length': [2, 'always', 72]
  }
};
```

## Automated Branch Management

### Branch Naming Convention
```bash
#!/bin/bash
# create-branch.sh
BRANCH_TYPE=$1
BRANCH_NAME=$2
TICKET_NUMBER=$3

case $BRANCH_TYPE in
  "feature")
    BRANCH="feature/${TICKET_NUMBER}-${BRANCH_NAME}"
    ;;
  "fix")
    BRANCH="fix/${TICKET_NUMBER}-${BRANCH_NAME}"
    ;;
  "hotfix")
    BRANCH="hotfix/${TICKET_NUMBER}-${BRANCH_NAME}"
    ;;
  "release")
    BRANCH="release/${BRANCH_NAME}"
    ;;
  *)
    echo "Invalid branch type: $BRANCH_TYPE"
    exit 1
    ;;
esac

git checkout -b "$BRANCH"
echo "Created branch: $BRANCH"
```

### Automated Merge Strategy
```yaml
# .github/workflows/auto-merge.yml
name: Auto Merge
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: npm test
        
      - name: Check code quality
        run: npm run lint
        
      - name: Auto-merge if checks pass
        if: |
          github.event.pull_request.base.ref == 'develop' &&
          github.event.pull_request.title =~ '^(feat|fix|docs|test|chore)'
        uses: ahmadnassri/action-dependabot-auto-merge@v2
        with:
          target: auto-merge
          github-token: ${{{ "{{" }}} secrets.GITHUB_TOKEN {{{ "}}" }}}
```

## Automated Release Management

### Semantic Versioning
```json
{
  "name": "your-project",
  "version": "1.0.0",
  "scripts": {
    "release": "semantic-release",
    "release:dry-run": "semantic-release --dry-run"
  },
  "devDependencies": {
    "@semantic-release/changelog": "^6.0.0",
    "@semantic-release/git": "^10.0.0",
    "semantic-release": "^19.0.0"
  }
}
```

### Release Configuration
```javascript
// .releaserc.js
module.exports = {
  branches: ['main', 'develop'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    '@semantic-release/npm',
    '@semantic-release/github',
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md', 'package.json'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
      }
    ]
  ]
};
```

## Automated Repository Maintenance

### Dependency Updates
```yaml
# .github/workflows/dependency-update.yml
name: Update Dependencies
on:
  schedule:
    - cron: '0 0 * * 1'  # Every Monday

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update dependencies
        run: |
          npm update
          npm audit fix
          
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v4
        with:
          token: ${{{ "{{" }}} secrets.GITHUB_TOKEN {{{ "}}" }}}
          commit-message: 'chore(deps): Update dependencies'
          title: 'Weekly Dependency Update'
          branch: 'chore/dependency-update'
          delete-branch: true
```

### Code Quality Automation
```yaml
# .github/workflows/code-quality.yml
name: Code Quality
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm run test:coverage
        
      - name: Run linter
        run: npm run lint
        
      - name: Type checking
        run: npm run type-check
        
      - name: Security audit
        run: npm audit --audit-level=high
```

## Custom Git Aliases

### Productivity Aliases
```bash
# ~/.gitconfig
[alias]
  # Commit organization
  cm = commit -m --no-edit
  ca = commit --amend --no-edit
  cs = commit -s --no-edit
  fix = "!f() { git commit -m \"fix: $1\" --no-edit; }; f"
  feat = "!f() { git commit -m \"feat: $1\" --no-edit; }; f"
  docs = "!f() { git commit -m \"docs: $1\" --no-edit; }; f"
  test = "!f() { git commit -m \"test: $1\" --no-edit; }; f"
  chore = "!f() { git commit -m \"chore: $1\" --no-edit; }; f"
  
  # Branch management
  br = branch
  co = checkout
  cob = "!f() { git checkout -b $1; }; f"
  bd = "!f() { git branch -d $1; }; f"
  bD = "!f() { git branch -D $1; }; f"
  
  # Status and log
  st = status
  lg = log --oneline --graph --decorate --all
  ll = log --pretty=format:\"%h %d %s %an %cr\" --graph
  changes = diff --name-status -r
  
  # Workflow
  done = "!f() { git add .; git commit -m \"chore: $1\"; git push; }; f"
  wip = "!f() { git add .; git commit -m \"WIP: $1\"; }; f"
  undo = reset --soft HEAD~1
  redo = "!f() { git reset --hard $1; }; f"
```

## Integration with IDE

### VS Code Integration
```json
{
  "git.enableSmartCommit": true,
  "git.smartCommitChanges": "all",
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.postCommitCommand": "none",
  "git.showInlineOpenFile": false,
  "git.suggestSmartCommit": true,
  "git.supportAutoMerge": true
}
```

### Git Hooks Integration
```json
{
  "gitHooks": {
    "pre-commit": "lint-staged",
    "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write",
      "git add"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write",
      "git add"
    ]
  }
}
```

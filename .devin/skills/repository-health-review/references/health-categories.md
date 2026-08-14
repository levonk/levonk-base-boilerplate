# Health Analysis Categories

## 1. Outdated Information Detection

**What it checks:**

- Date references older than 365 days
- Deprecated tool versions and frameworks
- Outdated URLs and broken links
- Old API references and deprecated methods
- Legacy configuration patterns

**Impact Assessment:**

- 🔴 **Critical**: Security vulnerabilities in outdated dependencies
- 🟡 **Warning**: Performance issues with deprecated tools
- 🔵 **Info**: Documentation that needs updating

## 2. Conflicting Rules Analysis

**What it checks:**

- ESLint configuration conflicts
- Gitignore pattern contradictions
- Build script conflicts
- Documentation contradictions
- Configuration file inconsistencies

**Common Conflicts:**

- Quote style rules (single vs double)
- Semicolon requirements (always vs never)
- File inclusion/exclusion patterns
- Environment variable conflicts

## 3. Undocumented Standards Detection

**What it checks:**

- Custom scripts without documentation
- Environment variables without explanation
- Custom file formats without descriptions
- Proprietary tools without setup guides
- Internal conventions without documentation

**Documentation Gaps:**

- Missing README sections
- Undocumented API endpoints
- Unclear configuration requirements
- Hidden dependencies
- Implicit team knowledge

## 4. Lessons from Failures Analysis

**What it checks:**

- TODO/FIXME comments with urgency indicators
- Temporary workarounds marked as permanent
- Known issues without resolution plans
- Performance bottlenecks noted in code
- Security-related temporary code

**Failure Patterns:**

- "TODO fix later" without timeline
- "HACK temporary" still in production
- "BUG critical" without fix
- "Workaround for" without proper solution
- "Remove before production" still present

## 5. Missing Tool Documentation

**What it checks:**

- Tools mentioned without setup instructions
- Configuration files without explanations
- Development environment setup gaps
- Deployment process documentation
- Testing framework setup guides

**Tool Categories:**

- Container tools (Docker, Kubernetes)
- CI/CD platforms (GitHub Actions, GitLab CI)
- Infrastructure tools (Terraform, Ansible)
- Development tools (ESLint, Prettier, testing frameworks)
- Monitoring and logging tools

## 6. Security and Access Patterns

**What it checks:**

- Hardcoded secrets and credentials
- Insecure configurations
- Overly permissive access patterns
- Missing security headers
- Authentication implementation gaps

**Security Issues:**

- API keys in configuration files
- Debug mode in production
- SSL/TLS verification disabled
- 777 file permissions
- Missing authentication safeguards

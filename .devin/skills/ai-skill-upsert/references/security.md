# Security Considerations for Skills

## Core Security Principles

### Principle of Lack of Surprise

Skills must not contain malware, exploit code, or any content that could compromise system security. A skill's contents should not surprise the user in their intent if described.

**Forbidden**:
- Malicious code designed to facilitate unauthorized access
- Data exfiltration mechanisms
- Code that exploits vulnerabilities
- Backdoors or hidden functionality

**Allowed**:
- Roleplay skills (e.g., "roleplay as an XYZ")
- Educational security content (e.g., explaining vulnerabilities)
- Legitimate automation tools

## Audit Requirements

### Audit All Bundled Content

Before packaging or using a skill, review:
- **Scripts**: Check for malicious code, external fetches, hardcoded credentials
- **Images**: Verify no embedded malware or suspicious content
- **Resources**: Ensure no sensitive data or credentials

### Avoid External Fetches

Skills fetching external URLs pose security risks. Prefer:
- Bundling required resources in the skill
- Using local references
- Allowing the user to specify external resources

If external fetches are necessary:
- Clearly document what is being fetched
- Use HTTPS with certificate validation
- Implement timeouts
- Sanitize all inputs
- Document the security implications

## Treat Skills Like Installing Software

Skills have the same security implications as installing software:
- Only use skills from trusted sources
- Review the skill's contents before use
- Be cautious with skills that require elevated permissions
- Report suspicious skills to the platform maintainers

## Tool Misuse Risk

Malicious skills can invoke tools harmfully. Be aware of:

### File System Operations
- Skills that delete files without confirmation
- Skills that modify system files
- Skills that access sensitive directories

### Network Operations
- Skills that make unauthorized network requests
- Skills that exfiltrate data
- Skills that bypass security controls

### Code Execution
- Skills that execute arbitrary code
- Skills that modify system configuration
- Skills that install software without user consent

## Best Practices

### 1. Validate All Inputs

```python
# Bad - no validation
def process_file(filename):
    with open(filename) as f:
        return f.read()

# Good - validate path
import os
def process_file(filename):
    if not os.path.abspath(filename).startswith(allowed_dir):
        raise ValueError("Access denied")
    with open(filename) as f:
        return f.read()
```

### 2. Use Principle of Least Privilege

- Only request the minimum permissions needed
- Avoid requesting write access when read-only suffices
- Document why each permission is needed

### 3. Sanitize User Input

```python
# Bad - command injection risk
import os
def run_command(user_input):
    os.system(f"process {user_input}")

# Good - safe execution
import subprocess
def run_command(user_input):
    subprocess.run(["process", user_input], check=True)
```

### 4. Avoid Hardcoded Credentials

Never include:
- API keys
- Passwords
- Tokens
- Private keys

Instead:
- Use environment variables
- Prompt the user for credentials
- Document required configuration

### 5. Implement Timeouts

```python
import requests
from requests.exceptions import Timeout

# Bad - no timeout
response = requests.get(url)

# Good - with timeout
try:
    response = requests.get(url, timeout=30)
except Timeout:
    handle_timeout()
```

### 6. Use Secure Defaults

- Default to secure configurations
- Don't default to insecure settings
- Document security trade-offs

## Security Checklist

Before packaging a skill, verify:

- [ ] No hardcoded credentials or secrets
- [ ] No malicious code or backdoors
- [ ] All inputs are validated and sanitized
- [ ] External fetches are documented and necessary
- [ ] File operations are restricted to appropriate directories
- [ ] Network operations use HTTPS with validation
- [ ] Timeouts are implemented for network operations
- [ ] Permissions are minimal and documented
- [ ] Error messages don't leak sensitive information
- [ ] Dependencies are from trusted sources
- [ ] The skill's purpose is clearly described
- [ ] The skill's behavior matches its description

## Reporting Security Issues

If you discover a security issue with a skill:
1. Document the issue clearly
2. Report it to the skill maintainer
3. If unresponsive, report to platform maintainers
4. Do not publicly disclose until patched

## Surface-Specific Security Notes

### Claude.ai
- Skills run in isolated environment
- Network access varies by settings
- File access restricted to workspace

### Claude API
- Workspace-wide skill sharing
- No network access
- Pre-installed skills only

### Claude Code
- Personal or project-level skills
- Full network access
- Local installation only

## Common Vulnerabilities

### 1. Path Traversal

```python
# Vulnerable
def read_file(path):
    with open(path) as f:
        return f.read()

# Secure
import os
def read_file(path):
    safe_path = os.path.normpath(path)
    if not safe_path.startswith(allowed_dir):
        raise ValueError("Invalid path")
    with open(safe_path) as f:
        return f.read()
```

### 2. Command Injection

```python
# Vulnerable
import os
def execute(cmd):
    os.system(cmd)

# Secure
import subprocess
def execute(cmd):
    subprocess.run(cmd.split(), check=True)
```

### 3. SSRF (Server-Side Request Forgery)

```python
# Vulnerable
def fetch(url):
    return requests.get(url)

# Secure
def fetch(url):
    if not url.startswith(("https://", "http://trusted-domain.com/")):
        raise ValueError("Invalid URL")
    return requests.get(url, timeout=30)
```

### 4. XML External Entity (XXE)

```python
# Vulnerable
import xml.etree.ElementTree as ET
def parse_xml(xml_string):
    return ET.fromstring(xml_string)

# Secure
import defusedxml.ElementTree as ET
def parse_xml(xml_string):
    return ET.fromstring(xml_string)
```

## Additional Resources

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Python Security Best Practices: https://docs.python.org/3/library/security_warnings.html
- Secure Coding Guidelines: https://wiki.sei.cmu.edu/confluence/display/seccode/SEI+CERT+Coding+Standards

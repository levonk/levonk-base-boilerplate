# Security Features

**Automatic Security Scanning:**
- **Configuration Analysis**: Scans environment configuration files for dangerous patterns
- **Command Injection Prevention**: Detects potential command injection vectors
- **Container Security**: Identifies privileged containers and unsafe volume mounts
- **Package Verification**: Warns about insecure package sources (HTTP URLs)
- **Cache-based Validation**: Only rescans when configuration changes

**Security Scan Results:**
```bash
🚨 SECURITY ERRORS FOUND:
  ⚠️  DANGEROUS: 'rm -rf' found in .envrc
Environment scan FAILED. Please fix security issues before proceeding.

⚠️ Security warnings found:
  ⚠️  WARNING: 'eval $()' found in .envrc - potential command injection
  ⚠️  WARNING: HTTP URLs found in devbox.json packages
Proceeding with caution...
✓ Security scan completed for direnv environment
```

# Security Fixes

This document describes the security issues that were identified and fixed in this repository.

## Docker Security Issues Fixed

### 1. API Dockerfile (`src/api/Dockerfile`)

#### Issue: Outdated Base Image
- **Problem**: Using `golang:1.21-alpine` which is outdated and may contain known vulnerabilities
- **Fix**: Updated to `golang:1.23-alpine` which includes the latest security patches
- **Impact**: Reduces exposure to known vulnerabilities in older Go versions

#### Issue: Running as Root User
- **Problem**: Container runs as root user, which violates the principle of least privilege
- **Fix**: Added non-root user configuration using the `nobody` user from Alpine Linux
  ```dockerfile
  COPY --from=builder /etc/passwd /etc/passwd
  USER nobody
  ```
- **Impact**: If container is compromised, attacker has limited privileges

### 2. Web Dockerfile (`src/web/Dockerfile`)

#### Issue: Unpinned Base Image
- **Problem**: Using `nginx:alpine` without version pinning, which can lead to unexpected changes
- **Fix**: Pinned to specific version `nginx:1.27-alpine`
- **Impact**: Ensures consistent and predictable deployments, easier to track security updates

#### Issue: Missing curl for Healthcheck
- **Problem**: HEALTHCHECK command uses `curl` but it's not installed, causing healthcheck to always fail
- **Fix**: Added `RUN apk add --no-cache curl` before the HEALTHCHECK instruction
- **Impact**: Healthchecks now work properly, improving container monitoring

#### Issue: Healthcheck Testing Wrong Endpoint
- **Problem**: Healthcheck was testing `/api` endpoint which is a proxy, not a direct health indicator
- **Fix**: Changed healthcheck to test root endpoint `/` which is directly served by nginx
- **Impact**: More reliable health status reporting

## Terraform Security Issues Fixed

### 1. SCM Minimum TLS Version (`modules/app/main.tf`)

#### Issue: Weak TLS Version for SCM
- **Problem**: SCM (Source Control Management) endpoint was using TLS 1.2 as minimum version
- **Fix**: Updated default minimum TLS version from `1.2` to `1.3`
  ```hcl
  scm_minimum_tls_version = optional(string, "1.3")
  ```
- **Impact**: Enforces stronger encryption for SCM operations, protecting against protocol downgrade attacks

## Security Issues Not Fixed (Require Breaking Changes)

The following security issues were identified but not fixed to maintain backward compatibility:

### ACR Admin Account Enabled
- **Issue**: Azure Container Registry admin account is enabled (`admin_enabled = true`)
- **Why Not Fixed**: The Docker provider requires credentials to push images to ACR. Disabling admin would require:
  - Setting up service principal authentication
  - Updating all module configurations
  - Potentially breaking existing deployments
- **Recommendation**: Consider implementing managed identity or service principal authentication in a future major version

### Public Network Access
- **Issue**: Resources are accessible from public networks
- **Why Not Fixed**: Restricting network access would require:
  - VNet configuration
  - Private endpoints setup
  - Significant infrastructure changes
- **Recommendation**: Implement network restrictions based on specific deployment requirements

## Testing Performed

1. **Docker Image Builds**: Both API and web Dockerfiles build successfully
2. **Container Runtime**: Containers run successfully and respond to requests
3. **Terraform Validation**: All Terraform configurations validate successfully
4. **Non-root User Verification**: API container confirmed to run as `nobody` user

## Summary

This PR successfully addresses several security issues while maintaining backward compatibility and functionality:

- ✅ Updated base images to latest secure versions
- ✅ Implemented non-root user for API container
- ✅ Fixed healthcheck reliability
- ✅ Enforced stronger TLS version for SCM operations
- ✅ Pinned container image versions for consistency

All changes were tested and verified to work correctly.

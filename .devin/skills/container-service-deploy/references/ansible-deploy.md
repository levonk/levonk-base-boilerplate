# Branch B — Ansible `docker_container` for Production Deployment

## When to Use

- Production deployments
- Multi-host container orchestration
- Infrastructure-as-code with reproducible, version-controlled state
- Environments requiring centralized secrets (Vault) or inventory-driven config

## Golden Rules

- **NEVER** use `docker-compose` (or `docker compose`) inside Ansible playbooks — manage containers with `community.docker.docker_container` directly.
- **NEVER** use systemd units for container management in production — Ansible owns the container lifecycle.
- **NEVER** hardcode ports, IPs, or image tags in tasks — every value must be a variable.

## Pulling Images

Use `community.docker.docker_image` with `source: pull` for pre-built images:

```yaml
---
- name: Pull service image
  community.docker.docker_image:
    name: "{{ service_image_name }}"
    tag: "{{ service_image_tag }}"
    source: pull
```

## Role Structure

- Name roles with **functional-group prefixes** (e.g., `nix_cache_harmonia`, not `harmonia`) so related roles cluster together.
- Defaults live in `defaults/main.yml` — no Jinja fallback logic there.
- Validate required variables at the **start of the playbook** with `ansible.builtin.assert`.

```
roles/
└── nix_cache_harmonia/
    ├── defaults/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    └── templates/
        └── service.conf.j2
```

## Variable Management

- **All ports must be variables** — never hardcode.
- Define group-level variables in `group_vars/{group_name}.yml`.
- Naming convention (mirrors Branch A):

```
{category}_{service}_{sub}_{host|container}_{port}
```

Example: `nix_cache_harmonia_host_port`, `nix_cache_harmonia_container_port`

### Defaults vs. Validation

- Put default values in `defaults/main.yml` — plain values, **no `| default()` fallback**.
- Validate required variables at playbook start:

```yaml
---
- name: Validate required variables
  ansible.builtin.assert:
    that:
      - service_image_name is defined
      - service_host_port is defined
      - service_container_port is defined
    msg: "Required variables for role must be defined."
```

- **Never** use `{{ variable | default('') }}` inside tasks — validate upfront instead.

## Port Collision Detection

Before deploying, check that the host port is free:

```yaml
---
- name: Check host port is available
  ansible.builtin.wait_for:
    port: "{{ service_host_port }}"
    state: stopped
    timeout: 5
  register: port_check

- name: Fail if host port is in use
  ansible.builtin.assert:
    that:
      - port_check.failed
    msg: "Host port {{ service_host_port }} is already in use."
```

## Container Restart Logic

Don't blindly remove/recreate containers. Compare the running container's
configuration against desired state before deciding to redeploy:

```yaml
---
- name: Inspect running container
  community.docker.docker_container_info:
    name: "{{ service_container_name }}"
  register: container_info

- name: Decide whether redeploy is needed
  ansible.builtin.set_fact:
    needs_redeploy: >-
      {{
        container_info.exists and (
          (container_info.container.Config.Image != service_image_name ~ ':' ~ service_image_tag) or
          (container_info.container.HostConfig.PortBindings | default({})) | length != 0
        )
      }}

- name: Recreate container only when needed
  community.docker.docker_container:
    name: "{{ service_container_name }}"
    image: "{{ service_image_name }}:{{ service_image_tag }}"
    # ... full config ...
    recreate: "{{ needs_redeploy }}"
```

## String Conversion for Env Variables

Always apply the `| string` filter to numeric env vars so the container runtime
receives strings, not integers:

```yaml
    env:
      PUID: "{{ puid | string }}"
      PGID: "{{ pgid | string }}"
      PORT: "{{ service_container_port | string }}"
```

## Security Hardening

```yaml
---
- name: Deploy hardened container
  community.docker.docker_container:
    name: "{{ service_container_name }}"
    image: "{{ service_image_name }}:{{ service_image_tag }}"
    cap_drop:
      - ALL
    security_opts:
      - no-new-privileges:true
    # Add capabilities only when the service requires them:
    # cap_add:
    #   - NET_ADMIN
    #   - NET_RAW
    networks:
      - name: "{{ service_network_name }}"
    # ...
```

- `cap_drop: - ALL` is the baseline; add capabilities **only** when the service needs them (e.g., `NET_ADMIN`, `NET_RAW` for VPN services).
- `security_opts: - no-new-privileges:true` always.
- Never mount `docker.sock`.
- Use defined custom networks; no host networking.

## Vault Integration

- Vault files follow the naming convention `group_name.vault.yml` inside `group_vars/`.
- Access vault variables with a safe fallback at the point of use:

```yaml
some_secret: "{{ vault_service_api_key | default('') }}"
```

- **Do not** put vault fallbacks in `defaults/main.yml` — keep defaults vault-free.

## Avoiding Deprecation Warnings

Use the dict-style `ansible_facts` access instead of the shorthand:

```yaml
# ✅ Good
ansible_facts['distribution']

# ❌ Avoid (deprecated)
ansible_distribution
```

## Example Task Structure

```yaml
---
# tasks/main.yml — role: nix_cache_harmonia

- name: Validate required variables
  ansible.builtin.assert:
    that:
      - service_image_name is defined
      - service_image_tag is defined
      - service_host_port is defined
      - service_container_port is defined
      - service_network_name is defined
    msg: "Required variables for nix_cache_harmonia must be defined."

- name: Check host port is available
  ansible.builtin.wait_for:
    port: "{{ service_host_port }}"
    state: stopped
    timeout: 5
  register: port_check

- name: Fail if host port is in use
  ansible.builtin.assert:
    that:
      - port_check.failed
    msg: "Host port {{ service_host_port }} is already in use."

- name: Pull service image
  community.docker.docker_image:
    name: "{{ service_image_name }}"
    tag: "{{ service_image_tag }}"
    source: pull

- name: Deploy container
  community.docker.docker_container:
    name: "{{ service_container_name }}"
    image: "{{ service_image_name }}:{{ service_image_tag }}"
    restart_policy: unless-stopped
    published_ports:
      - "{{ service_host_port }}:{{ service_container_port }}"
    env:
      PUID: "{{ puid | string }}"
      PGID: "{{ pgid | string }}"
      TZ: "{{ tz | default('UTC') }}"
    cap_drop:
      - ALL
    security_opts:
      - no-new-privileges:true
    networks:
      - name: "{{ service_network_name }}"
    healthcheck:
      test: ["CMD", "sh", "/healthcheck/healthcheck-internal-service.sh"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

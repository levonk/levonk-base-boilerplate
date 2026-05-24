# Ansible Boilerplate (Copier)

Scaffolds an Ansible automation project with inventory, playbooks, and roles.

## Usage

```bash
copier copy ./boilerplate/apps/infrastructure/ansible ./out/my-ansible
```

## Generated Structure

```
my-ansible-project/
  ansible.cfg
  inventory/
    production.yml
    staging.yml
  playbooks/
    site.yml
  roles/
    common/
```

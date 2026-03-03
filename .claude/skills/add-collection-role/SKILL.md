---
name: add-collection-role
description: Add a new role to the xavs.images Ansible collection
user_invocable: true
---

# Add Collection Role

Add a new role to the `xavs.images` collection for host preparation tasks.

## Before You Start

- `!cat galaxy.yml`
- `!ls roles/`
- `!cat roles/apparmor_libvirt/tasks/main.yml`

## Existing Roles

| Role | Purpose |
|------|---------|
| `baremetal` | Orchestrator — calls all other roles in sequence |
| `docker` | Install/configure Docker CE + containerd |
| `docker_sdk` | Docker SDK for Python |
| `podman` | Install/configure Podman |
| `podman_sdk` | Podman SDK for Python |
| `packages` | System package install/removal |
| `xavs_user` | Create kolla/xavs user with SSH + sudo |
| `etc_hosts` | Manage /etc/hosts entries |
| `apparmor_libvirt` | Remove libvirt AppArmor profile (Ubuntu) |

## Step-by-Step

### 1. Create Role Directory

```bash
mkdir -p roles/<role_name>/{defaults,tasks,templates,handlers}
```

### 2. Create `defaults/main.yml`

```yaml
---
<role_name>_enabled: true
# Add role-specific variables here
```

### 3. Create `tasks/main.yml`

Simple role (single task file):
```yaml
---
- include_tasks: "setup.yml"
  when: <role_name>_enabled | bool
```

Action-dispatching role (like baremetal):
```yaml
---
- include_tasks: "{{ kolla_action }}.yml"
```

### 4. Create Task Files

```yaml
# tasks/setup.yml
---
- name: Install required packages
  package:
    name: "{{ item }}"
    state: present
  loop: "{{ <role_name>_packages }}"
  become: true
```

### 5. Wire into Baremetal Orchestrator

If this role should run during host preparation, add it to `roles/baremetal/tasks/deploy.yml`:

```yaml
- name: Run <role_name> role
  import_role:
    name: <role_name>
  when: <role_name>_enabled | bool
```

**Execution order in baremetal:**
1. etc_hosts
2. pre-install (packages)
3. packages
4. docker or podman
5. docker_sdk or podman_sdk
6. xavs_user
7. apparmor_libvirt
8. **your new role** (add at appropriate position)

### 6. Usage from xavs-ansible

The collection is invoked by xavs-ansible:

```yaml
# In xavs-ansible/ansible/xavs-host.yml
- import_role:
    name: xavs.images.baremetal
```

Variables flow from xavs-ansible's `group_vars/all.yml` into collection roles.

## Common Gotchas

1. **Namespace prefix** — When used from xavs-ansible, roles are referenced as `xavs.images.<role_name>`
2. **`galaxy.yml`** — Rebuild collection after adding roles: `ansible-galaxy collection build --force`
3. **Baremetal execution order** — The baremetal role is the orchestrator. Adding a role to the collection doesn't automatically include it in the deploy sequence
4. **Variable scope** — Collection roles inherit variables from the calling playbook (xavs-ansible's group_vars)

# CLAUDE.md — xavs-ansible-collection

## What This Is

Ansible collection (`xavs.images`) providing 11 roles for preparing Linux hosts for containerized OpenStack deployment. Fork of `openstack/ansible-collection-kolla` with XAVS branding and customizations. Consumed by the `xavs-ansible` repo.

**Collection namespace**: `xavs.images` (version 1.0.0)

## Architecture & Dependencies

### Versions
- **Collection**: `xavs.images` v1.0.0
- **Ansible**: ansible-core >=2.16 (tested), parent requires >=2.17,<2.19
- **Python**: >=3.6 (setup.cfg), tested 3.7–3.9
- **Docker SDK**: docker >=7.0.0
- **Podman SDK**: podman >=4.7.0
- **Ceph**: quincy release (for Zun)
- **License**: GPL-3.0-or-later

### Platform Support
- Ubuntu 22.04/24.04 (x86_64, ARM64)
- Debian Bookworm (x86_64, ARM64)
- Rocky Linux 9 (x86_64)
- Docker CE (repo default, not version-pinned) + containerd
- Podman (system repo default)

### Docker daemon.json Composition Order
1. Default: `{log-opts: {max-file: 5, max-size: 50m}}`
2. `+ Zun config` (if enabled)
3. `+ insecure registries` (if docker_registry_insecure)
4. `+ registry mirrors` (if configured)
5. `+ storage driver` (if specified)
6. `+ iptables: false` (default — docker_disable_default_iptables_rules)
7. `+ bridge: none` (default — docker_disable_default_network)
8. `+ ip-forward: false` (default)
9. `+ ulimits` (EL9 only — nofile 1048576)
10. `+ debug` (if enabled)
11. `+ docker_custom_config` (user overrides, final)

### Role Execution Sequence (baremetal orchestrator)
1. `xavs.images.etc_hosts` → setup /etc/hosts
2. `pre-install.yml` → sysctl, firewall disable, SELinux
3. `xavs.images.packages` → install/remove system packages
4. `xavs.images.{{ container_engine }}` → docker or podman
5. `xavs.images.xavs_user` → kolla user + SSH + sudo (if enabled)
6. `xavs.images.{{ container_engine }}_sdk` → Python bindings
7. `xavs.images.apparmor_libvirt` → remove AppArmor profile (Ubuntu)
8. `configure-ceph-for-zun.yml` → Ceph client (conditional)

### Variable Flow from xavs-ansible
```
xavs-ansible/group_vars/all.yml
  ├── container_engine: "docker"
  ├── docker_namespace: "xavs.images"
  ├── offline_mode: false
  ├── create_kolla_user: false
  └── node_config_directory: "/etc/xavs"
       ↓
xavs-ansible/xavs-host.yml
  └── import_role: xavs.images.baremetal
       ↓
This collection's roles (use above vars as defaults)
```

## Repository Layout

```
roles/
├── baremetal/                # Orchestrator — calls other roles in sequence
├── docker/                   # Install/configure Docker CE + containerd
├── docker_sdk/               # Docker SDK for Python (python-docker)
├── podman/                   # Install/configure Podman
├── podman_sdk/               # Podman SDK for Python
├── packages/                 # System package install/removal
├── xavs_user/                # Create kolla/xavs user with SSH + sudo
├── etc_hosts/                # Manage /etc/hosts entries
└── apparmor_libvirt/         # Remove libvirt AppArmor profile (Ubuntu)

galaxy.yml                    # Collection metadata
setup.cfg                     # Python packaging
tox.ini                       # Test environments
tools/run-ansible-sanity.sh   # Collection build + ansible-test wrapper
zuul.d/                       # OpenStack CI/CD (Zuul) config
```

## How It's Used

`xavs-ansible` imports the `baremetal` role to prepare hosts:
```yaml
# In xavs-ansible/ansible/xavs-host.yml
- import_role:
    name: xavs.images.baremetal
```

The `baremetal` role orchestrates: `packages` → `docker`/`podman` → `docker_sdk`/`podman_sdk` → `xavs_user` → `etc_hosts` → `apparmor_libvirt`

## Key Variables

```yaml
container_engine: "docker"     # or "podman"
offline_mode: false            # Skip all network operations
create_kolla_user: false       # Create kolla user with Docker access
docker_namespace: "xavs.images"
node_config_directory: "/etc/xavs"
```

## Build / Test

```bash
# Build collection
ansible-galaxy collection build --force
# Produces: xavs-images-1.0.0.tar.gz

# Install
ansible-galaxy collection install xavs-images-1.0.0.tar.gz

# Test
tox -e py3              # Unit tests
tox -e linters          # All linters (flake8, ansible-lint, bandit, doc8)
tox -e ansible-sanity   # ansible-test sanity checks
tox -e ansible-lint     # Ansible-specific linting
```

## Task Recipes

### Add a New Role

1. **Create role directory** — `roles/<role_name>/`:
   ```
   roles/<role_name>/
   ├── defaults/main.yml     # Variables with defaults
   ├── tasks/
   │   ├── main.yml          # Entry point
   │   ├── install.yml       # Package installation
   │   ├── config.yml        # Configuration
   │   └── uninstall.yml     # Removal tasks
   ├── handlers/main.yml     # Restart/reload handlers
   └── templates/            # Jinja2 templates
   ```
2. **Add to baremetal orchestrator** — Edit `roles/baremetal/tasks/install.yml`:
   ```yaml
   - import_role:
       name: xavs.images.<role_name>
     when: <condition>
   ```
3. **Handle offline mode** — Wrap network-dependent tasks:
   ```yaml
   - name: Install packages
     apt: name={{ item }}
     loop: "{{ packages }}"
     when: not offline_mode | bool
   ```
4. **Update galaxy.yml** if role adds new dependencies
5. **Test**: Build and install collection, run against test host

### Add a Docker Configuration Option

1. **Add variable** to `roles/docker/defaults/main.yml`:
   ```yaml
   docker_my_option: false
   ```
2. **Add to daemon.json assembly** in `roles/docker/tasks/config.yml`:
   ```yaml
   - name: Merge my option into Docker config
     set_fact:
       docker_config: "{{ docker_config | combine({'my-option': docker_my_option}) }}"
     when: docker_my_option | bool
   ```
3. The merge follows the composition order documented above (step 1–11)
4. Place new option at appropriate priority (before `docker_custom_config` which is always last)

### Build and Publish the Collection

1. **Update version** in `galaxy.yml`: `version: X.Y.Z`
2. **Build**: `ansible-galaxy collection build --force` → produces `xavs-images-X.Y.Z.tar.gz`
3. **Test locally**: `ansible-galaxy collection install xavs-images-X.Y.Z.tar.gz --force`
4. **Lint**: `tox -e linters && tox -e ansible-sanity`
5. **Install in xavs-ansible**: Update `requirements-core.yml` with new version or path

### Add Platform Support

1. **Add OS detection** — Use `ansible_facts.os_family` and `ansible_facts.distribution`:
   ```yaml
   - name: Install for new platform
     include_tasks: "install-{{ ansible_facts.os_family | lower }}.yml"
   ```
2. **Create platform-specific task file** — `tasks/install-<family>.yml`
3. **Add to CI** — Update `zuul.d/` job definitions for new platform
4. **Update galaxy.yml** `platforms` list

## Critical Gotchas

1. **Container engine selection** — `container_engine` variable switches between docker/podman. Role imports are dynamic: `xavs.images.{{ container_engine }}_sdk`.

2. **Offline mode** — Set `offline_mode: true` to skip repo setup, package install, pip install. All packages must be pre-staged.

3. **Python 3.10+ externally-managed** — SDK roles detect `EXTERNALLY-MANAGED` marker and use system packages instead of pip. Falls back to OSBPO apt repo on Debian.

4. **Uninstall safety** — Docker/Podman uninstall asserts NO running containers or volumes exist first. Will fail if containers are running.

5. **DEB822 format** — Docker apt repo uses new DEB822 format (not legacy sources.list). Written to `/etc/apt/sources.list.d/docker.sources`.

6. **SSH key required** — `xavs_user` role needs `kolla_ssh_key.public_key` from parent playbook. Missing = failure.

7. **etc_hosts cloud-init** — Disables cloud-init's `manage_etc_hosts` to prevent RabbitMQ hostname resolution issues.

## Branch Workflow

- **Stable**: `stable/2025.1`
- **Development**: `claude-ankit`

## Related Repos

- `xavs-ansible` — Main deployment playbook (consumes this collection)
- Upstream: `openstack/ansible-collection-kolla`

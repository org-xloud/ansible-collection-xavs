---
name: build-and-install
description: Build and install the xavs.images Ansible collection
user_invocable: true
---

# Build and Install Collection

## Build

```bash
cd /root/xavs-ansible-collection

# Build the collection tarball
ansible-galaxy collection build --force
# Output: xavs-images-1.0.0.tar.gz
```

## Install Locally

```bash
# Install from tarball
ansible-galaxy collection install xavs-images-1.0.0.tar.gz --force

# Installs to: ~/.ansible/collections/ansible_collections/xavs/images/
```

## Install via Requirements

```yaml
# requirements.yml
collections:
  - name: xavs.images
    version: 1.0.0
    source: file:///root/xavs-ansible-collection/xavs-images-1.0.0.tar.gz
```

```bash
ansible-galaxy collection install -r requirements.yml
```

## Run Tests

```bash
# Sanity tests
./tools/run-ansible-sanity.sh

# Lint
ansible-lint roles/

# Unit tests
tox -e py3
```

## Version Bump

Edit `galaxy.yml`:

```yaml
version: 1.0.1  # Bump this
```

Then rebuild: `ansible-galaxy collection build --force`

## Common Gotchas

1. **`--force`** — Required to overwrite existing build artifact
2. **`build_ignore` in galaxy.yml** — Files listed there are excluded from the tarball
3. **Version must increase** — Can't install same version over existing without `--force`
4. **Collection path** — Default install to `~/.ansible/collections/`. Check `ansible --version` for paths

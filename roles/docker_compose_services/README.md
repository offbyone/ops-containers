# Docker Compose Services Ansible Role

This Ansible role manages Docker Compose services from a centralized Git repository. It:

1. Clones or updates a Git repository containing Docker Compose definitions
2. Deploys specified services using Docker Compose v2
3. Ensures services are healthy

## Requirements

- Ansible 2.10+
- Docker and Docker Compose Plugin installed on target hosts
- Community Docker collection: `ansible-galaxy collection install community.docker`

## Role Variables

See `defaults/main.yml` for all variables.

Key variables:

```yaml
# Repository settings
repo_path: "/opt/ansible-docker-compose/ops-containers"
repo_url: "https://github.com/offbyone/ops-containers.git"
repo_branch: "main"

# GitHub PAT (optional)
use_github_pat: false
github_pat_vault_var: "github_pat"

# Services configuration
services: []  # Define this in host_vars
```

## Host Variables

Define services per host in `host_vars/<hostname>.yml`:

```yaml
services:
  - name: radarr
    compose_file: docker-compose.yml
    health_check_url: "http://localhost:7878"
    env:
      PUID: "1000"
      PGID: "1000"
```

## Example Playbook

```yaml
- name: Deploy Docker Compose Services
  hosts: docker_hosts
  roles:
    - role: docker_compose_services
```

## Usage

1. Clone this role into your Ansible roles directory
2. Configure host variables defining required services
3. Run the playbook with:
   ```
   ansible-playbook -i inventory deploy-services.yml
   ```

## License

MIT

## Author Information

Your Name

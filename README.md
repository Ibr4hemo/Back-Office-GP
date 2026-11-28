# Intelligent Traffic Management Dashboard 
[![CI](https://github.com/Ibr4hemo/Back-Office-GP/actions/workflows/CI.yaml/badge.svg)](https://github.com/Ibr4hemo/Back-Office-GP/actions/workflows/CI.yaml)
> Project for Digital Egypt Pioneers Initiative (DEPI)

* Instructor: Eng. Mohamed Rahim
* Group: GIZ5_SWD1_S1

## Problem Addressed:

Cities struggle to monitor traffic congestion and provide insights for traffic control.

## Description:

Develop a traffic monitoring system that collects simulated traffic data from IoT sensors or CSV logs and displays it in real-time dashboards. Automate deployment, scaling, and monitoring with DevOps tools. Students focus on data collection, automation, CI/CD, containerization, and monitoring, without AI prediction.

## Deliverables:

- Traffic data collection service (CSV or simulated sensor inputs, Dockerized)
- Web dashboard showing congestion, peak times, and alerts
- CI/CD pipeline for service updates (GitHub Actions)
- Docker containers for services
- Kubernetes deployment for scalability
- Prometheus dashboards and alerts for system metrics
- Terraform scripts for AWS infrastructure
- Ansible scripts for server setup and configuration (maybe)
- Git repository for code and deployment scripts

### Team

| Name | Role | GitHub |
|:------:|:------:|:--------:|
| Ibrahim Ahmed | TBD | [@ibr4hemo](https://github.com/Ibr4hemo) |
| youssef elageal | TBD | [@youssefos4ma](https://github.com/youssefos4ma) |
| Ahmed Bahaa Mazen | TBD | [@Ahmed-Mazen](https://github.com/Ahmed-Mazen) |
| Ahmed ELwakeel | TBD | [@ahmedelwakeel8](https://github.com/ahmedelwakeel8) |
| Mohamed Tamer | TBD | [@Mohamed393652](https://github.com/Mohamed393652) |

### Project Overview

_To be decided. This section will describe the problem we are solving and the solution._

### Tech Stack

- **Version control**: Git, GitHub
- **CI/CD**: GitHub Actions
- **Containers**: Docker, Kubernetes
- **IaC and configuration**: Terraform, Ansible(maybe)
- **Cloud**: AWS
- **Monitoring**: Prometheus, Grafana

### Repository Structure

```bash
.
├── backend
│   └── dockerfile
├── database
│   └── dockerfile
├── frontend
│   └── dockerfile
├── kubernetes
│   ├── deployment.yaml
│   ├── namespace.yaml
│   └── service.yaml
├── monitoring
│   └── dockerfile
├── terraform
│   ├── main.tf
│   ├── vm.tf
│   └── vpc.tf
└── .github
    └── workflows
        └── CI.yaml
```

### CI/CD

CI runs on GitHub Actions ([`.github/workflows/CI.yaml`](.github/workflows/CI.yaml)) for every pull request to `main` and every push to `main`.

| Job | What it checks |
|:----|:---------------|
| Terraform | `terraform fmt -check`, `terraform validate`, `tflint` |
| Kubernetes manifests | `kubeconform` schema validation of `kubernetes/` |
| Backend (Python) | Installs `requirements.txt`, lints with `ruff` (syntax errors and undefined names), runs the Alembic migrations against a throwaway Postgres 16, then starts the app and checks that `/api/events` answers |
| Docker (backend / frontend / database / monitoring) | Builds each image. On `main` it also pushes to GHCR as `ghcr.io/ibr4hemo/back-office-gp/<service>:sha-<commit>` and `:latest`. A service is skipped until its `Dockerfile` has a `FROM` line. |
| CI passed | Summary check that fails if any job above failed. Branch protection requires it. |

Before pushing Terraform changes, run `terraform fmt -recursive` inside `terraform/` so the format check passes.

CD (deploying new images to the k3s cluster) will be added once the services and Kubernetes manifests exist.

### Getting Started

_Setup instructions will be added once we have something to run._

### Roadmap

- [x] Decide on the project idea
- [x] Define architecture
- [x] Set up repo workflow (branches, PR rules)
- [ ] Build CI/CD pipeline
- [ ] Containerize and deploy
- [ ] Add monitoring
- [ ] Final documentation and presentation

### Contributing

- Create a branch per task: `feature/<short-name>`
- Open a pull request; at least one teammate reviews before merging
- The `CI passed` check must be green before merging
- Never commit directly to `main` (`main` is protected, so direct pushes are rejected)

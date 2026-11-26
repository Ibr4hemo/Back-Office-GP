# Intelligent Traffic Management Dashboard 
> Project for Digital Egypt Pioneers Initiative (DEPI)

Instructor: Eng. Mohamed Rahim
Group: GIZ5_SWD1_S1

## Problem Addressed:

Cities struggle to monitor traffic congestion and provide insights for traffic control.

## Description:

Develop a traffic monitoring system that collects simulated traffic data from IoT sensors or CSV logs and displays it in real-time dashboards. Automate deployment, scaling, and monitoring with DevOps tools. Students focus on data collection, automation, CI/CD, containerization, and monitoring, without AI prediction.

## Deliverables:

- Traffic data collection service (CSV or simulated sensor inputs, Dockerized)
- Web dashboard showing congestion, peak times, and alerts
- CI/CD pipeline for service updates (Jenkins)
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
- Never commit directly to `main`

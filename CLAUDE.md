# MCP PostgreSQL Toolkit

> Production-ready deployment templates for Google's MCP Toolbox for Databases.

## Purpose

Provides K8s, Docker Compose, and Helm deployment recipes that give AI agents secure PostgreSQL access via the Model Context Protocol. Replaces the deprecated `@modelcontextprotocol/server-postgres` (SQL injection vulnerability) with Google's parameterized-query-based toolbox.

## Tech Stack

| Layer | Technology |
|-------|------------|
| MCP Server | Google MCP Toolbox for Databases (Go binary) |
| Container | Docker (wraps Google's image with tools.yaml) |
| Orchestration | Kubernetes manifests + Helm chart |
| Local dev | Docker Compose (Postgres 17 + Toolbox) |
| CI/CD | GitHub Actions → GHCR image |
| Registry | MCP Registry (`mcp-publisher`) + Docker MCP Catalog |
| License | Apache 2.0 (IntelMedica.ai) |

## Directory Structure

```
mcp-postgres-toolkit/
├── Dockerfile                  # Wraps Google toolbox image
├── docker-compose.yml          # Local dev: Postgres + Toolbox
├── tools.yaml                  # MCP tool definitions (3 default tools)
├── server.json                 # MCP Registry metadata
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml
│   ├── secret.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── helm/                       # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
└── .github/workflows/
    └── docker-publish.yml      # Build + push to GHCR on tag
```

## Key Files

- `tools.yaml` — Defines MCP tools: `list-tables`, `describe-table`, `run-query`
- `k8s/deployment.yaml` — K8s deployment with secret env injection
- `helm/values.yaml` — All configurable Helm values
- `server.json` — MCP Registry publish metadata

## Commands

```bash
# Local dev
cp .env.example .env && docker compose up -d

# Kubernetes
kubectl apply -f k8s/

# Helm
helm install mcp-db ./helm --set postgres.host=your-host --set postgres.password=your-pass

# Test
curl -X POST http://localhost:5000/mcp -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

## Security

- All credentials injected via env vars / K8s secrets — never hardcoded
- Parameterized queries only — SQL injection structurally impossible
- No real IPs, passwords, or hostnames in any file

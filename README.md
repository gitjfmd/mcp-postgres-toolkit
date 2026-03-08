# mcp-postgres-toolkit

**Production-ready deployment templates for MCP Toolbox for Databases**

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MCP Protocol](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-green.svg)](https://modelcontextprotocol.io)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)](https://kubernetes.io/)

---

Deploy [Google's MCP Toolbox for Databases](https://github.com/googleapis/genai-toolbox) on **Docker Compose**, **Kubernetes**, or **Helm** in minutes. Give your AI agents secure, parameterized PostgreSQL access via the [Model Context Protocol](https://modelcontextprotocol.io).

## Why This Exists

The deprecated `@modelcontextprotocol/server-postgres` passed raw SQL strings from LLMs directly to the database -- a textbook SQL injection vulnerability. Google's **MCP Toolbox for Databases** solves this by design:

- **Parameterized queries only** -- SQL injection is structurally impossible
- **Pre-defined tools** -- agents pick from a curated set of operations, not arbitrary SQL
- **Connection pooling** -- built-in pooling with health checks and automatic reconnection
- **Multi-database support** -- PostgreSQL, MySQL, Cloud SQL, AlloyDB, Spanner, and more
- **Authentication** -- supports IAM-based auth for Google Cloud databases

This repository provides the deployment scaffolding so you can go from zero to a running MCP database server with a single command.

## Quick Start

### Option 1: Docker Compose (Simplest)

```bash
git clone https://github.com/gitjfmd/mcp-postgres-toolkit.git
cd mcp-postgres-toolkit

# Configure your database credentials
cp .env.example .env
# Edit .env with your actual values

# Start everything
docker compose up -d
```

The MCP Toolbox server will be available at `http://localhost:5000`.

### Option 2: Kubernetes

```bash
# Create the namespace and resources
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml      # Edit with your base64-encoded credentials first
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Verify
kubectl get pods -n mcp-db
```

### Option 3: Helm

```bash
helm install mcp-toolbox ./helm \
  --set postgres.host=your-postgres-host \
  --set postgres.user=your-user \
  --set postgres.password=your-password \
  --set postgres.database=your-database
```

## Architecture

```
┌─────────────────┐     MCP Protocol      ┌──────────────────┐
│   AI Agent      │ ──────────────────────>│  MCP Toolbox     │
│  (Claude, etc.) │                        │  for Databases   │
└─────────────────┘                        └────────┬─────────┘
                                                    │
                                           Parameterized Queries
                                                    │
                                           ┌────────▼─────────┐
                                           │   PostgreSQL     │
                                           │   (or MySQL,     │
                                           │    Cloud SQL,    │
                                           │    AlloyDB, ...) │
                                           └──────────────────┘
```

## Default Tools

The included `tools.yaml` defines three tools that cover common database exploration tasks:

| Tool | Description | Parameters |
|------|-------------|------------|
| `list-tables` | Lists all tables in the public schema | None |
| `describe-table` | Shows column details for a specific table | `table_name` |
| `run-query` | Executes a parameterized read-only SELECT query | `query` |

### tools.yaml Reference

```yaml
sources:
  my-pg-source:
    kind: postgres
    host: ${DB_HOST}
    port: 5432
    database: ${DB_NAME}
    user: ${DB_USER}
    password: ${DB_PASSWORD}

tools:
  list-tables:
    kind: postgres-sql
    source: my-pg-source
    description: "List all tables in the public schema."
    statement: |
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name;

  describe-table:
    kind: postgres-sql
    source: my-pg-source
    description: "Describe the columns of a specific table."
    parameters:
      - name: table_name
        type: string
        description: "Name of the table to describe."
    statement: |
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'public' AND table_name = $1
      ORDER BY ordinal_position;

  run-query:
    kind: postgres-sql
    source: my-pg-source
    description: "Execute a read-only SQL query."
    parameters:
      - name: query
        type: string
        description: "The SELECT query to execute."
    statement: "SELECT * FROM ($1) AS subquery LIMIT 100;"

toolsets:
  default:
    - list-tables
    - describe-table
    - run-query
```

## Adding Custom Tools

Add new tools to `tools.yaml` following the same pattern:

```yaml
tools:
  # ... existing tools ...

  count-rows:
    kind: postgres-sql
    source: my-pg-source
    description: "Count rows in a specific table."
    parameters:
      - name: table_name
        type: string
        description: "Name of the table."
    statement: |
      SELECT COUNT(*) AS row_count
      FROM information_schema.tables t
      WHERE t.table_schema = 'public' AND t.table_name = $1;
```

After editing, restart the toolbox container or pod to pick up changes.

## Supported Databases

MCP Toolbox for Databases supports multiple database backends. Change the `kind` and connection parameters in `tools.yaml`:

| Database | `kind` | Notes |
|----------|--------|-------|
| PostgreSQL | `postgres` | Any standard PostgreSQL instance |
| MySQL | `mysql` | MySQL 5.7+ / 8.x |
| Cloud SQL (PostgreSQL) | `cloud-sql-postgres` | Google Cloud SQL with IAM auth |
| Cloud SQL (MySQL) | `cloud-sql-mysql` | Google Cloud SQL with IAM auth |
| AlloyDB | `alloydb` | Google AlloyDB with IAM auth |
| Spanner | `spanner` | Google Cloud Spanner |

See the [MCP Toolbox documentation](https://github.com/googleapis/genai-toolbox) for full configuration options.

## MCP Client Configuration

### Claude Code (`.mcp.json`)

```json
{
  "mcpServers": {
    "postgres-toolkit": {
      "type": "http",
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

### Cursor (`.cursor/mcp.json`)

```json
{
  "mcpServers": {
    "postgres-toolkit": {
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

### Claude Desktop (`claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "postgres-toolkit": {
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

### Generic MCP Client

Point any MCP-compatible client to: `http://localhost:5000/mcp`

The toolbox exposes an HTTP-based MCP endpoint (Streamable HTTP transport).

## Project Structure

```
mcp-postgres-toolkit/
├── LICENSE                  # Apache 2.0 (IntelMedica.ai)
├── README.md                # This file
├── CONTRIBUTING.md          # Contribution guide
├── Dockerfile               # Custom image wrapping Google's toolbox
├── docker-compose.yml       # Docker Compose deployment
├── tools.yaml               # MCP tool definitions
├── server.json              # MCP Registry metadata
├── .env.example             # Environment variable template
├── .gitignore
├── .dockerignore
├── k8s/                     # Kubernetes manifests
│   ├── namespace.yaml
│   ├── secret.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── helm/                    # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── configmap.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── secret.yaml
└── .github/
    └── workflows/
        └── docker-publish.yml
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Credits

This project builds on top of [Google's MCP Toolbox for Databases](https://github.com/googleapis/genai-toolbox) (`googleapis/genai-toolbox`), which provides the core MCP server implementation with parameterized query support. This repository contributes deployment templates, Kubernetes manifests, Helm charts, and documentation -- it does not modify the upstream toolbox code.

## License

Copyright 2026 [IntelMedica.ai](https://intelmedica.ai)

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.

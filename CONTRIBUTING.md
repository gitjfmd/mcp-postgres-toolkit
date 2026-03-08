# Contributing to mcp-postgres-toolkit

Thank you for your interest in contributing. This project provides deployment templates for Google's MCP Toolbox for Databases.

## How to Contribute

### 1. Fork and Clone

```bash
git clone https://github.com/your-username/mcp-postgres-toolkit.git
cd mcp-postgres-toolkit
```

### 2. Make Your Changes

Common contributions include:

- **New tools** -- Add tool definitions to `tools.yaml` for common database operations
- **New database sources** -- Add configuration examples for MySQL, Cloud SQL, AlloyDB, etc.
- **Helm improvements** -- Additional values, hooks, or templates
- **Kubernetes enhancements** -- Ingress, NetworkPolicy, HPA, PodDisruptionBudget
- **Documentation** -- Clearer instructions, more examples, troubleshooting guides

### 3. Test with Docker Compose

Before submitting, verify your changes work:

```bash
cp .env.example .env
# Edit .env with test credentials

docker compose up -d
# Verify the toolbox starts and connects to PostgreSQL
curl http://localhost:5000/health
docker compose down
```

### 4. Submit a Pull Request

- Open a PR against the `main` branch
- Describe what you changed and why
- Include any testing steps specific to your change

## Guidelines

- **No credentials** -- Never commit real passwords, IPs, or tokens. Use placeholders.
- **Keep it simple** -- These are templates. Prefer clarity over cleverness.
- **Apache 2.0** -- All contributions are licensed under Apache 2.0.

## Reporting Issues

Open an issue on GitHub with:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Your environment (OS, Docker version, Kubernetes version)

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

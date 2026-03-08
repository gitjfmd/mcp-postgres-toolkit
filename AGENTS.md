# MCP PostgreSQL Toolkit — Agent Definitions

> All agent instructions reference `CLAUDE.md` for project context.

## Agent Types

| Agent | CLI | Use For |
|-------|-----|---------|
| **Infra Dev** | Claude / Codex | K8s manifests, Helm chart, Dockerfile changes |
| **Docs Writer** | Gemini | README, CONTRIBUTING, usage guides |
| **Security Auditor** | Codex | Credential scanning, dependency audit, CVE checks |
| **Release Manager** | Claude | Version tags, GHCR publishing, MCP Registry submission |

## Orchestration Rules

1. All agents follow `CLAUDE.md` for project structure
2. No real credentials in any file — placeholders only
3. Security auditor runs on every change before merge
4. Gemini handles all research and doc tasks (FREE tier)

## Agent Files

Agent-specific instructions can be placed in component directories:
- `k8s/agents.md` — K8s manifest conventions
- `helm/agents.md` — Helm chart conventions

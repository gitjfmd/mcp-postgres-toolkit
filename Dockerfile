# Copyright 2026 IntelMedica.ai
# Licensed under the Apache License, Version 2.0
#
# Wraps Google's MCP Toolbox for Databases with a default tools.yaml.
# Build:  docker build -t mcp-postgres-toolkit .
# Run:    docker run -p 5000:5000 --env-file .env mcp-postgres-toolkit

FROM us-central1-docker.pkg.dev/database-toolbox/toolbox/toolbox:latest

COPY tools.yaml /app/tools.yaml

CMD ["--tools-file", "/app/tools.yaml", "--address", "0.0.0.0"]

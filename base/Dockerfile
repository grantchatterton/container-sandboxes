# syntax=docker/dockerfile:1
# Shared base. sbx prepends this file to sandboxes/<name>/Dockerfile and builds
# the combined file, so every sandbox can use `FROM base`. Stage names defined
# here (bun, base) are reserved.

# Default runtime versions; sbx overrides them with the host's versions when
# node or bun is installed.
ARG NODE_VERSION=24.22.1
ARG BUN_VERSION=1.4.4

# ---------------------------------------------------------------------------
# Bun binary source
# ---------------------------------------------------------------------------
FROM docker.io/oven/bun:${BUN_VERSION}-slim AS bun

# ---------------------------------------------------------------------------
# Base
# ---------------------------------------------------------------------------
FROM docker.io/library/node:${NODE_VERSION}-trixie-slim AS base

# Install shared command-line tools.
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates fd-find git jq python3 ripgrep shellcheck shfmt \
  && rm -rf /var/lib/apt/lists/*

# Add Bun, with bunx as a symlink to it.
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
RUN ln -sf bun /usr/local/bin/bunx

# Run as the non-root node user; sbx overrides the workdir with the project path.
WORKDIR /workspace
USER node

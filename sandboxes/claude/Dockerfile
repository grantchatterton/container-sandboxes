# Claude Code. Appended to base/Dockerfile; the last stage is the image.

# ---------------------------------------------------------------------------
# Installer
# ---------------------------------------------------------------------------
FROM docker.io/library/debian:trixie-slim AS claude-installer

# Install what the installer script needs.
RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# `sbx update` changes CACHE_BUST, so everything below reruns.
ARG CACHE_BUST=1

# Run the official installer and copy the binary to a fixed path.
RUN curl -fsSL https://claude.ai/install.sh | bash \
  && install -D -m 755 /root/.local/bin/claude /out/claude

# ---------------------------------------------------------------------------
# Image
# ---------------------------------------------------------------------------
FROM base AS claude

# Copy in only the installed binary.
COPY --from=claude-installer /out/claude /usr/local/bin/claude

ENTRYPOINT ["claude"]

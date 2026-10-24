# Cursor Agent. Appended to base/Dockerfile; the last stage is the image.

# ---------------------------------------------------------------------------
# Installer
# ---------------------------------------------------------------------------
FROM installer AS cursor-installer

# `sbx update` changes CACHE_BUST, so everything below reruns.
ARG CACHE_BUST=1

# The installer drops a versioned tree (script plus its own Node binary) under
# $HOME and symlinks ~/.local/bin/agent. Copy that tree to a stable path.
RUN curl -fsSL https://cursor.com/install | bash \
  && cp -a "$(dirname -- "$(readlink -f /root/.local/bin/agent)")" /opt/cursor-agent

# ---------------------------------------------------------------------------
# Image
# ---------------------------------------------------------------------------
FROM base AS cursor

# Copy in the installed tree.
COPY --from=cursor-installer /opt/cursor-agent /opt/cursor-agent

# Expose it as both `agent` and `cursor-agent` (linking into /usr/local/bin
# needs root).
RUN ln -sf /opt/cursor-agent/cursor-agent /usr/local/bin/agent \
  && ln -sf /opt/cursor-agent/cursor-agent /usr/local/bin/cursor-agent

ENTRYPOINT ["agent"]

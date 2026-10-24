# Pi. Appended to base/Dockerfile; the last stage is the image.

FROM base AS pi

# Global npm installs need root.
USER root

# `sbx update` changes CACHE_BUST, so everything below reruns.
ARG CACHE_BUST=1

# Install Pi without running package install scripts.
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# Drop back to the non-root user.
USER node

ENTRYPOINT ["pi"]

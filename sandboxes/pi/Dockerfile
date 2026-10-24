# Pi. Appended to base/Dockerfile; the last stage is the image.

FROM base AS pi

# `sbx update` changes CACHE_BUST, so everything below reruns.
ARG CACHE_BUST=1

# Install Pi without running package install scripts.
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent

ENTRYPOINT ["pi"]

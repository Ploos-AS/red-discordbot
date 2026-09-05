# syntax=docker/dockerfile:1.7
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim-bookworm AS builder
ARG REDBOT_VERSION
RUN test -n "${REDBOT_VERSION}" \
    && apt-get update && apt-get install -y --no-install-recommends build-essential git libffi-dev libsodium-dev \
    && python -m venv /opt/redbot/venv \
    && /opt/redbot/venv/bin/pip install --no-cache-dir --upgrade pip wheel \
    && /opt/redbot/venv/bin/pip install --no-cache-dir "Red-DiscordBot==${REDBOT_VERSION}" \
    && /opt/redbot/venv/bin/redbot --version \
    && rm -rf /var/lib/apt/lists/*

FROM python:${PYTHON_VERSION}-slim-bookworm
ARG CONTAINER_VERSION=0.1.0
ARG REDBOT_VERSION
LABEL org.opencontainers.image.title="Red-DiscordBot container" \
      org.opencontainers.image.description="Immutable, self-hosted Red-DiscordBot distribution" \
      org.opencontainers.image.source="https://github.com/Ploos-AS/red-discordbot" \
      org.opencontainers.image.documentation="https://github.com/Ploos-AS/red-discordbot#readme" \
      org.opencontainers.image.vendor="Ploos AS" \
      org.opencontainers.image.licenses="MIT AND GPL-3.0-only" \
      org.opencontainers.image.version="${CONTAINER_VERSION}" \
      io.ploos.red-discordbot.upstream.version="${REDBOT_VERSION}" \
      io.ploos.red-discordbot.upstream.source="https://github.com/Cog-Creators/Red-DiscordBot"
RUN test -n "${REDBOT_VERSION}" \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates ffmpeg git openssh-client tini \
    && groupadd --gid 1000 redbot && useradd --uid 1000 --gid redbot --home-dir /data --no-create-home redbot \
    && install -d -o redbot -g redbot /data \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /opt/redbot /opt/redbot
COPY rootfs/ /
RUN chmod 0755 /usr/local/bin/entrypoint /usr/local/bin/healthcheck /usr/local/bin/red-bootstrap
ENV PATH="/opt/redbot/venv/bin:${PATH}" HOME=/data XDG_CONFIG_HOME=/data/.config \
    XDG_DATA_HOME=/data/.local/share INSTANCE_NAME=docker PREFIX=! STORAGE_TYPE=JSON EXTRA_ARGS=
VOLUME ["/data"]
USER 1000:1000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD ["healthcheck"]
ENTRYPOINT ["/usr/bin/tini", "--", "entrypoint"]

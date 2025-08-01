# syntax=docker/dockerfile:1.9
FROM debian:bookworm-slim

# Security-conscious organizations should package/review uv themselves.
COPY --from=ghcr.io/astral-sh/uv:0.7 /uv /bin/uv

RUN uv tool add supervisor
RUN uv tool add vdirsyncer

# Set up directories
RUN mkdir -p /etc/supervisor /etc/vdirsyncer /var/log/supervisor /app

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Optional: copy static config or mount via volume
# COPY vdirsyncer.conf /etc/vdirsyncer/config

CMD ["/bin/uv", "tool", "run", "supervisord", "-c", "/etc/supervisor/supervisord.conf"]

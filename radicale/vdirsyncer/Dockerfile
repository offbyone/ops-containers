FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    supervisor \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -Ls https://astral.sh/uv/install.sh | bash

ENV PATH="/root/.cargo/bin:$PATH"

# Set up directories
RUN mkdir -p /etc/supervisor /etc/vdirsyncer /var/log/supervisor /app

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Optional: copy static config or mount via volume
# COPY vdirsyncer.conf /etc/vdirsyncer/config

WORKDIR /app

# Install vdirsyncer via uv
RUN uv venv && \
    uv pip install vdirsyncer

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

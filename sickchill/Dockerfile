FROM debian:bookworm AS compile-supervisor
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    # python virtualenv construction
    python-is-python3 python3-venv

# prepare the supervisor venv
RUN python -mvenv /app/supervisor && \
    . /app/supervisor/bin/activate && \
    python -mpip install --upgrade pip && \
    python -mpip install supervisor

FROM debian:bookworm as compile-sickchill
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    # python virtualenv construction
    python-is-python3 python3-venv

# prepare the sickchill venv
RUN python -mvenv /app/sickchill

# Sadly, on most platforms this needs to build Rust.
RUN apt-get install -y --no-install-recommends \
    # for rust
    curl ca-certificates
RUN curl https://sh.rustup.rs -sSf | bash -x -s -- -y

# needed to work around https://github.com/rust-lang/cargo/issues/8719
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN apt-get install -y --no-install-recommends \
    # for building in general
    gcc build-essential pkg-config \
    # python sources need these. Mainly sickchill
    python3-dev libffi-dev libxml2-dev libxslt-dev libssl-dev

RUN . /root/.cargo/env && \
    . /app/sickchill/bin/activate && \
    python -mpip install --upgrade pip && \
    python -mpip install sickchill

FROM debian:bookworm-slim AS runtime-image
RUN apt-get update && \
    apt-get -y --no-install-recommends install curl \
        ca-certificates && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
       -o /usr/share/keyrings/tailscale-archive-keyring.gpg && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list \
       -o /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
        tailscale python-is-python3 jq && \
    apt-get purge -y curl \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/tailscale
VOLUME /etc/sickchill
VOLUME /mnt/media

COPY --from=compile-supervisor /app/supervisor /app/supervisor
COPY --from=compile-sickchill  /app/sickchill  /app/sickchill

COPY etc/supervisor /etc/supervisor
COPY etc/supervised /etc/supervised
RUN mkdir -p /etc/supervised/init.d && touch /etc/supervised/init.d/.keep
COPY bin/init.sh /etc/supervised/bin/init.sh
COPY bin/run-in-venv.sh /usr/local/bin/run-in-venv.sh

CMD . /app/supervisor/bin/activate && \
    exec python /app/supervisor/bin/supervisord \
    -c /etc/supervisor/supervisord.conf

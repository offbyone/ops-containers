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
VOLUME /var/lib/sickchill
VOLUME /mnt/media
EXPOSE 8080

COPY --from=compile-sickchill  /app/sickchill  /app/sickchill

# Dependencies last, because I don't need them to set the rest up
RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        ca-certificates \
        python-is-python3 \
        libxslt1.1 libxml2 \
        && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD . /app/sickchill/bin/activate && \
    exec python -m SickChill \
    --datadir=/var/lib/sickchill \
    --config /var/lib/sickchill/config.ini \
    --nolaunch --port 8080

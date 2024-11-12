FROM ubuntu:noble AS compile-sickchill

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # python virtualenv construction \
    python-is-python3 python3-venv \
    # for building in general \
    build-essential pkg-config \
    # for rust \
    curl ca-certificates \
    # python sources need these. Mainly sickchill \
    libffi-dev libxml2-dev libxslt-dev libssl-dev

RUN curl https://sh.rustup.rs -sSf | bash -x -s -- -y

# Security-conscious organizations should package/review uv themselves.
COPY --from=ghcr.io/astral-sh/uv:0.5 /uv /bin/uv

# - Silence uv complaining about not being able to use hard links,
# - tell uv to byte-compile packages for faster application startups,
# - prevent uv from accidentally downloading isolated Python builds,
# - and finally pick a Python.
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.12 \
    # needed to work around https://github.com/rust-lang/cargo/issues/8719 \
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

RUN apt-get install -y --no-install-recommends \
    # for building in general
    gcc build-essential pkg-config

ADD requirements.txt /src/requirements.txt

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache \
    . /root/.cargo/env && \
    uv venv && \
    uv pip sync /src/requirements.txt

FROM ubuntu:noble AS runtime-image
VOLUME /var/lib/sickchill
VOLUME /mnt/media
EXPOSE 8080

COPY --from=compile-sickchill  /app/.venv  /app/.venv

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

COPY --from=ghcr.io/astral-sh/uv:0.5 /uv /bin/uv

WORKDIR /app
CMD [ \
    "uv", "run", "python", \
    "-m", "SickChill", \
    "--datadir=/var/lib/sickchill", \
    "--config", "/var/lib/sickchill/config.ini", \
    "--nolaunch", \
    "--port", "8080" \
    ]

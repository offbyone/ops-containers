FROM debian:bookworm AS compile-image
RUN apt-get update
RUN apt-get install -y --no-install-recommends gcc build-essential python-is-python3 python3-venv python3-dev

# prepare the supervisor venv
RUN python -mvenv /app/supervisor && \
    /app/supervisor/bin/python -mpip install --upgrade pip && \
    /app/supervisor/bin/python -mpip install supervisor

# prepare the sickchill venv
RUN python -mvenv /app/sickchill && \
    /app/sickchill/bin/python -mpip install --upgrade pip && \
    /app/sickchill/bin/python -mpip install sickchill

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

COPY --from=compile-image /app/supervisor /app/supervisor
COPY --from=compile-image /app/sickchill /app/sickchill

COPY etc/supervisor /etc/supervisor
COPY etc/supervised /etc/supervised
RUN mkdir -p /etc/supervised/init.d && touch /etc/supervised/init.d/.keep
COPY bin/init.sh /etc/supervised/bin/init.sh
COPY bin/run-in-venv.sh /usr/local/bin/run-in-venv.sh

CMD . /app/supervisor/bin/activate && \
    exec python /app/supervisor/bin/supervisord \
    -c /etc/supervisor/supervisord.conf

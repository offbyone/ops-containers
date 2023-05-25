FROM alpine:latest as tailscale
WORKDIR /install
ENV TAILSCALE_VERSION=1.42.0
ENV TSFILE=tailscale_${TAILSCALE_VERSION}_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM linuxserver/sickchill:latest
RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables
COPY --from=tailscale /install/tailscaled /app/tailscaled
COPY --from=tailscale /install/tailscale /app/tailscale
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /app

COPY bin/* /app/
ADD s6/s6-rc.d /etc/s6-overlay/s6-rc.d

FROM tailscale/tailscale:v1.84.3
COPY connect.sh /connect.sh
COPY --from=ghcr.io/jqlang/jq:1.8.0 /jq /usr/local/bin/jq
HEALTHCHECK --interval=5s --timeout=10s --start-period=20s --retries=3 \
  CMD tailscale status --json | /usr/local/bin/jq -e '.Self != null and .Self.Online == true' || exit 1
CMD ["/connect.sh"]

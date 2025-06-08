FROM tailscale/tailscale:v1.80.3
COPY connect.sh /connect.sh
COPY --from=ghcr.io/jqlang/jq:1.8.0 /jq /usr/local/bin/jq
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD tailscale status --json | /usr/local/bin/jq -e '.Self != null and .Self.Online == true' || exit 1
CMD ["/connect.sh"]

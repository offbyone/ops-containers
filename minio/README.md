To set up tailscale serve, you need to use the tailscale API, which means loading serve.json from the tailscale CLI.

``` shellsession
$ cat serve.json | sudo docker compose exec sidecar tailscale debug localapi POST serve-config - 
```

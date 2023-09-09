# wg_hideme_privoxy

## wireguard vpn client with privoxy and microsocks in docker
## its a hideme vpn client ONLY

mount to use as sample \
Container Path: /config <> /mnt/user/appdata/wg_hideme_privoxy/

```
docker run -d \
  --name=wg_hideme_privoxy \
  --net=bridge \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  -e TZ="Europe/Berlin" \
  -e LOCAL_NET=192.168.1.0/24 \
  -e HIDEME_SERVER=de \
  -e HIDEME_USER=hidemeLogin \
  -e HIDEME_PASS=hidemePass \
  -p 8080:8080/tcp \
  -p 1080:1080/tcp \
  -v /mnt/user/appdata/wg_hideme_privoxy/:/config:rw \
  --cap-add=NET_ADMIN --device /dev/net/tun --sysctl net.ipv6.conf.all.disable_ipv6=1 \
  alturismo/wg_hideme_privoxy
```

## Environment Variables

LOCAL_NET - CIDR mask of the local IP addresses which will acess the proxy and bypass it, comma seperated \
HIDEME_SERVER - HideMe Server to use \
HIDEME_USER - your HideMe username for your vpn \
HIDEME_PASS - your HideMe password for your vpn \
HIDEME_SOCKS - set to ```off``` to disable \
HIDEME_PRIVOXY - set to ```off``` to disable \

TZ - Timezone, not relevant for function

port 8080 privoxy \
port 1080 socks proxy

## hideme.client will replace dns servers and has a killswitch included, also reconnections are set to check every 3 minutes in case of disconnects

thanks to this nice app by hideme

https://github.com/eventure/hide.client.linux

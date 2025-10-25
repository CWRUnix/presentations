#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

DOMAIN=case.eduu

sudo systemctl stop systemd-resolved
cleanup() {
  pkill -P $$ dnsmasq || true
  sudo systemctl start systemd-resolved
}
trap cleanup EXIT INT TERM

sleep 1
sudo dnsmasq --no-daemon \
  --listen-address=127.0.0.53 \
  --address=/$DOMAIN/127.0.0.1 &
sleep 1

sudo python3 - <<'PY'
import http.server, socketserver
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        with open('./website.html', 'rb') as f:
            body = f.read()
        self.send_response(200)
        self.send_header('Content-Type','text/html')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)
    def log_message(self, *args): pass
socketserver.TCPServer(('', 80), H).serve_forever()
PY


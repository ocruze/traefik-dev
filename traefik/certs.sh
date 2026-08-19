#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Domains covered by the dev certificate — edit and re-run to add more.
# All domains end up as SANs of a single certificate (certs/dev.pem).
DOMAINS=("docker.localhost" "*.docker.localhost")

export CAROOT="$PWD/certs"
CERT="certs/dev.pem"
KEY="certs/dev-key.pem"

command -v mkcert >/dev/null || {
    echo "mkcert is required: sudo apt install mkcert libnss3-tools" >&2
    exit 1
}

mkdir -p certs

# Create the CA and register it in the browser trust stores (Firefox/Chromium NSS).
# NSS-only because the system store needs sudo; see README for system-wide trust.
[ -f "$CAROOT/rootCA-key.pem" ] || TRUST_STORES=nss mkcert -install

# (Re)generate the certificate when its SANs don't match DOMAINS
wanted=$(printf '%s\n' "${DOMAINS[@]}" | sort)
current=$(openssl x509 -in "$CERT" -noout -ext subjectAltName 2>/dev/null |
    grep -o 'DNS:[^, ]*' | sed 's/DNS://' | sort || true)
if [ "$wanted" != "$current" ]; then
    mkcert -cert-file "$CERT" -key-file "$KEY" "${DOMAINS[@]}"
fi

# Remove leftover certificates from previous configurations
for f in certs/*.pem; do
    case "$(basename "$f")" in
        dev.pem | dev-key.pem | rootCA.pem | rootCA-key.pem) ;;
        *) rm -v "$f" ;;
    esac
done

echo "certs ready and trusted"

# traefik-dev

Local web dev environment: [Traefik](https://traefik.io/) reverse proxy with
trusted HTTPS on `*.docker.localhost`, plus a [MailCatcher](https://mailcatcher.me/).

## Prerequisites

- Docker + Compose
- [mkcert](https://github.com/FiloSottile/mkcert) and `certutil`
  (needs an admin account): `sudo apt install mkcert libnss3-tools`

## Setup

1. Create the shared Docker network:

   ```bash
   docker network create web_dev
   ```

2. Generate and trust the dev certificates — as your normal user, **never with sudo**:

   ```bash
   ./certs.sh
   ```

   Creates the CA, registers it in the browser trust stores (Firefox/Chromium
   NSS databases), and generates the certificate `certs/dev.pem`. Idempotent.

3. Restart your browser (the trust database is only read at startup).

4. *(Optional, recommended)* Make `curl`, `wget`, git, etc. trust the CA too.
   The system store needs root — run from an admin account:

   ```bash
   sudo cp certs/rootCA.pem /usr/local/share/ca-certificates/mkcert-dev.crt
   sudo update-ca-certificates
   ```

5. Start the stack:

   ```bash
   docker compose up -d --remove-orphans
   ```

6. Check: https://docker.localhost should show the Traefik dashboard with a
   green padlock.

## Adding domains

Edit the `DOMAINS` list at the top of `certs.sh` and re-run it. All domains
are SANs of the single certificate `certs/dev.pem`. Anything under
`*.docker.localhost` is already covered — no regeneration needed.

Route new services either with Traefik labels on containers attached to
`web_dev`, or via `dynamic.yml` for apps running on the host
(`http://host.docker.internal:<port>`).

## URLs

- Traefik dashboard: https://docker.localhost
- MailCatcher: https://mailcatcher.docker.localhost
  (SMTP reachable from containers on `web_dev` at `mailcatcher:1025`)

## Notes

- `certs/` is gitignored; `rootCA-key.pem` never leaves the host and is not
  mounted into any container.
- Wiping `certs/` and re-running `certs.sh` creates a **new** CA: redo the
  browser restart (step 3) and the system-store copy (step 4).
- Traefik runs with `network_mode: host` (+ `userns_mode: host`) for
  compatibility with the IGN Docker install.

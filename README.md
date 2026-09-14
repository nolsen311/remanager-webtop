# remanager-webtop

Runs [reManager](https://github.com/rmitchellscott/reManager) — a desktop
app for managing mods on reMarkable tablets — inside a container, streamed
to a browser tab. reManager itself has no web or headless mode; it's a
[Wails](https://wails.io/) (GTK3 + WebKitGTK) desktop app, so this wraps it
in [linuxserver/webtop](https://github.com/linuxserver/docker-webtop), which
runs a full Linux desktop and streams it to the browser over WebRTC. That
lets you open reManager from a phone browser on your LAN, no desktop or SSH
client required.

## How it stays up to date

`.github/workflows/build.yml` polls the reManager GitHub releases every 3
hours. When a new release is published upstream, it builds a fresh image
(pinned to that release's Linux binary) for `linux/amd64` and `linux/arm64`
and pushes it to `ghcr.io/<owner>/remanager-webtop` as both `:latest` and
the version tag. Nothing runs on your server automatically — see
[Keeping the running container up to date](#keeping-the-running-container-up-to-date)
below.

## Setup

1. Push this repo to GitHub under your own account. The workflow needs no
   secrets — it uses the built-in `GITHUB_TOKEN`.
2. After the first workflow run, open the repo's **Packages** tab, find
   `remanager-webtop`, and set its visibility to **Public** (package
   settings, not the repo). This lets `docker compose pull` work on your
   server without logging in to GHCR. If you'd rather keep it private, run
   `docker login ghcr.io` on the server with a PAT that has `read:packages`
   instead.
3. On your home server:
   ```bash
   docker compose up -d
   ```
4. Visit `http://<server-ip>:3001` from your phone's browser (same
   Wi-Fi/LAN as the server). You'll land on a full Linux desktop with
   reManager already open — connect it to your reMarkable Paper Pro Move
   over SSH the same way you would on desktop.

Optional: uncomment `CUSTOM_USER`/`PASSWORD` in `docker-compose.yml` to put
a login prompt in front of the web UI.

## Keeping the running container up to date

The GitHub Action only builds and publishes the image — your server still
needs to pull it. `update.sh` does that (pulls, and only recreates the
container if the image actually changed):

```bash
./update.sh
```

Add it to cron for hands-off updates, e.g. daily at 4am:

```
0 4 * * * cd /path/to/remanager-webtop && ./update.sh >> update.log 2>&1
```

## Persistence

reManager's settings and saved SSH credentials live under `/config` inside
the container, backed by the `remanager-config` named volume, so they
survive image upgrades and container recreation.

## Notes

- First launch may prompt to set up a keyring (used to store saved SSH
  passwords). You can skip it if you don't need password persistence.
- The container renders in software (no GPU passthrough), which is fine
  for reManager's UI but means it's not meant for anything graphically
  heavy.

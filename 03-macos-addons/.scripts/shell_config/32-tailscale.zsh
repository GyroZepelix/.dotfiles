# Tailscale CLI from the macOS app bundle (the App Store / standalone app does
# not put `tailscale` on PATH).
TAILSCALE_APP_CLI="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
if [[ -x "$TAILSCALE_APP_CLI" ]]; then
  alias tailscale="$TAILSCALE_APP_CLI"
fi
unset TAILSCALE_APP_CLI

body=$(
  journalctl --user -u sync-yt-cookies.service -n 8 -o cat --no-pager \
    | tail -n 4 \
    | tr '\n' ' ' \
    | cut -c1-240
)
notify-send \
  --urgency=critical \
  --app-name=sync-yt-cookies \
  --icon=dialog-error \
  "YouTube cookies failed" \
  "${body:-sync-yt-cookies failed. journalctl --user -u sync-yt-cookies -n 20}"

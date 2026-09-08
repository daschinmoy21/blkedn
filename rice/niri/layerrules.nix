{...}: {
  programs.niri.settings = {
    # Noctalia v5 namespaces (was ^quickshell$ from older shell stack).
    # Overview only shows layer surfaces marked place-within-backdrop.
    # See: https://docs.noctalia.dev/v4/getting-started/compositor-settings/niri/
    layer-rules = [
      {
        # Option 1: blurred overview wallpaper (Noctalia "Enable overview wallpaper")
        matches = [{namespace = "^noctalia-overview";}];
        place-within-backdrop = true;
      }
      {
        # Option 2: regular wallpaper sits in niri backdrop (visible in overview)
        matches = [{namespace = "^noctalia-wallpaper";}];
        place-within-backdrop = true;
      }
    ];
  };
}

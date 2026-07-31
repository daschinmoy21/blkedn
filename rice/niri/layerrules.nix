{...}: {
  programs.niri.settings = {
    # Do not use place-within-backdrop for the interactive Amadeus bar —
    # it can make the layer non-clickable.
    layer-rules = [];
  };
}

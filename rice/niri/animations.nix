{...}: {
  programs.niri.settings = {
    animations = let
      anim = {
        enable = true;
        kind.easing = {
          duration-ms = 270;
          curve = "cubic-bezier";
          curve-args = [
            0.26
            0.38
            0.3
            1.28
          ];
        };
      };
    in {
      slowdown = 1.0;
      workspace-switch = {
        spring = {
          damping-ratio = 1.0;
          stiffness = 1000;
          epsilon = 0.0001;
        };
      };
      window-open = {
        easing = {
          duration-ms = 150;
          curve = "ease-out-expo";
        };
      };
      window-close = {
        easing = {
          duration-ms = 150;
          curve = "ease-out-quad";
        };
      };
      horizontal-view-movement = {
        spring = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      window-movement = {
        spring = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
    };
  };
}

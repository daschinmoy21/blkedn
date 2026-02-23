{...}: {
  programs.niri.settings = {
    layout = {
      gaps = 9;
      center-focused-column = "never"; # default is never in niri if not specified, black-don-os didn't specify so likely default. Rice had "on-overflow". I'll stick to default if not present.
      
      preset-column-widths = [
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 1.0; }
      ];

      default-column-width = { proportion = 0.5; };

      focus-ring.enable = false; # black-don-os has focus-ring { off }

      border = {
        enable = true;
        width = 2;
        active.color = "#cba6f7";
        inactive.color = "#45475a";
        urgent.color = "#f5c2e7";
      };

      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = { x = 0; y = 5; };
        color = "#00000077"; # #0007 is #00000077 in hex (77 is rough approx of 7 repeating or 7/15? No, #0007 is argb or rgba? CSS #0007 usually means #00000077. niri uses CSS colors? KDL uses string colors. black-don-os used "#0007". I will use standard 8-digit hex for safety or just pass the string if niri accepts it. Niri accepts CSS colors. #0007 expands to #00000077.
      };
      
      struts = {}; # empty in black-don-os
    };
  };
}
#background: linear-gradient(225deg, #73E25196, #B5821F98);


{pkgs, ...}: let
  tuigreetCommand = pkgs.writeShellScript "tuigreet-session" ''
    exec ${pkgs.tuigreet}/bin/tuigreet \
      --time \
      --asterisks \
      --user-menu \
      --remember \
      --greeting WELCOME \
      --theme 'text=red;prompt=green;time=red;input=red;border=white;title=red;action=white;greet=white' \
      --cmd ${pkgs.niri}/bin/niri-session
  '';
in {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${tuigreetCommand}";
        user = "greeter";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    niri
  '';
}

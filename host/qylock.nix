{
  pkgs,
  inputs,
  ...
}: {
  programs.qylock = {
    enable = true;
    theme = "field";
    sddm.enable = false;
    quickshell.enable = true;
  };
}

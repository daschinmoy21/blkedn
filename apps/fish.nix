{pkgs, ...}: {
  programs.fish = {
    enable = true;

    shellInit = ''
      fish_vi_key_bindings
    '';

    shellAliases = {
      build = "nh os switch ~/Nix --impure";
      update = "nh os switch -u -a ~/Nix --impure";
      preview = "nh os test -n ~/Nix --impure";
      scrub = "nh clean all --keep-since 7d, --keep 5";
      sweep = "nix-collect-garbage -v";
      assess = "nix-collect-garbage -v --dry-run";
    };
  };
}

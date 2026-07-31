{pkgs, ...}: {
  programs.fish = {
    enable = true;

    shellInit = ''
      fish_vi_key_bindings
    '';

    shellAliases = {
      build = "nh os switch /home/crimxnhaze/blkedn";
      update = "nh os switch -u -a /home/crimxnhaze/blkedn";
      preview = "nh os test -n /home/crimxnhaze/blkedn";
      scrub = "nh clean all --keep-since 7d, --keep 5";
      sweep = "nix-collect-garbage -v";
      assess = "nix-collect-garbage -v --dry-run";
    };
  };
}

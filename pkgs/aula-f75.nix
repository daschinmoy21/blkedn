# AULA F75 keyboard keymap/lighting writer (native Rust, HID feature reports).
# https://github.com/Nokkasiili/aula-f75-linux
#
# Upstream hardcodes ./test.toml; our patch takes the config path as argv[1] and adds
# `--dump <names.toml> <out.toml>` to read the keyboard's current keymap/colors (backup).
# The sample config (Finnish-ANSI tweaks: Delete -> `*`, right Fn -> AltGr) is
# installed to $out/share/aula-f75/example.toml — copy and edit before applying.
# Usage: aula-f75 ~/aula.toml   (needs the hidraw udev rule in host/services.nix)
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  udev,
}:
rustPlatform.buildRustPackage {
  pname = "aula-f75";
  version = "0.1.0-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "Nokkasiili";
    repo = "aula-f75-linux";
    rev = "33ae5bafb6de1bca45530dc28c95ac855be7dc51";
    hash = "sha256-A9hb085I1x338RGnaFZOCi+eI+VMoqIIJvjJzyS/MFk=";
  };

  cargoLock.lockFile = ./aula-f75-Cargo.lock;

  patches = [./aula-f75-config-arg-dump.patch];

  nativeBuildInputs = [pkg-config];
  buildInputs = [udev];

  postInstall = ''
    mv $out/bin/driver $out/bin/aula-f75
    install -Dm644 test.toml $out/share/aula-f75/example.toml
  '';

  meta = {
    description = "Native Linux keymap/lighting tool for the AULA F75 keyboard";
    homepage = "https://github.com/Nokkasiili/aula-f75-linux";
    platforms = lib.platforms.linux;
    mainProgram = "aula-f75";
  };
}

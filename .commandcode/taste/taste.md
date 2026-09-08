# nix
- Prefer using packages directly from nixpkgs when available instead of maintaining a custom flake input. Confidence: 0.95
- Avoid `nix flake update`; pin flake inputs to prevent breakage, especially for discord screenshare. Confidence: 0.85
- Use stable nixpkgs for niri and xwayland; unstable versions cause discord screenshare to stop working. Confidence: 0.75

# nixvim
- Use nixvim (not nvf) for neovim configuration. Confidence: 0.75
- Use blink.cmp with `signature.enabled = true` for autocomplete; lsp-signature plugin conflicts with blink.cmp. Confidence: 0.70
- Add which-key or similar keybind hint plugin (leader key shows grouped hints). Confidence: 0.70

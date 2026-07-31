# Imperative Nix profile packages

Snapshot of packages installed via `nix profile` (user profile at
`~/.local/state/nix/profiles/profile`), **not** declared in this flake.

Captured: **2026-07-31** with `nix profile list`.

> These installs survive independently of `nh os switch` / Home Manager.
> Prefer migrating long-lived tools into the flake when possible.

## Full list

| Name | Package / version | Source |
| --- | --- | --- |
| Logia | logia 0.9.5 | `github:daschinmoy21/Logia` |
| bzip2 | 1.0.8 | nixpkgs |
| ccusage | 20.0.17 | `github:ccusage/ccusage` |
| claude-code-nix | claude-code 2.1.195 | `github:sadjow/claude-code-nix` |
| fastfetch | 2.66.0 | nixpkgs |
| fetch | 2.1.0 | nixpkgs |
| file-roller | 44.7 | nixpkgs |
| github-copilot-cli | 1.0.26 | nixpkgs |
| gnutar | 1.35 | nixpkgs |
| godot | 4.7-stable | nixpkgs |
| gzip | 1.14 | nixpkgs |
| hey | 0.1.4 | nixpkgs |
| home-manager-path | HM generation path | Home Manager (auto) |
| kiro-cli | 2.8.1 | nixpkgs |
| kiro-fhs | kiro 0.12.333 | nixpkgs |
| omp-nix | oh-my-pi 17.0.6 | `github:yuxqiu/omp-nix` |
| p7zip | 17.06 | nixpkgs |
| pear-desktop | 3.12.0 | nixpkgs |
| qwen-code | 0.16.0 | nixpkgs |
| unzip | 6.0 | nixpkgs |
| witr | 0.3.3 | nixpkgs |
| xz | 5.8.3 | nixpkgs |
| ytmdesktop | 2.0.11 | nixpkgs |
| zip | 3.0 | nixpkgs |

**Total:** 24 profile entries (including `home-manager-path`).

## By category

### AI / coding agents

- claude-code-nix
- github-copilot-cli
- kiro-cli
- kiro-fhs
- qwen-code
- omp-nix (oh-my-pi)
- ccusage
- Logia

### Desktop apps

- godot
- pear-desktop
- ytmdesktop
- file-roller
- fastfetch / fetch

### Archive / compression

- zip, unzip, gzip, bzip2, xz, p7zip, gnutar

### Misc

- hey
- witr

### Home Manager

- `home-manager-path` — packages from the HM config generation; not a manual `nix profile install`.

## Overlap with this flake

| Profile package | Also in flake config? |
| --- | --- |
| pear-desktop | Yes — `host/programs.nix` (duplicate) |
| Archive tools | No (system has `xarchiver`) |
| AI tools above | No |
| godot, ytmdesktop, file-roller, fastfetch | No |

## Refresh this list

```fish
nix profile list
```

Or re-dump a table later when migrating packages into the flake.

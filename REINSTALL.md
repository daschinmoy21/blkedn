# Fresh NixOS reinstall — handoff note

This branch (`clean-repro`) is meant to be reinstalled from a clean disk, then restored with backups on **SSD2**.

After you finish the base NixOS install and clone this repo, **hand the session back to the agent** to restore Helium, Hetzner/SSH keys, walls symlink, and anything else listed below. You do not need to run the restore steps yourself unless you want to.

---

## Before you wipe (checklist)

Do these on the **old** system if you have not already:

- [x] SSH keys copied to `SSD2/nixos-backup/ssh/`
- [x] Helium profile copied to `SSD2/nixos-backup/helium/`
- [x] Walls moved to `SSD2/walls` (`~/walls` was a symlink)
- [ ] Optional: one more Helium sync after closing the browser  
  `rsync -a --delete ~/.config/net.imput.helium/ /home/crimxnhaze/SSD2/nixos-backup/helium/net.imput.helium/`
- [ ] Commit / push `clean-repro` so the flake is on the remote
- [ ] Note root + boot disk layout (UEFI) and any extra SSD UUIDs

---

## Backup locations (SSD2)

SSD2 is mounted in the flake at `/home/crimxnhaze/SSD2` via `host/drives.nix` (NTFS, `nofail`).

| What | Path on SSD2 |
|------|----------------|
| SSH (hetzner, id_ed25519, gcloud, config, …) | `/home/crimxnhaze/SSD2/nixos-backup/ssh/` |
| Helium profile | `/home/crimxnhaze/SSD2/nixos-backup/helium/net.imput.helium/` |
| Wallpapers (canonical tree) | `/home/crimxnhaze/SSD2/walls/` |
| Short restore notes | `/home/crimxnhaze/SSD2/nixos-backup/docs/RESTORE.md` |

**Do not commit private keys or the Helium profile into git.**

---

## You do: install + bootstrap only

1. Install NixOS (UEFI), create user `crimxnhaze`, enable networking.
2. Mount SSD2 if needed so data is visible (after first switch, flake mounts it; before that you may mount manually by UUID).
3. Clone this flake:

   ```bash
   git clone <your-remote-for-blkedn> ~/blkedn
   cd ~/blkedn
   git checkout clean-repro
   ```

4. Regenerate hardware config (UUIDs change after reinstall):

   ```bash
   sudo nixos-generate-config --show-hardware-config | tee hardware-configuration.nix
   ```

5. Fix or temporarily comment extra mounts in `host/drives.nix` if SSD UUIDs changed:

   ```bash
   ls -l /dev/disk/by-uuid/
   ```

6. First switch (pure; no `--impure`):

   ```bash
   # set a password if you have none yet
   sudo passwd crimxnhaze

   nh os switch /home/crimxnhaze/blkedn
   # or: sudo nixos-rebuild switch --flake /home/crimxnhaze/blkedn#nixos
   ```

7. Reboot into niri / greeter, confirm SSD2 is mounted:

   ```bash
   ls /home/crimxnhaze/SSD2/nixos-backup
   ```

8. **Stop here and ask the agent to restore everything** (message example below).

---

## Agent does: full restore (after reinstall)

When the user says reinstall is done and SSD2 is mounted, the agent should:

### 1. SSH keys

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cp -a /home/crimxnhaze/SSD2/nixos-backup/ssh/* ~/.ssh/
chmod 600 ~/.ssh/hetzner_key ~/.ssh/id_ed25519 ~/.ssh/google_compute_engine 2>/dev/null || true
chmod 644 ~/.ssh/*.pub 2>/dev/null || true
# quick test (optional): ssh -i ~/.ssh/hetzner_key …
```

### 2. Helium browser profile

Quit Helium first, then:

```bash
mkdir -p ~/.config
rsync -a /home/crimxnhaze/SSD2/nixos-backup/helium/net.imput.helium/ \
  ~/.config/net.imput.helium/
```

### 3. Walls symlink

Data already lives on SSD2; only recreate the home link:

```bash
ln -sfn /home/crimxnhaze/SSD2/walls /home/crimxnhaze/walls
test -f ~/walls/katana.png && echo walls ok
```

### 4. Flake / system sanity

- Confirm `git checkout clean-repro` and `hardware-configuration.nix` matches this machine.
- Confirm `host/drives.nix` UUIDs for SSD2/SSD3.
- `nh os switch ~/blkedn` if anything was edited.
- Optional: drop leftover `nix profile` packages once system packages work (see `NIX-PROFILE-APPS.md` / README).

### 5. Desktop stack expected on this branch

| Piece | Source |
|-------|--------|
| WM | niri (nixpkgs) |
| Shell | Noctalia v5 (binary cache, NixOS module — not Home Manager) |
| Lock | qylock (`Mod+Alt+L` → `qylock-lock`) |
| Greeter | greetd + tuigreet |
| GPU | NVIDIA PRIME + Intel (see `hw/nvidia.nix`) |
| Editor | nvf Neovim |

### 6. Still manual / later

- User password / any secrets not on SSD2  
- Cloudflare WARP login, browser account sessions if profile restore is incomplete  
- **keelcode** — not packaged yet (README TODO)  
- `host/priv/` — reference only, not imported  

---

## Suggested message to the agent after reinstall

```text
Reinstall done. Branch clean-repro, SSD2 mounted at ~/SSD2.
Restore everything per REINSTALL.md: SSH keys, Helium, walls symlink,
drives UUIDs, and verify nh os switch / noctalia / niri.
```

---

## Branch notes

- Prefer pure rebuilds: no `--impure` on `nh os switch`.
- Noctalia uses `github:noctalia-dev/noctalia/cachix` **without** `nixpkgs.follows` so the binary cache hits.
- `host/priv/` is not part of this setup.
- Walls are **not** in a GitHub repo; only on SSD2.

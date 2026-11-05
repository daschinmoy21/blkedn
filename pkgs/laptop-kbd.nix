# Turn the built-in keyboard on or off through the kernel's per-device `inhibited`
# switch. External keyboards are separate devices and keep working.
# hw/laptop-keyboard.nix grants the write permission.
{writeShellApplication}:
writeShellApplication {
  name = "laptop-kbd";
  text = ''
    device_name="AT Translated Set 2 keyboard"

    die() {
      printf 'laptop-kbd: %s\n' "$2" >&2
      exit "$1"
    }

    find_attr() {
      local dir found=""
      for dir in /sys/class/input/input*; do
        [[ -r "$dir/name" ]] || continue
        [[ "$(<"$dir/name")" == "$device_name" ]] || continue
        [[ -z "$found" ]] || die 3 "more than one '$device_name' device found"
        found="$dir/inhibited"
      done
      [[ -n "$found" ]] || die 3 "no '$device_name' device found"
      [[ -e "$found" ]] || die 3 "$found does not exist"
      printf '%s\n' "$found"
    }

    state_of() {
      case "$(<"$1")" in
        0) printf 'enabled\n' ;;
        1) printf 'disabled\n' ;;
        *) die 5 "unexpected value in $1" ;;
      esac
    }

    set_state() {
      local attr="$1" want="$2" value=1
      [[ "$want" == disabled ]] || value=0
      [[ -w "$attr" ]] || die 4 "no write permission on $attr (see hw/laptop-keyboard.nix)"
      { printf '%s\n' "$value" >"$attr"; } 2>/dev/null || die 4 "could not write to $attr"
      [[ "$(state_of "$attr")" == "$want" ]] || die 5 "state did not change to $want"
      printf '%s\n' "$want"
    }

    attr="$(find_attr)"

    case "''${1:-status}" in
      on) set_state "$attr" enabled ;;
      off) set_state "$attr" disabled ;;
      toggle)
        if [[ "$(state_of "$attr")" == enabled ]]; then
          set_state "$attr" disabled
        else
          set_state "$attr" enabled
        fi
        ;;
      status) state_of "$attr" ;;
      path) printf '%s\n' "$attr" ;;
      *)
        printf 'usage: laptop-kbd [on|off|toggle|status|path]\n' >&2
        exit 2
        ;;
    esac
  '';
}

#!/usr/bin/env bash
set -uo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/anto426"
CONFIG_FILE="${ANTO426_SYNC_CONFIG:-$DATA_DIR/sync.env}"
SYNC_SCRIPT="${ANTO426_SYNC_SCRIPT:-$HOME/.config/anto426/remote_sync.sh}"
DEFAULT_IMAGE_DIR="$HOME/Pictures/neofetch"
DEFAULT_ASCII_LOGO="${XDG_CONFIG_HOME:-$HOME/.config}/fastfetch/ascii-logo.txt"

load_dotfiles_asset_config() {
    if [[ -x "$SYNC_SCRIPT" ]]; then
        ANTO426_SYNC_QUIET=1 "$SYNC_SCRIPT" init >/dev/null 2>&1 || true
    fi

    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck disable=SC1090
        source "$CONFIG_FILE"
    fi
}

image_dir() {
    printf '%s\n' "${ANTO426_NEOFETCH_DIR:-$DEFAULT_IMAGE_DIR}"
}

ascii_logo() {
    printf '%s\n' "${ANTO426_FASTFETCH_ASCII_LOGO:-$DEFAULT_ASCII_LOGO}"
}

is_vscode_terminal() {
    case "${TERM_PROGRAM:-}" in
        vscode | bootty) return 0 ;;
    esac

    [[ "${BOOTTY:-}" == "1" ]]
}

images_enabled() {
    case "${ANTO426_NEOFETCH_IMAGES:-1}" in
        0 | false | no | off) return 1 ;;
        *) return 0 ;;
    esac
}

run_ascii_fastfetch() {
    local logo
    logo="$(ascii_logo)"

    if [[ -f "$logo" ]]; then
        exec fastfetch --logo "$logo" --logo-type file
    fi

    exec fastfetch
}

clear_terminal_images() {
    # Clear previously rendered Kitty graphics in terminals that support them.
    printf '\033_Ga=d,d=A\033\\' 2>/dev/null || true
}

clear_fastfetch_image_cache() {
    local dir="$1"
    local cache_home cache_dir

    [[ "$dir" == /* && "$dir" != "/" ]] || return 0

    for cache_home in "$HOME/.cache" "${XDG_CACHE_HOME:-}"; do
        [[ -n "$cache_home" ]] || continue
        cache_dir="$cache_home/fastfetch/images$dir"
        [[ "$cache_dir" == "$cache_home/fastfetch/images/"* ]] || continue
        rm -rf "$cache_dir"
    done
}

run_image_fastfetch() {
    local image="$1"
    local source_dir="$2"
    local cache_dir status

    cache_dir="$(mktemp -d "${TMPDIR:-/tmp}/fastfetch-cache.XXXXXX")" || run_ascii_fastfetch

    clear_fastfetch_image_cache "$source_dir"
    clear_terminal_images
    XDG_CACHE_HOME="$cache_dir" fastfetch --logo "$image" \
        --logo-type kitty-direct \
        --logo-width 30 \
        --logo-padding-left 3 \
        --logo-padding-right 5 \
        --logo-preserve-aspect-ratio true
    status=$?

    clear_fastfetch_image_cache "$source_dir"
    rm -rf "$cache_dir"
    exit "$status"
}

pick_image() {
    local dir="$1"

    [[ -d "$dir" ]] || return 1

    find "$dir" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) |
        shuf -n 1
}

load_dotfiles_asset_config

if ! command -v fastfetch >/dev/null 2>&1; then
    exit 0
fi

if is_vscode_terminal; then
    run_ascii_fastfetch
fi

if ! images_enabled; then
    run_ascii_fastfetch
fi

IMAGE_DIR="$(image_dir)"
image="$(pick_image "$IMAGE_DIR" || true)"

[[ -n "${image:-}" ]] || run_ascii_fastfetch

run_image_fastfetch "$image" "$IMAGE_DIR"

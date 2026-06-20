#!/usr/bin/env bash
set -uo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/anto426"
CONFIG_FILE="${ANTO426_SYNC_CONFIG:-$DATA_DIR/sync.env}"
SYNC_SCRIPT="${ANTO426_SYNC_SCRIPT:-$HOME/.config/anto426/remote_sync.sh}"
SYNC_STAMP="$DATA_DIR/neofetch-assets-sync.stamp"
DEFAULT_IMAGE_DIR="$HOME/Pictures/neofetch"
SYNC_INTERVAL_DEFAULT=900

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

maybe_sync_assets() {
    [[ -x "$SYNC_SCRIPT" ]] || return 0

    local now last interval
    now="$(date +%s)"
    last=0
    [[ -f "$SYNC_STAMP" ]] && last="$(cat "$SYNC_STAMP" 2>/dev/null || printf '0')"
    interval="${ANTO426_SYNC_INTERVAL:-$SYNC_INTERVAL_DEFAULT}"
    [[ "$interval" =~ ^[0-9]+$ ]] || interval="$SYNC_INTERVAL_DEFAULT"

    if (( now - last > interval )); then
        mkdir -p "$(dirname "$SYNC_STAMP")"
        printf '%s\n' "$now" > "$SYNC_STAMP"
        (ANTO426_SYNC_QUIET=1 "$SYNC_SCRIPT" assets >/dev/null 2>&1 || true) &
    fi
}

pick_image() {
    local dir="$1"

    [[ -d "$dir" ]] || return 1

    find "$dir" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) |
        shuf -n 1
}

load_dotfiles_asset_config
maybe_sync_assets

if ! command -v fastfetch >/dev/null 2>&1; then
    exit 0
fi

IMAGE_DIR="$(image_dir)"
image="$(pick_image "$IMAGE_DIR" || true)"

if [[ -z "${image:-}" && -x "$SYNC_SCRIPT" ]]; then
    ANTO426_SYNC_QUIET=1 "$SYNC_SCRIPT" assets >/dev/null 2>&1 || true
    image="$(pick_image "$IMAGE_DIR" || true)"
fi

[[ -n "${image:-}" ]] || exec fastfetch

exec fastfetch --logo "$image" \
    --logo-type kitty \
    --logo-width 30 \
    --logo-padding-left 3 \
    --logo-padding-right 5 \
    --logo-preserve-aspect-ratio true

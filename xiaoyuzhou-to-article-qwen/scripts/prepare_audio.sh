#!/bin/bash
# 下载小宇宙单集音频，并输出可供通义听悟上传的绝对路径。
# 用法: bash prepare_audio.sh <小宇宙单集链接> [临时文件父目录]

set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    echo "用法: bash prepare_audio.sh <小宇宙单集链接> [临时文件父目录]"
    exit 0
fi

URL="${1:?用法: bash prepare_audio.sh <小宇宙单集链接> [临时文件父目录]}"
BASE_OUTPUT_DIR="${2:-${TMPDIR:-/tmp}}"

case "$URL" in
    https://www.xiaoyuzhoufm.com/episode/*|https://xiaoyuzhoufm.com/episode/*) ;;
    *)
        echo "错误：只支持小宇宙单集链接（xiaoyuzhoufm.com/episode/...）" >&2
        exit 1
        ;;
esac

for bin in podpull ffprobe; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "错误：缺少依赖 $bin" >&2
        exit 1
    fi
done

mkdir -p "$BASE_OUTPUT_DIR"
BASE_OUTPUT_DIR="$(cd "$BASE_OUTPUT_DIR" && pwd)"
RUN_DIR="$(mktemp -d "$BASE_OUTPUT_DIR/xiaoyuzhou-to-article-qwen.XXXXXX")"

podpull get "$URL" --out "$RUN_DIR" --no-input

AUDIO_PATH="$(find "$RUN_DIR" -maxdepth 1 -type f \
    \( -iname '*.m4a' -o -iname '*.mp3' -o -iname '*.wav' \
       -o -iname '*.aac' -o -iname '*.flac' -o -iname '*.ogg' \) \
    -print | head -n 1)"

if [ -z "$AUDIO_PATH" ]; then
    echo "错误：podpull 未生成可识别的音频文件" >&2
    exit 1
fi

if ! ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$AUDIO_PATH" >/dev/null; then
    echo "错误：下载结果不是可读取的音频文件：$AUDIO_PATH" >&2
    exit 1
fi

DURATION="$(ffprobe -v error -show_entries format=duration \
    -of default=noprint_wrappers=1:nokey=1 "$AUDIO_PATH")"
SIZE_BYTES="$(stat -f%z "$AUDIO_PATH" 2>/dev/null || stat -c%s "$AUDIO_PATH")"

printf 'AUDIO_PATH=%s\n' "$AUDIO_PATH"
printf 'DURATION_SECONDS=%.0f\n' "$DURATION"
printf 'SIZE_BYTES=%s\n' "$SIZE_BYTES"

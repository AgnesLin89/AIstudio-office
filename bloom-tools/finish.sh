#!/usr/bin/env bash
# 用法: ./finish.sh 輸入.mp4 [輸出名] [底色hex=0060FF] [模式=direct|key] [key色hex=FFFFFF] [相似度=0.12]
# direct: Kling 輸出本身就是想要的畫面，只做 1200x1200 / 10 秒 / 30fps / 轉 ProRes 422 HQ
# key   : Kling 輸出是花在純色底(預設白)上，去掉該底色後疊到藍底 (邊緣可能有殘邊，先試樣片)
set -euo pipefail
IN="$1"; OUT="${2:-$(basename "${1%.*}")_blue}"; BLUE="${3:-0060FF}"
MODE="${4:-direct}"; KEY="${5:-FFFFFF}"; SIM="${6:-0.12}"
S=1200; D=10; FPS=30
SCALE="scale=${S}:${S}:force_original_aspect_ratio=increase,crop=${S}:${S},fps=${FPS}"
if [ "$MODE" = key ]; then
  FC="[0:v]${SCALE},colorkey=0x${KEY}:${SIM}:0.05[fg];color=c=0x${BLUE}:s=${S}x${S}:r=${FPS}:d=${D}[bg];[bg][fg]overlay=shortest=1,format=yuv422p10le[v]"
else
  FC="[0:v]${SCALE},format=yuv422p10le[v]"
fi
ffmpeg -y -i "$IN" -filter_complex "$FC" -map "[v]" -t $D -an \
  -c:v prores_ks -profile:v 3 -vendor apl0 -pix_fmt yuv422p10le "${OUT}.mov"
ffprobe -v error -show_entries stream=codec_name,profile,width,height,r_frame_rate,duration,pix_fmt -of default=nw=1 "${OUT}.mov"

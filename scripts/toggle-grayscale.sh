#!/bin/bash
# toggle-grayscale.sh — toggle a grayscale shader in Hyprland.
# Requires a grayscale shader file at ~/.config/hypr/grayscale.glsl.

set -euo pipefail

SHADER="${HOME}/.config/hypr/grayscale.glsl"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-grayscale-active"

if [[ ! -f "$SHADER" ]]; then
  # Fallback: write a minimal grayscale shader if missing.
  mkdir -p "$(dirname "$SHADER")"
  cat > "$SHADER" <<'GLSL'
precision highp float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
  vec4 pix = texture2D(tex, v_texcoord);
  float gray = dot(pix.rgb, vec3(0.299, 0.587, 0.114));
  gl_FragColor = vec4(vec3(gray), pix.a);
}
GLSL
fi

if [[ -f "$STATE_FILE" ]]; then
  hyprctl keyword decoration:screen_shader "none" >/dev/null
  rm -f "$STATE_FILE"
else
  hyprctl keyword decoration:screen_shader "$SHADER" >/dev/null
  touch "$STATE_FILE"
fi

#!/usr/bin/env bash
# Script: zz
# Description: Translate natural-language instructions into a single bash command via OpenAI API (and other LLM backends).
# Usage: zz [--backend BACKEND] [--model MODEL] "instruction"
# Author: Joseph Ian Walker
# Date: 2025-06-19
# Version: 0.1
# License: MIT

set -euo pipefail

: "${OPENAI_API_KEY:?Need to set OPENAI_API_KEY}"
backend="${ZZ_BACKEND:-openai}"
command -v curl >/dev/null 2>&1 || { echo "Error: curl not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not installed"; exit 1; }

model="gpt-4o"
help=false
instruction=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --backend)
      backend="$2"
      shift 2
      ;;
    --model)
      model="$2"
      shift 2
      ;;
    -h|--help)
      help=true
      break
      ;;
    *)
      instruction+="$1 "
      shift
      ;;
  esac
done

if [[ "$help" == true ]]; then
  cat <<EOF
Usage: zz [--backend BACKEND] [--model MODEL] "instruction"

Options:
  --backend BACKEND   Which LLM driver to use: openai, ollama or llm (default: $backend)
  --model MODEL       Model name to invoke (default: $model)
  -h, --help          Show this help.
EOF
  exit 0
fi

instruction="${instruction%% }"
if [[ -z "$instruction" ]]; then
  echo "Error: no instruction provided"
  exit 1
fi

sys="You are an expert bash user. Respond with exactly one bash command that fulfills the user instruction; do not include any explanation, markdown, or quotes."

json=$(jq -cn \
  --arg model "$model" \
  --arg sys "$sys" \
  --arg usr "$instruction" \
  '{model: $model, messages: [ {role:"system", content:$sys}, {role:"user", content:$usr} ], temperature:0}')

case "$backend" in
  openai)
    response=$(curl -sSf https://api.openai.com/v1/chat/completions \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$json")
    echo "$response" | jq -r '.choices[0].message.content'
    ;;

  ollama)
    command -v ollama >/dev/null 2>&1 || { echo "Error: ollama CLI not found"; exit 1; }
    ollama run "$model" --hidethinking <<EOF
$sys

$instruction
EOF
    ;;

  llm)
    command -v llm >/dev/null 2>&1 || { echo "Error: llm CLI not found"; exit 1; }
    llm prompt -m "$model" -s "$sys" --no-log "$instruction"
    ;;

  *)
    echo "Error: unknown backend '$backend' (must be openai, ollama or llm)"
    exit 1
    ;;
esac
#!/usr/bin/env sh

args=(--no-newline)

if [[ "${1}" == --primary ]]; then
  args+=(--primary)
fi

word=$(wl-paste "${args[@]}" | sed "s/-\n//g")

if [[ -z "${word}" ]]; then
  exit
fi

wordbook & wordbook --look-up "${word}"

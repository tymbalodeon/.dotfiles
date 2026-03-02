#!/usr/bin/env sh

args=(--no-newline)

if [[ "${1}" == --primary ]]; then
  args+=(--primary)
fi

# TODO: implement stripping newlines and hyphens (see define.nu)
word=$(wl-paste "${args[@]}")

if [[ -z "${word}" ]]; then
  exit
fi

wordbook & wordbook --look-up "${word}"

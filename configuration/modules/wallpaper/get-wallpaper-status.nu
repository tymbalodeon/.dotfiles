#!/usr/bin/env nu

export def main [] {
  ^wpaperctl get-status --json
  | from json
  | get status
  | first
}

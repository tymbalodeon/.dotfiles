#!/usr/bin/env nu

const SHORT_IDS = [
  "adguard-adblocker"
  "darkreader"
  "proton-pass"
  "refined-github-"
  "subscription-feed-filter"
  "surfingkeys_ff"
  "undistracted-main"
]

export def main [] {
  # TODO: make this a re-usable function with all the other uses, plus can it be
  # done purely with jj?
  cd (git rev-parse --show-toplevel)

  $SHORT_IDS
  | each {
      |shortId| 

      {
        name: (
          http get $"https://addons.mozilla.org/api/v5/addons/addon/($shortId)/"
          | get guid
        )

        value: {
          installation_mode: "normal_installed"
          install_url: $"https://addons.mozilla.org/en-US/firefox/downloads/latest/($shortId)/latest.xpi"
        }
      }
    }
  | to json
  | save --force ./configuration/home-manager/zen-browser/extensions.json
}

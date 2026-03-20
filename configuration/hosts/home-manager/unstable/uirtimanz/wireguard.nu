# Start/stop wireguard
export def main [] {
  wg status
}

export def start [] {
  sudo wg-quick up wg0
}

export def status [] {
  sudo wg show
}

export def stop [] {
  if (wg status | is-not-empty) {
    sudo wg-quick down wg0
  }
}

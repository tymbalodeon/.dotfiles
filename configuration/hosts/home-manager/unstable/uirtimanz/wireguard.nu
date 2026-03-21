# Start/stop wireguard
def wg [] {
  wg status
}

# Start wireguard
def "wg start" [] {
  sudo wg-quick up wg0
}

# Show wireguard connection status
def "wg status" [] {
  sudo wg show
}

# Stop wireguard
def "wg stop" [] {
  if (wg status | is-not-empty) {
    sudo wg-quick down wg0
  }
}

def "wg start" [] {
  sudo wg-quick up wg0
}

def "wg status" [] {
  sudo wg show
}

def "wg stop" [] {
  if (wg status | is-not-empty) {
    sudo wg-quick down wg0
  }
}

# Start/stop wireguard
def wg [] {
  wg status
}

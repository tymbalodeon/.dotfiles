use std assert

use ../files.nu get-tree-ignore-glob

let configuration_data = {
  systems: [darwin nixos]
  hosts: [benrosen bumbirich ruzia work]
  system_hosts: {
    darwin: [benrosen work]
    nixos: [bumbirich ruzia]
  }
}

let tests = [
  {
    shared: false
    configuration: null
    expected: null
  }

  {
    shared: false
    configuration: darwin
    expected: nixos
  }

  {
    shared: false
    configuration: benrosen
    expected: "bumbirich|ruzia|work|nixos"
  }

  {
    shared: true
    configuration: null
    expected: "hosts|systems"
  }

  {
    shared: true
    configuration: nixos
    expected: "hosts|darwin"
  }

  {
    shared: true
    configuration: bumbirich
    expected: "benrosen|ruzia|work|darwin"
  }
]

for test in $tests {
  let actual = (
    get-tree-ignore-glob $configuration_data $test.shared $test.configuration
  )

  assert equal $actual $test.expected
}

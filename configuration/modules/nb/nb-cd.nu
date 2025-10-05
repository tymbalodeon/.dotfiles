def --env "nb cd" [] {
  cd (
    nb notebooks --path
    | lines
    | where {str ends-with (nb notebooks current)}
    | first
  )
}

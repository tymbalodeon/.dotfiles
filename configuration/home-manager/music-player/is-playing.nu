#!/usr/bin/env nu

def main [] {
  if (
    rmpc status  
    | from json
    | get state
  ) != Play {
    exit 1
  }
}

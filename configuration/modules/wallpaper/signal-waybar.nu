#!/usr/bin/env nu

def main [] {
  pkill -RTMIN+2 waybar
}

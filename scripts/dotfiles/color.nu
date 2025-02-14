#!/usr/bin/env nu
 
export def colorize [text: string color: string] {
  $"(ansi $color)($text)(ansi reset)"
}


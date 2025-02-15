#!/usr/bin/env nu

export def colorize [text: string style: string] {
  $"(ansi $style)($text)(ansi reset)"
}

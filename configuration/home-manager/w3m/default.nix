{
  programs.w3m = {
    bindings = {
      "$" = "LINE_END";
      "0" = "LINE_BEGIN";
      b = "PREV_WORD";
      C-b = "COMMAND 'PREV_PAGE'";
      C-f = "COMMAND 'NEXT_PAGE'";
      "::" = "COMMAND";
      C-r = "REDO";
      ":downloads" = "DOWNLOAD_LIST";
      ESC-g = "GOTO_LINE";
      G = "END";
      gg = "BEGIN";
      H = "BACK";
      ":help" = "HELP";
      j = "COMMAND 'MOVE_DOWN1'";
      J = "NEXT_TAB";
      k = "COMMAND 'MOVE_UP1'";
      K = "PREV_TAB";
      "^" = "LINE_BEGIN";
      n = "SEARCH_NEXT";
      N = "SEARCH_PREV";
      o = "GOTO";
      O = "TAB_GOTO";
      ":q" = "EXIT";
      r = "RELOAD";
      "?" = "SEARCH_BACK";
      ":settings" = "OPTIONS";
      "/" = "WHEREIS";
      w = "NEXT_WORD";
      yy = "EXTERN 'printf %s | xclip -selection clipboard'";
    };

    enable = true;
  };
}

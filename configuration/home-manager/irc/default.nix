{
  programs.senpai = {
    config = {
      address = "irc.libera.chat";
      nickname = (import ../../users).ircNickname;
    };

    enable = true;
  };
}

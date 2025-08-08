{pkgs, ...}: {
  home.packages = with pkgs;
    [
      mpc
      mpd
    ]
    ++ (
      if stdenv.isLinux
      then [rmpc]
      else []
    );

  programs.ncmpcpp = {
    bindings = [
      {
        key = "j";
        command = "scroll_down";
      }

      {
        key = "k";
        command = "scroll_up";
      }

      {
        key = "J";
        command = ["select_item" "scroll_down"];
      }

      {
        key = "K";
        command = ["select_item" "scroll_up"];
      }
    ];

    enable = true;
  };
}

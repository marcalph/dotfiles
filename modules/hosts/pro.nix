{ ... }: {
  # GNOME / Ubuntu Dock — pro only (this file is imported solely by mkHome "pro")
  dconf.settings = {
    "org/gnome/shell".favorite-apps = [
      "firefox.desktop"
      "code.desktop"
      "obsidian.desktop"
      "bitwarden.desktop" # from pkgs.bitwarden-desktop in home.packages
      "kitty.desktop"
      "anki.desktop"
    ];

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      autohide = true;
    };
  };
}

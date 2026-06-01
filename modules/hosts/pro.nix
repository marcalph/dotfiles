{ config, pkgs, inputs, ... }: {
  # make kitty etc. show up in the ubuntu app grid
  targets.genericLinux.enable = true;

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;

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

{ config, pkgs, inputs, ... }: {
  # make kitty etc. show up in the ubuntu app grid
  targets.genericLinux.enable = true;

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;

  home.packages = [
    pkgs.bitwarden-desktop
    pkgs.obsidian
    pkgs.anki-bin
    # Ansible owns pro's system layer (daemons/OS config) — run against localhost.
    # See ansible/pro.yml. ansible itself is a client tool → nix; the daemons it
    # installs (docker, …) are apt/system-level.
    pkgs.ansible
    pkgs.ansible-lint
  ];

  # GNOME / Ubuntu Dock — pro only (this file is imported solely by mkHome "pro")
  dconf.settings = {
    "org/gnome/shell".favorite-apps = [
      "firefox.desktop"
      "google-chrome.desktop"
      "code.desktop"
      "obsidian.desktop"
      "bitwarden.desktop"
      "kitty.desktop"
      "anki.desktop"
    ];

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      autohide = true;
    };
  };
}

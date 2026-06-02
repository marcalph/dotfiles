{ config, pkgs, inputs, ... }: {
  # make kitty etc. show up in the ubuntu app grid
  targets.genericLinux.enable = true;

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;

  home.packages = [
    pkgs.bitwarden-desktop
    # Obsidian on pro needs two fixes layered together:
    #  1. nixGL wrap → lets the Nix-built Electron find Ubuntu's Intel GL/EGL
    #     drivers (else the GPU process fails EGL init, "Failed to get system
    #     egl display").
    #  2. --disable-features=Vulkan → with the GPU now working, Electron 40's
    #     native Wayland backend (--ozone-platform=wayland, enabled here because
    #     NIXOS_OZONE_WL is exported) is incompatible with the Vulkan renderer
    #     it otherwise selects, so no window surface is ever created
    #     ("'--ozone-platform=wayland' is not compatible with Vulkan"). Disabling
    #     Vulkan keeps native Wayland and forces the GL path → the window appears.
    # symlinkJoin so the .desktop entry / icons survive for the GNOME dock.
    (config.lib.nixGL.wrap (pkgs.symlinkJoin {
      name = "obsidian-no-vulkan";
      paths = [ pkgs.obsidian ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/obsidian --add-flags '--disable-features=Vulkan'";
    }))
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
    ];

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      # Ubuntu's dock ships "panel mode" (always-on) → dock-fixed defaults true,
      # which overrides autohide. Must unset it for autohide to take effect.
      dock-fixed = false;
      autohide = true;
      # hide unconditionally + reveal on hover (not just dodge-overlapping-windows)
      intellihide = false;
    };
  };
}

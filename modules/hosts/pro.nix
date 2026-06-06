{ config, pkgs, inputs, lib, ... }: {
  imports = [ inputs.xremap-flake.homeManagerModules.default ];

  # pro is the work machine → override the shared personal git identity
  # (modules/home/git.nix) with the harmattan one, for this host only.
  programs.git.settings.user.name = lib.mkForce "marc-alphonsus";
  programs.git.settings.user.email = lib.mkForce "marc.alphonsus@harmattan.ai";

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

  # ── macOS-style keyboard (Super == ⌘) ──────────────────────────────────────
  # GNOME/Wayland can't remap copy/paste (Ctrl+C/V live inside each app's
  # toolkit, not the compositor), so we remap at the evdev layer with xremap.
  # It grabs the keyboard and re-emits via /dev/uinput — device access for that
  # is granted by ansible/pro.yml (input group + uinput udev rule + module).
  #
  # Ctrl is never touched, so Ctrl+C stays SIGINT in the terminal. A lone Super
  # tap still opens the GNOME overview (only Super+<key> chords are grabbed).
  # NB: this overrides GNOME's Super+arrow window tiling (xremap eats the chord
  # before the compositor sees it).
  services.xremap = {
    enable = true;
    withGnome = true; # talks to the GNOME shell extension for window-class match
    config.keymap = [
      # Terminals: ⌘C/V/X → Ctrl+Shift+C/V/X so they copy/paste instead of
      # sending SIGINT/SIGQUIT. (Detecting the terminal needs the extension.)
      {
        name = "clipboard (terminals)";
        application.only = [
          "kitty"
          "Alacritty"
          "org.gnome.Terminal"
          "org.gnome.Console"
          "foot"
          "WezTerm"
          "wezterm"
        ];
        remap = {
          "Super-c" = "C-Shift-c";
          "Super-v" = "C-Shift-v";
          "Super-x" = "C-Shift-x";
        };
      }
      # Everywhere else: the ⌘ edit cluster → Ctrl equivalents.
      {
        name = "clipboard + edit (apps)";
        application.not = [
          "kitty"
          "Alacritty"
          "org.gnome.Terminal"
          "org.gnome.Console"
          "foot"
          "WezTerm"
          "wezterm"
          # VSCode is one window holding both an editor and a terminal, so a
          # WM_CLASS-level rule can't tell them apart — blindly sending Ctrl
          # would make ⌘C SIGINT / ⌘Z suspend / ⌘S freeze in its terminal.
          # Let Super pass through; VSCode resolves it focus-aware via its own
          # keybindings (modules/home/vscode.nix). Ctrl is left untouched there,
          # so terminal SIGINT stays on Ctrl+C. (Nav below still applies to it.)
          "code"
          "Code"
        ];
        remap = {
          "Super-c" = "C-c"; # copy
          "Super-v" = "C-v"; # paste
          "Super-x" = "C-x"; # cut
          "Super-a" = "C-a"; # select all
          "Super-z" = "C-z"; # undo
          "Super-Shift-z" = "C-Shift-z"; # redo
          "Super-s" = "C-s"; # save
          "Super-f" = "C-f"; # find
        };
      }
      # Navigation + selection — applied everywhere (Home/End are sane in shells
      # too). ⌘←/→ = line edges, ⌘↑/↓ = doc edges, +Shift selects; ⌥←/→ = word.
      {
        name = "navigation + selection";
        remap = {
          "Super-Left" = "Home";
          "Super-Right" = "End";
          "Super-Up" = "C-Home";
          "Super-Down" = "C-End";
          "Super-Shift-Left" = "Shift-Home";
          "Super-Shift-Right" = "Shift-End";
          "Super-Shift-Up" = "C-Shift-Home";
          "Super-Shift-Down" = "C-Shift-End";
          "Alt-Left" = "C-Left"; # word left  (note: replaces browser "Back")
          "Alt-Right" = "C-Right"; # word right (replaces browser "Forward")
          "Alt-Shift-Left" = "C-Shift-Left";
          "Alt-Shift-Right" = "C-Shift-Right";
        };
      }
    ];
  };

  # xremap's window-class detection on GNOME/Wayland requires its shell
  # extension. Ubuntu's GDM-launched gnome-shell only scans ~/.local/share, not
  # the nix profile, so symlink the nix-built extension into place; it's enabled
  # via dconf (enabled-extensions) below.
  home.file.".local/share/gnome-shell/extensions/xremap@k0kubun.com".source =
    "${pkgs.gnomeExtensions.xremap}/share/gnome-shell/extensions/xremap@k0kubun.com";

  # GNOME / Ubuntu Dock — pro only (this file is imported solely by mkHome "pro")
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "google-chrome.desktop"
        "code.desktop"
        "obsidian.desktop"
        "bitwarden.desktop"
        "kitty.desktop"
      ];
      # Ubuntu's stock extensions load via vendor defaults (this key is empty),
      # so listing only xremap here adds it without disabling the dock etc.
      enabled-extensions = [ "xremap@k0kubun.com" ];
    };

    # GNOME claims a few Super+<letter> chords that collide with the macOS edit
    # cluster. In most apps xremap rewrites Super+key at the device level before
    # GNOME sees it, but in xremap-excluded windows (VSCode) the real Super
    # reaches GNOME and its shortcut wins (e.g. Super+V opened the notification
    # list instead of pasting). Drop the conflicting chords so they fall through.
    "org/gnome/shell/keybindings" = {
      toggle-message-tray = [ "<Super>m" ]; # was [<Super>v, <Super>m]; free Super+V
      toggle-application-view = [ ]; # was [<Super>a]; free Super+A (select all)
      toggle-quick-settings = [ ]; # was [<Super>s]; free Super+S (save)
    };

    # Per-host wallpaper (placeholder: wallpapers/pro-wallpaper.png). The path
    # literal copies the image into the nix store; swap the file to change it.
    "org/gnome/desktop/background" = {
      picture-uri = "file://${../../wallpapers/pro-wallpaper.png}";
      picture-uri-dark = "file://${../../wallpapers/pro-wallpaper.png}";
      picture-options = "zoom";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "LEFT";
      # Ubuntu's dock ships "panel mode" (always-on) → dock-fixed defaults true,
      # which overrides autohide. Must unset it for autohide to take effect.
      dock-fixed = false;
      autohide = true;
      # hide unconditionally + reveal on hover (not just dodge-overlapping-windows)
      intellihide = false;
    };
  };
}

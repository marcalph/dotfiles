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
  # Two layers, deliberately split (same model as macOS):
  #   • app-internal keys (copy/paste/cut, in-file nav) → xremap, below.
  #   • window/desktop management → Sway natively (Ctrl+Alt+arrows, mirroring
  #     Rectangle's defaults on the Mac so muscle memory is identical). Those
  #     chords aren't in the keymap, so xremap passes them through to Sway.
  #
  # No compositor (Sway or GNOME) can remap copy/paste or in-file nav — those
  # live inside each app's toolkit, not the WM — so we remap at the evdev layer
  # with xremap. It grabs the keyboard and re-emits via /dev/uinput; device
  # access is granted by ansible/pro.yml (input group + uinput udev rule + module).
  #
  # Ctrl is never touched, so Ctrl+C stays SIGINT in the terminal. A lone Super
  # tap still reaches the compositor (only Super+<key> chords are grabbed).
  services.xremap = {
    enable = true;
    withWlroots = true; # Sway window-class detection (upstream-recommended over withSway)
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

  # ── Sway (Wayland compositor) ───────────────────────────────────────────────
  # The compositor binary + its GL/seat-level companions (swaybg, wofi, …) are
  # apt-installed by ansible/pro.yml — same boundary as docker/chrome: anything
  # touching DRM/GL/logind is system-level, not nix. So here `package = null`:
  # home-manager owns ~/.config/sway/config only and the system Sway runs it.
  # Pick "Sway" at the GDM login screen after the ansible run.
  #
  # Key split (see the xremap notes above): xremap eats Super+<letter|arrow> at
  # the evdev layer for the macOS edit cluster, so Sway never sees those — every
  # binding below deliberately avoids them. Window management is Ctrl+Alt+arrows
  # (mirrors Rectangle on the Mac); those chords aren't in the keymap, so xremap
  # passes them straight through to Sway.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the apt-installed Sway; HM just writes the config
    # systemd.enable (default) injects the `systemctl --user import-environment`
    # exec → WAYLAND_DISPLAY etc. reach the user bus, so the xremap service
    # (wantedBy graphical-session.target) starts with a working environment.
    systemd.enable = true;
    checkConfig = false; # can't validate without a Sway package in the build
    config = let
      mod = "Mod4"; # Super
      kitty = "${config.programs.kitty.package}/bin/kitty"; # nixGL-wrapped
      ws = builtins.genList (i: toString (i + 1)) 9; # ["1".."9"]
    in {
      modifier = mod;
      terminal = kitty;
      menu = "wofi --show drun";

      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };

      # Per-host wallpaper (path literal → copied into the nix store).
      output."*".bg = "${../../wallpapers/pro-wallpaper.avif} fill";

      # Minimal built-in bar (no waybar dep): clock via a shell status loop.
      bars = [{
        position = "top";
        statusCommand = "while date +'%Y-%m-%d  %H:%M'; do sleep 20; done";
      }];

      # Full, explicit set (replaces HM's defaults, which bind Super+arrows /
      # Super+hjkl — both pointless here since xremap grabs them first).
      keybindings = {
        "${mod}+Return" = "exec ${kitty}";
        "${mod}+d" = "exec wofi --show drun";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" =
          "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";

        # Window management — Ctrl+Alt+arrows focus, +Shift moves the window.
        "Ctrl+Mod1+Left" = "focus left";
        "Ctrl+Mod1+Down" = "focus down";
        "Ctrl+Mod1+Up" = "focus up";
        "Ctrl+Mod1+Right" = "focus right";
        "Ctrl+Mod1+Shift+Left" = "move left";
        "Ctrl+Mod1+Shift+Down" = "move down";
        "Ctrl+Mod1+Shift+Up" = "move up";
        "Ctrl+Mod1+Shift+Right" = "move right";

        # Layout / window state (Super+f is taken by xremap → use Shift).
        "${mod}+Shift+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+b" = "splith";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        # Desktops — Super+N jumps, Super+Shift+N sends the window there,
        # Ctrl+Alt+[ / ] cycle (Spaces-like).
        "Ctrl+Mod1+bracketleft" = "workspace prev";
        "Ctrl+Mod1+bracketright" = "workspace next";
      } // builtins.listToAttrs (builtins.concatMap (n: [
        { name = "${mod}+${n}"; value = "workspace number ${n}"; }
        { name = "${mod}+Shift+${n}"; value = "move container to workspace number ${n}"; }
      ]) ws);
    };
  };

  # GNOME / Ubuntu Dock — pro only (this file is imported solely by mkHome "pro")
  # NB: left for a GNOME fallback session; under Sway none of this applies and
  # xremap no longer uses the GNOME extension (window detection is wlroots-native).
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
      picture-uri = "file://${../../wallpapers/pro-wallpaper.avif}";
      picture-uri-dark = "file://${../../wallpapers/pro-wallpaper.avif}";
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

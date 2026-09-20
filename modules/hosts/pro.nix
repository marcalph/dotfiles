{ config, pkgs, inputs, lib, ... }:
let
  # shared with the desktop entry below, which needs an absolute Exec into it
  foliate = config.lib.nixGL.wrap pkgs.foliate;
  steam = config.lib.nixGL.wrap pkgs.steam;
  # apt-provided, like sway itself: swaylock authenticates through PAM, and the
  # Ubuntu package is what ships /etc/pam.d/swaylock. A nix swaylock has no PAM
  # file here, so it would refuse every password and lock you out of the
  # session. swaymsg must match the running apt sway 1.9.
  swaylock = "/usr/bin/swaylock";
  swaymsg = "/usr/bin/swaymsg";
in
{
  # Bar, tray applets, notifications and launcher skin for the sway session.
  imports = [ ../home/sway-shell.nix ];

  # pro is the work machine → override the shared personal git identity
  # (modules/home/git.nix) with the harmattan one, for this host only.
  programs.git.settings.user.name = lib.mkForce "marc-alphonsus";
  programs.git.settings.user.email = lib.mkForce "marc.alphonsus@harmattan.ai";

  # make kitty etc. show up in the ubuntu app grid
  targets.genericLinux.enable = true;

  # GDM runs sway straight from /usr/share/wayland-sessions, so no shell profile
  # is read and the session PATH keeps only the system dirs. environment.d is
  # the one env file that session does read — targets.genericLinux already puts
  # XDG_DATA_DIRS there — so PATH goes there too. Without it wofi hides every
  # nix app whose .desktop has a bare `TryExec` (zed) and fails to start the
  # ones with a bare `Exec` (vscode), because neither name resolves.
  systemd.user.sessionVariables.PATH = "${config.home.profileDirectory}/bin\${PATH:+:$PATH}";

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";
  programs.kitty.package = config.lib.nixGL.wrap pkgs.kitty;

  # Zed draws through blade/Vulkan. Unwrapped it fails like rerun does (see
  # modules/home/packages.nix): Nix's vulkan-loader finds only Ubuntu's ICD
  # manifests, whose library_path is a bare soname that Nix's ld.so never
  # resolves, so the renderer gets zero backends. nixGL puts Nix's own Mesa on
  # LD_LIBRARY_PATH. wrap keeps share/, so the .desktop entry survives.
  programs.zed-editor.package = config.lib.nixGL.wrap pkgs.zed-editor;

  # nixGL wraps kitty by exporting an LD_LIBRARY_PATH full of Nix's Mesa +
  # libglvnd so the Nix-built kitty can reach Ubuntu's GPU. But kitty is a
  # terminal, so that env is inherited by everything launched from it — and
  # Nix's vendor-neutral libglvnd then shadows the *system* GL of non-Nix apps
  # started from the shell, aborting their GLX init (e.g. the /opt/serval Qt6
  # app: "Could not initialize GLX" → SIGABRT). Reset it for kitty's children so
  # they load Ubuntu's GL like any normal terminal. Nix GUI apps launched from
  # here re-establish their own GL via their own nixGL wrappers, so this is safe.
  programs.kitty.extraConfig = "env LD_LIBRARY_PATH=";

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
    # GTK4 + WebKitGTK: same EGL-init failure as obsidian unwrapped. No symlinkJoin
    # needed — nixGL.wrap keeps share/, so the .desktop and icons survive.
    foliate
    # Drag-and-drop output layout, the GNOME "Displays" equivalent for wlroots.
    (config.lib.nixGL.wrap pkgs.wdisplays)
    # Steam needs nixGL for the same reason: GPU process fails EGL init without it.
    # The Nix-built steam finds Ubuntu's GL/EGL drivers via LD_LIBRARY_PATH.
    steam
    # Ansible owns pro's system layer (daemons/OS config) — run against localhost.
    # See ansible/pro.yml. ansible itself is a client tool → nix; the daemons it
    # installs (docker, …) are apt/system-level.
    pkgs.ansible
    pkgs.ansible-lint
  ];

  # Upstream ships a bare `Exec=foliate`, resolved via PATH — an apt/snap foliate
  # ahead of ~/.nix-profile/bin would launch unwrapped and die on EGL init. Pin it
  # to the wrapped store path. hiPrio, so it shadows rather than duplicates.
  xdg.desktopEntries."com.github.johnfactotum.Foliate" = {
    name = "Foliate";
    genericName = "E-Book Viewer";
    comment = "Read e-books in style";
    exec = "${foliate}/bin/foliate %U";
    icon = "com.github.johnfactotum.Foliate";
    terminal = false;
    type = "Application";
    categories = [ "Office" "Viewer" ];
    startupNotify = true;
    mimeType = [
      "application/epub+zip"
      "application/x-mobipocket-ebook"
      "application/vnd.amazon.mobi8-ebook"
      "application/x-fictionbook+xml"
      "application/x-zip-compressed-fb2"
      "application/vnd.comicbook+zip"
      "x-scheme-handler/opds"
    ];
    settings.Keywords = "Ebook;Book;EPUB;Viewer;Reader;";
  };

  # ── Sway (Wayland compositor) ───────────────────────────────────────────────
  # The compositor binary + its GL/seat-level companions (swaybg, wofi, …) are
  # apt-installed by ansible/pro.yml — same boundary as docker/chrome: anything
  # touching DRM/GL/logind is system-level, not nix. So here `package = null`:
  # home-manager owns ~/.config/sway/config only and the system Sway runs it.
  # Pick "Sway" at the GDM login screen after the ansible run.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the apt-installed Sway; HM just writes the config
    # systemd.enable (default) injects the `systemctl --user import-environment`
    # exec → WAYLAND_DISPLAY etc. reach the user bus, so user services that want
    # graphical-session.target start with a working environment.
    systemd.enable = true;
    checkConfig = false; # can't validate without a Sway package in the build
    config = let
      mod = "Mod4"; # Super
      kitty = "${config.programs.kitty.package}/bin/kitty"; # nixGL-wrapped
    in {
      modifier = mod;
      terminal = kitty;
      menu = "wofi --show drun";

      # Same font and palette as kitty and waybar (Solarized Dark). A border
      # replaces the titlebar, because the bar shows the window name.
      fonts = { names = [ "Hack Nerd Font" ]; size = 10.0; };
      gaps = { inner = 8; outer = 2; smartBorders = "on"; };
      window = { border = 2; titlebar = false; };
      floating = { border = 2; titlebar = false; };
      colors = {
        focused = { border = "#268bd2"; background = "#268bd2"; text = "#002b36"; indicator = "#2aa198"; childBorder = "#268bd2"; };
        focusedInactive = { border = "#073642"; background = "#073642"; text = "#93a1a1"; indicator = "#073642"; childBorder = "#073642"; };
        unfocused = { border = "#002b36"; background = "#002b36"; text = "#586e75"; indicator = "#002b36"; childBorder = "#002b36"; };
        urgent = { border = "#dc322f"; background = "#dc322f"; text = "#fdf6e3"; indicator = "#dc322f"; childBorder = "#dc322f"; };
      };

      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };

      # Mice and the trackpoint run far too fast at libinput's default 0.
      # Range is -1 (slowest) to 1; the touchpad above keeps its own default.
      input."type:pointer".pointer_accel = "-0.4";

      # Per-host wallpaper (path literal → copied into the nix store).
      output."*".bg = "${../../wallpapers/pro-wallpaper.avif} fill";

      # This file sets no output position, so a `swaymsg reload` makes sway
      # arrange the outputs left to right again and undo kanshi. kanshi only
      # reacts to a plug event, so it never sees the reload. always = true
      # runs this on every reload, and kanshi puts the layout back.
      startup = [
        { command = "systemctl --user restart kanshi.service"; always = true; }
      ];

      # No swaybar. HM derives `swaybar_command` from its own sway package even
      # when `package = null`, so the bar block pulled a whole nix sway 1.12
      # into the closure and ran its bar against the apt sway 1.9. waybar
      # replaces it, so the mismatch goes away with the block.
      bars = [ ];

      # No keybindings attr: home-manager's sway defaults apply (Super+Return
      # terminal, Super+d menu, Super+arrows and Super+hjkl focus, Super+Shift+q
      # kill, Super+1..9 workspaces). Nothing grabs Super before sway now.
    };
    # Appended, so it adds keys instead of replacing the defaults above.
    # Sway binds no laptop hardware key. GNOME did that before. wpctl comes
    # with pipewire. brightnessctl, grim and slurp come from apt
    # (ansible/pro.yml). --locked keeps volume and brightness usable while the
    # screen is locked.
    extraConfig = ''
      bindsym Mod4+Ctrl+l exec ${swaylock} -f
      bindsym --locked XF86AudioRaiseVolume exec /usr/bin/wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      bindsym --locked XF86AudioLowerVolume exec /usr/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindsym --locked XF86AudioMute exec /usr/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym --locked XF86AudioMicMute exec /usr/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindsym --locked XF86MonBrightnessUp exec /usr/bin/brightnessctl set 5%+
      bindsym --locked XF86MonBrightnessDown exec /usr/bin/brightnessctl set 5%-
      bindsym Print exec /usr/bin/grim -g "$(/usr/bin/slurp)" - | /usr/bin/wl-copy
    '';
  };

  # Bar and notifications are in modules/home/sway-shell.nix. The idle watcher
  # below is the third thing a GNOME session gave for free.

  # Output layout per set of connected screens
  services.kanshi = {
    enable = true;
    profiles = {
      undocked.outputs = [
        { criteria = "eDP-1"; position = "0,0"; status = "enable"; }
      ];
      # External on top, laptop below it, centred: x = (ext width - 1920) / 2
      docked.outputs = [
        { criteria = "Dell Inc. DELL S3425DW 9RLSR44"; position = "0,0"; }
        { criteria = "eDP-1"; position = "760,1440"; status = "enable"; }
      ];
      home.outputs = [
        { criteria = "ASUSTek COMPUTER INC VY279HGR T7LMTF133369"; position = "0,0"; }
        { criteria = "eDP-1"; position = "0,1080"; status = "enable"; }
      ];
    };
  };

  # swayidle decides when, swaylock is what it runs. Without the pair the
  # screen never locks, not on idle and not on lid close.
  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = "${swaylock} -f"; }
      {
        timeout = 600;
        command = "${swaymsg} 'output * power off'";
        resumeCommand = "${swaymsg} 'output * power on'";
      }
    ];
    events = [ { event = "before-sleep"; command = "${swaylock} -f"; } ];
  };

  # GNOME / Ubuntu Dock — pro only (this file is imported solely by mkHome "pro")
  # NB: left for a GNOME fallback session; under Sway none of this applies.
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "google-chrome.desktop"
        "code.desktop"
        "obsidian.desktop"
        "bitwarden.desktop"
        "kitty.desktop"
        "dev.zed.Zed.desktop"
      ];
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

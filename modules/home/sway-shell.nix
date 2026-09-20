{ pkgs, lib, ... }:
# The sway session shell: bar, tray applets, notifications, launcher skin.
# Imported by modules/hosts/pro.nix only (the one sway host), not by
# modules/home/default.nix, which every host reads.
#
# The colours below are Solarized Dark, the kitty palette
# (modules/home/kitty.nix). Terminal and bar then use one set of colours.
let
  # apt binaries (ansible/pro.yml). Each one talks to a system daemon on the
  # system bus, the same boundary sway itself is on. Two more reasons:
  #  - blueman also registers a root D-Bus mechanism, because the bluetooth
  #    on/off switch writes rfkill. A nix blueman puts that service file in the
  #    nix profile. The system bus does not read there, so the switch fails.
  #  - nm-applet is the only GUI that scans for wifi networks.
  #    nm-connection-editor edits saved connections and cannot scan.
  bluemanManager = "/usr/bin/blueman-manager";
  bluemanApplet = "/usr/bin/blueman-applet";
  nmApplet = "/usr/bin/nm-applet";
  nmEditor = "/usr/bin/nm-connection-editor";
  swaylock = "/usr/bin/swaylock";
  wpctl = "/usr/bin/wpctl"; # pipewire is the audio server on pro
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
in
{
  # Audio mixer. It is GTK3 and uses no GPU path, so it needs no nixGL wrap.
  home.packages = [ pkgs.pavucontrol ];

  programs.waybar = {
    enable = true;
    systemd.enable = true; # starts with graphical-session.target

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      # keep the bar off the screen edges
      margin-top = 6;
      margin-left = 10;
      margin-right = 10;

      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "sway/window" ];
      modules-right = [
        "tray"
        "pulseaudio"
        "bluetooth"
        "network"
        "backlight"
        "battery"
        "clock"
        "custom/lock"
      ];

      "sway/workspaces".format = "{name}";
      "sway/window" = {
        format = "{title}";
        max-length = 60;
      };

      # Holds the nm-applet and blueman-applet icons. Click one for the wifi
      # list or the bluetooth device menu.
      tray = {
        icon-size = 16;
        spacing = 10;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = pavucontrol;
      };

      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-connected = "󰂱 {num_connections}";
        tooltip-format = "{controller_alias}\n{num_connections} connected";
        on-click = bluemanManager;
      };

      network = {
        format-wifi = "󰖩 {signalStrength}%";
        format-ethernet = "󰈀";
        format-disconnected = "󰖪";
        tooltip-format-wifi = "{essid}\n{ipaddr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
        on-click = nmEditor;
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [ "󰃞" "󰃟" "󰃠" ];
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹" ];
        tooltip-format = "{timeTo}";
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%a %d %b}"; # a click swaps the two
        tooltip-format = "<tt>{calendar}</tt>";
      };

      "custom/lock" = {
        format = "󰌾";
        tooltip = false;
        on-click = "${swaylock} -f";
      };
    };

    style = ''
      * {
        font-family: "Hack Nerd Font", monospace;
        font-size: 13px;
        border: none;
        min-height: 0;
      }

      /* the bar itself stays invisible; each group is its own floating pill */
      window#waybar {
        background: transparent;
        color: #93a1a1;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: rgba(0, 43, 54, 0.92); /* base03, translucent */
        border-radius: 14px;
        padding: 0 6px;
      }

      #workspaces button {
        padding: 0 10px;
        margin: 4px 2px;
        color: #586e75;
        background: transparent;
        border-radius: 10px;
      }

      #workspaces button.focused,
      #workspaces button.visible {
        background: #268bd2;
        color: #002b36;
      }

      #workspaces button.urgent {
        background: #dc322f;
        color: #fdf6e3;
      }

      #workspaces button:hover {
        background: #073642;
        color: #93a1a1;
        text-shadow: none;
        box-shadow: none;
      }

      #mode,
      #window,
      #tray,
      #pulseaudio,
      #bluetooth,
      #network,
      #backlight,
      #battery,
      #clock,
      #custom-lock {
        padding: 0 10px;
        margin: 4px 0;
      }

      #clock {
        color: #eee8d5;
        font-weight: bold;
      }

      #mode {
        color: #b58900;
      }

      #battery {
        color: #859900;
      }

      #battery.charging {
        color: #2aa198;
      }

      #battery.warning {
        color: #b58900;
      }

      #battery.critical {
        color: #dc322f;
      }

      #network.disconnected,
      #bluetooth.disabled,
      #pulseaudio.muted {
        color: #586e75;
      }

      #custom-lock:hover,
      #bluetooth:hover,
      #network:hover,
      #pulseaudio:hover {
        color: #268bd2;
      }

      tooltip {
        background: #073642;
        border: 1px solid #586e75;
        border-radius: 8px;
      }

      #tray menu {
        background: #073642;
        color: #93a1a1;
      }
    '';
  };

  # The two applets are the UI you click. The waybar network and bluetooth
  # modules only read state. HM has services.network-manager-applet and
  # services.blueman-applet, but each one runs its own nix package. Both
  # binaries must be the apt ones (see the let block), so these units run them.
  systemd.user.services = lib.mapAttrs (name: exec: {
    Unit = {
      Description = "tray applet ${name}";
      Requires = [ "tray.target" ];
      After = [ "graphical-session.target" "tray.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service.ExecStart = exec;
    Install.WantedBy = [ "graphical-session.target" ];
  }) {
    # --indicator: waybar is the tray, and it shows StatusNotifierItem icons
    # only. nm-applet uses the older GtkStatusIcon protocol by default.
    nm-applet = "${nmApplet} --indicator";
    blueman-applet = bluemanApplet;
  };

  services.mako = {
    enable = true; # notification popups; sway has none built in
    settings = {
      font = "Hack Nerd Font 11";
      background-color = "#002b36f2";
      text-color = "#93a1a1";
      border-color = "#268bd2";
      border-size = 2;
      border-radius = 12;
      padding = "12";
      margin = "12";
      default-timeout = 6000;
      anchor = "top-right";
    };
  };

  programs.wofi = {
    enable = true;
    package = null; # apt wofi (ansible/pro.yml); HM writes the config only
    settings = {
      show = "drun";
      width = 520;
      height = 420;
      prompt = "";
      insensitive = true;
      allow_images = true;
      image_size = 28;
    };
    style = ''
      window {
        background: rgba(0, 43, 54, 0.96);
        border: 2px solid #268bd2;
        border-radius: 14px;
        font-family: "Hack Nerd Font", monospace;
        font-size: 13px;
      }

      #input {
        margin: 8px;
        padding: 8px;
        border: none;
        border-radius: 10px;
        background: #073642;
        color: #93a1a1;
      }

      #inner-box,
      #outer-box,
      #scroll {
        margin: 4px;
        background: transparent;
      }

      #entry {
        padding: 8px;
        border-radius: 10px;
      }

      #entry:selected {
        background: #268bd2;
      }

      #text {
        color: #93a1a1;
      }

      #entry:selected #text {
        color: #002b36;
        font-weight: bold;
      }
    '';
  };
}

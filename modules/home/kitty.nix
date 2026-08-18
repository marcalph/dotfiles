{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "Hack Nerd Font Mono";
      size = 14;
    };
    settings = {
      # Window
      window_padding_width = 8;
      hide_window_decorations = "titlebar-only";
      confirm_os_window_close = 0;

      # Tabs
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0;

      # Scrollback
      scrollback_lines = 10000;

      # Bell
      enable_audio_bell = false;
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      macos_option_as_alt = true;
      macos_quit_when_last_window_closed = true;
    };
    keybindings = {
      # Splits
      "cmd+d" = "launch --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --location=hsplit --cwd=current";
      "cmd+w" = "close_window";

      # Navigate splits
      "cmd+left" = "neighboring_window left";
      "cmd+right" = "neighboring_window right";
      "cmd+up" = "neighboring_window up";
      "cmd+down" = "neighboring_window down";

      # Resize splits
      "cmd+shift+left" = "resize_window narrower";
      "cmd+shift+right" = "resize_window wider";
      "cmd+shift+up" = "resize_window taller";
      "cmd+shift+down" = "resize_window shorter";

      # Tabs
      "cmd+t" = "new_tab_with_cwd";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
    } // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      # Linux: cmd → super (macOS uses cmd natively, Linux uses Super key)
      "super+d" = "launch --location=vsplit --cwd=current";
      "super+shift+d" = "launch --location=hsplit --cwd=current";
      "super+w" = "close_window";
      "super+left" = "neighboring_window left";
      "super+right" = "neighboring_window right";
      "super+up" = "neighboring_window up";
      "super+down" = "neighboring_window down";
      "super+shift+left" = "resize_window narrower";
      "super+shift+right" = "resize_window wider";
      "super+shift+up" = "resize_window taller";
      "super+shift+down" = "resize_window shorter";
      "super+t" = "new_tab_with_cwd";

      # Clipboard
      "super+c" = "copy_to_clipboard";
      "super+v" = "paste_from_clipboard";
      "super+x" = "copy_to_clipboard";
    };
    themeFile = "Solarized_Dark";
  };
}

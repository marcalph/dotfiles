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
    # kitty's own defaults stay active next to the set below; kitty_mod is
    # ctrl+shift, and none of these chords collide with the super+* set here.
    # Read from kitty 0.47.4 lib/kitty/kitty/options/definition.py.
    #   clipboard  kitty_mod+c copy, +v paste, +s paste selection (or shift+insert),
    #              +o pass selection to a program
    #   scroll     kitty_mod+up/down or +k/+j line, +page_up/+page_down page,
    #              +home/+end ends, +z/+x previous/next shell prompt,
    #              +h scrollback in pager, +g last command output, +/ search
    #   window     kitty_mod+enter new, +n new OS window, +w close, +]/+[ cycle,
    #              +f/+b move forward/back, +` move to top, +r resize mode,
    #              +1..+0 focus Nth, +f7 pick one, +f8 swap two
    #   tab        kitty_mod+right/+left or ctrl+tab / ctrl+shift+tab cycle,
    #              +t new, +q close, +. / +, move, +alt+t set title
    #   layout     kitty_mod+l next layout
    #   font       kitty_mod+equal or +plus bigger, +minus smaller,
    #              +backspace reset
    #   selection  kitty_mod+e open URL, then kitty_mod+p> prefixed: f/shift+f
    #              selected path, c/d chosen file or directory, l line, w word,
    #              h hash, n file at line, y hyperlink
    #   misc       kitty_mod+f1 docs, +f2 edit config, +f3 command palette,
    #              +f5 reload config, +f6 debug config, +f10 maximize,
    #              +f11 fullscreen, +u unicode input, +escape kitty shell,
    #              +delete reset terminal, +a> then m/l/1/d background opacity
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

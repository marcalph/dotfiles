{ pkgs, ... }:

{
  programs.autojump.enable = true;
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = false;
  programs.ripgrep.enable = true;
  programs.direnv.enable = true;
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;

  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.envExtra = "";
  programs.zsh.history.ignoreDups = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.shellAliases = {
    cat = "bat";
    cp = "cp -iv";
    d = "dirs -v";
    diff = "diff -yw --color=always";
    ll = "eza -hailF --icons";
    ls = "eza --grid --icons";
    tree = "eza --tree --icons";
    ga = "git add .";
    gc = "git commit";
    gl = "git log --oneline --decorate --graph";
    gs = "git status | head -n 2; exa --git -l";
    mv = "mv -iv";
    projects = "cd $HOME/Projects";
    rm = "rm -iv";
  };
  programs.zsh.dirHashes = {
    docs = "$HOME/Documents";
    vids = "$HOME/Videos";
    dl   = "$HOME/Downloads";
  };
  programs.zsh.initContent = ''
    setopt AUTO_PUSHD           # Push the current directory visited on the stack.
    setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
    setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

    for index ({1..9}) alias "$index"="cd +$index"; unset index

    export PATH=~/.cargo/bin:~/.local/bin:/usr/local/bin:$PATH
    export XDG_CONFIG_HOME="$HOME/.config"

    autoload -Uz compinit
    compinit

    compdef eza=ls

    export PYTHON_CONFIGURE_OPTS="--with-lzma --enable-shared"
    # Tcl/Tk paths for Python tkinter support
    export TCL_LIBRARY="${pkgs.tcl}/lib/tcl8.6"
    export TK_LIBRARY="${pkgs.tk}/lib/tk8.6"

    # Initialize pay-respects for command correction
    eval "$(${pkgs.pay-respects}/bin/pay-respects zsh)"

    # Enable file path completion for uv commands
    zstyle ':completion:*:*:uv:*' file-patterns '*'

    # tty1-only sway autostart (tower); Macs and SSH sessions are unaffected.
    if [ "$(tty)" = "/dev/tty1" ] && [ -z "$WAYLAND_DISPLAY" ] && command -v sway >/dev/null; then
      exec sway
    fi
  '';
}

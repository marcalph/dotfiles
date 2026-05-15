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
    if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
      source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
    setopt AUTO_PUSHD           # Push the current directory visited on the stack.
    setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
    setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

    for index ({1..9}) alias "$index"="cd +$index"; unset index

    export PATH=~/.cargo/bin:~/.local/bin:/usr/local/bin:$PATH
    export XDG_CONFIG_HOME="$HOME/.config"



    autoload -Uz compinit
    compinit

    compdef eza=ls
    compdef eza=ll

    export LDFLAGS="-L${pkgs.xz}/lib -L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib -L${pkgs.postgresql}/lib -L${pkgs.tcl}/lib -L${pkgs.tk}/lib"
    export CPPFLAGS="-I${pkgs.xz}/include -I${pkgs.zlib}/include -I${pkgs.openssl.out}/include -I${pkgs.postgresql}/include -I${pkgs.tcl}/include -I${pkgs.tk}/include"
    export PKG_CONFIG_PATH="${pkgs.xz}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.openssl.out}/lib/pkgconfig:${pkgs.postgresql}/lib/pkgconfig:${pkgs.tcl}/lib/pkgconfig:${pkgs.tk}/lib/pkgconfig"
    export PYTHON_CONFIGURE_OPTS="--with-lzma --enable-shared"
    # Tcl/Tk paths for Python tkinter support
    export TCL_LIBRARY="${pkgs.tcl}/lib/tcl8.6"
    export TK_LIBRARY="${pkgs.tk}/lib/tk8.6"

    # Initialize pay-respects for command correction
    eval "$(pay-respects zsh)"

    # Enable file path completion for uv commands
    zstyle ':completion:*:*:uv:*' file-patterns '*'

  '';
}

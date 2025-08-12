{ config, pkgs, lib, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      magic-wormhole
      google-cloud-sql-proxy
      google-cloud-sdk
      speedtest-cli
      poppler_utils
      python313
      uv
      ngrok
      pkgs.nerd-fonts.hack
      shellcheck
      pay-respects
      jq
      pre-commit
      tldr
      ranger
      diesel-cli
      pkg-config
      turbo
      readline
      poetry
      openssl
      openssl.dev
      zlib
      xz
      zulu
      nodejs
      nodePackages.pnpm
      rustup
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      # Critical build flags for Python packages requiring C extensions
      LDFLAGS = "-L${pkgs.openssl.out}/lib -L${pkgs.zlib}/lib -L${pkgs.xz}/lib";
      CPPFLAGS = "-I${pkgs.openssl.out}/include -I${pkgs.zlib}/include -I${pkgs.xz}/include";
      PKG_CONFIG_PATH = "${pkgs.openssl.out}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.xz}/lib/pkgconfig";
    };
    
  };
  fonts.fontconfig.enable = true;
  programs.autojump.enable = true;
  programs.bat.enable = true;
  programs.bat.config.theme = "TwoDark";
  programs.eza.enable = true;
  programs.eza.enableZshIntegration = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = false;
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "marcalph";
    userEmail = "marcalph#protonmail.com";
    ignores = [
      "CLAUDE.md"
      "TODO.md"
    ];
  };
  programs.neovim.enable = true;
  programs.ripgrep.enable = true;
  programs.direnv.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestion.enable = true;
  programs.zsh.envExtra = "";
  programs.zsh.history.ignoreDups = true;
  # programs.zsh.autosuggestion.enable =  true;
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
    docs  = "$HOME/Documents";
    vids  = "$HOME/Videos";
    dl    = "$HOME/Downloads";
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

    export PATH=~/.local/bin:/usr/local/bin:$PATH
    export XDG_CONFIG_HOME="$HOME/.config"



    autoload -Uz compinit
    compinit
    
    compdef eza=ls
    compdef eza=ll

    export LDFLAGS="-L${pkgs.xz}/lib -L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib"
    export CPPFLAGS="-I${pkgs.xz}/include -I${pkgs.zlib}/include -I${pkgs.openssl.out}/include"
    export PKG_CONFIG_PATH="${pkgs.xz}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.openssl.out}/lib/pkgconfig"
    export PYTHON_CONFIGURE_OPTS="--with-lzma --enable-shared"

    # Initialize pay-respects for command correction
    eval "$(pay-respects zsh)"

  '';
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  # home.file.".inputrc".source = ./dotfiles/inputrc;

}
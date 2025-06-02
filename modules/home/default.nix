{ config, pkgs, lib, ... }:

{
  # imports = [
  #   ./nvim.nix
  #   ./tmux.nix
  #   ./git.nix
  #   ./wezterm.nix
  # ];
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    stateVersion = "24.11"; # Please read the comment before changing.
    # home.packages option allows install of nix packages user profile
    packages = with pkgs; [
      # gcloud utils
      google-cloud-sql-proxy
      google-cloud-sdk
      speedtest-cli
      # db
      postgresql
      # random tools
      poppler
      python313
      uv
      ngrok
      (pkgs.nerdfonts.override { fonts = [ "Hack"]; })
      shellcheck
      thefuck
      jq
      pre-commit
      tldr
      ranger
      diesel-cli
      pkg-config
      turbo
      readline
      poetry
      # code
      zulu  # aarch64-darwin compatible openjdk
      nodejs
      nodePackages.pnpm
      rustup
    ];
    # Required to get the fonts installed by home-manager to be picked up by OS.
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
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
  };
  programs.neovim.enable = true;
  programs.ripgrep.enable = true;
  programs.direnv.enable = true;
  programs.thefuck.enableZshIntegration = true;
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
    nixswitch = "darwin-rebuild switch --flake flake.nix";
  };
  # todo(marcalph): fix this
  programs.zsh.dirHashes = {
    docs  = "$HOME/Documents";
    vids  = "$HOME/Videos";
    dl    = "$HOME/Downloads";
  };
  programs.zsh.initExtra = ''
    setopt AUTO_PUSHD           # Push the current directory visited on the stack.
    setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
    setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.    

    for index ({1..9}) alias "$index"="cd +$index"; unset index

    export PATH=~/.local/bin:/usr/local/bin:$PATH
    export XDG_CONFIG_HOME="$HOME/.config"


    eval $(thefuck --alias)

    # Enable compinit and compdef
    autoload -Uz compinit
    compinit
    
    # Bind aliases to their original commands
    compdef eza=ls
    compdef eza=ll

    # ensure pyenv builds Python with xz/lzma support
    # export LDFLAGS="-L${pkgs.xz}/lib -L${pkgs.zlib}/lib"
    # export CPPFLAGS="-I${pkgs.xz}/include -I${pkgs.zlib}/include"
    # export PKG_CONFIG_PATH="${pkgs.xz}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig"
    # export PYTHON_CONFIGURE_OPTS="--with-lzma --enable-shared"

  '';
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  # home.file.".inputrc".source = ./dotfiles/inputrc;

}
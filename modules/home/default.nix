{ config, pkgs, lib, ... }:

{
  # imports = [
  #   ./nvim.nix
  #   ./tmux.nix
  #   ./git.nix
  #   ./wezterm.nix
  # ];

  home = {
    stateVersion = "24.05"; # Please read the comment before changing.
    # home.packages option allows install of nix packages user profile
    packages = with pkgs; [
      # gcloud utils
      google-cloud-sql-proxy
      google-cloud-sdk
      speedtest-cli
      # db
      postgresql
      mysql
      ffmpeg_5
      shellcheck
      tldr
      cargo-binstall
      ranger
      (pkgs.nerdfonts.override { fonts = [ "Hack"]; })
      rustup
      jq
      thefuck
      nodejs
      nodePackages.pnpm
      turbo
      pre-commit
      poetry
      pyenv # used to define a global default python version w/ std tooling i.e. pipx installed poetry
      xz
      readline
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
  # programs.eza.enableZshIntegration = true;
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
  programs.git.enable = true;
  programs.neovim.enable = true;
  programs.ripgrep.enable = true;
  programs.direnv.enable = true;
  programs.thefuck.enableZshIntegration = true;
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  # programs.zsh.autosuggestion.enable = true;
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

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    export PATH=~/.local/bin:$PATH
    eval $(thefuck --alias)
  '';
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  # home.file.".inputrc".source = ./dotfiles/inputrc;

}
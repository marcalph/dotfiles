{ config, pkgs, lib, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      anki-bin
      magic-wormhole
      google-cloud-sql-proxy
      google-cloud-sdk
      speedtest-cli
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
      postgresql
      openssl
      openssl.dev
      zlib
      xz
      zulu
      nodejs
      nodePackages.pnpm
      rustup
      graphviz
      # anki package is broken, using anki-bin instead
      anki-bin
      #whatsapp-for-mac
      rectangle
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      # Critical build flags for Python packages requiring C extensions
      LDFLAGS = "-L${pkgs.openssl.out}/lib -L${pkgs.zlib}/lib -L${pkgs.xz}/lib -L${pkgs.postgresql}/lib";
      CPPFLAGS = "-I${pkgs.openssl.out}/include -I${pkgs.zlib}/include -I${pkgs.xz}/include -I${pkgs.postgresql}/include";
      PKG_CONFIG_PATH = "${pkgs.openssl.out}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.xz}/lib/pkgconfig:${pkgs.postgresql}/lib/pkgconfig";
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
    extraConfig = {
      init.defaultBranch = "main";
    };
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

    export LDFLAGS="-L${pkgs.xz}/lib -L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib -L${pkgs.postgresql}/lib"
    export CPPFLAGS="-I${pkgs.xz}/include -I${pkgs.zlib}/include -I${pkgs.openssl.out}/include -I${pkgs.postgresql}/include"
    export PKG_CONFIG_PATH="${pkgs.xz}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.openssl.out}/lib/pkgconfig:${pkgs.postgresql}/lib/pkgconfig"
    export PYTHON_CONFIGURE_OPTS="--with-lzma --enable-shared"

    # Initialize pay-respects for command correction
    eval "$(pay-respects zsh)"

    # Enable file path completion for uv commands
    zstyle ':completion:*:*:uv:*' file-patterns '*'

  '';
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  # home.file.".inputrc".source = ./dotfiles/inputrc;

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        bbenoist.nix
        hashicorp.terraform
        hashicorp.hcl
        ms-azuretools.vscode-docker
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-toolsai.jupyter-renderers
        ms-vsliveshare.vsliveshare
        tamasfe.even-better-toml
        eamodio.gitlens
        gruntfuggly.todo-tree
        mechatroner.rainbow-csv
        eriklynd.json-tools
        pomdtr.excalidraw-editor
        bierner.markdown-mermaid
      ];
      userSettings = {
        "update.mode" = "none";
        "terminal.integrated.fontFamily" = "Hack Nerd Font Mono";
        "editor.fontFamily" = "Menlo, Monaco, 'Courier New', monospace";
        "files.autoSave" = "afterDelay";
        "markdown-preview-enhanced.previewTheme" = "solarized-dark.css";
        "markdown-preview-enhanced.mermaidTheme" = "forest";
        "github.copilot.nextEditSuggestions.enabled" = false;
        "workbench.editor.empty.hint" = "hidden";
        "update.showReleaseNotes" = false;
      };
    };
  };

}
{ config, pkgs, lib, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
  };
  home = {
    stateVersion = "24.11";
    packages = with pkgs; [
      slack
      obsidian
      bitwarden-desktop
      bitwarden-cli
      anki-bin
      magic-wormhole
      google-cloud-sql-proxy
      google-cloud-sdk
      speedtest-cli
      (python313.withPackages (ps: [ ps.tkinter ]))
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
      # Tcl/Tk for Python tkinter support (not bundled with uv's standalone Python)
      tcl
      tk
      # anki package is broken, using anki-bin instead
      anki-bin
      #whatsapp-for-mac
      rectangle
    ];
    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "nvim";
      # Tcl/Tk paths for Python tkinter support
      TCL_LIBRARY = "${pkgs.tcl}/lib/tcl8.6";
      TK_LIBRARY = "${pkgs.tk}/lib/tk8.6";
      # Critical build flags for Python packages requiring C extensions
      LDFLAGS = "-L${pkgs.openssl.out}/lib -L${pkgs.zlib}/lib -L${pkgs.xz}/lib -L${pkgs.postgresql}/lib -L${pkgs.tcl}/lib -L${pkgs.tk}/lib";
      CPPFLAGS = "-I${pkgs.openssl.out}/include -I${pkgs.zlib}/include -I${pkgs.xz}/include -I${pkgs.postgresql}/include -I${pkgs.tcl}/include -I${pkgs.tk}/include";
      PKG_CONFIG_PATH = "${pkgs.openssl.out}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.xz}/lib/pkgconfig:${pkgs.postgresql}/lib/pkgconfig:${pkgs.tcl}/lib/pkgconfig:${pkgs.tk}/lib/pkgconfig";
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
    ignores = [
      "CLAUDE.md"
      "TODO.md"
    ];
    settings = {
      user.name = "marcalph";
      user.email = "marcalph@protonmail.com";
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
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  # home.file.".inputrc".source = ./dotfiles/inputrc;

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # From nixpkgs (more stable)
        bbenoist.nix
        hashicorp.terraform
        ms-azuretools.vscode-docker
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-vsliveshare.vsliveshare
        tamasfe.even-better-toml
        eamodio.gitlens
      ];
      # Marketplace extensions commented out - can re-enable after debugging unzip issue
      # ++ (with pkgs.vscode-marketplace; [
      #   hashicorp.hcl
      #   ms-toolsai.jupyter-keymap
      #   ms-toolsai.jupyter-renderers
      #   gruntfuggly.todo-tree
      #   mechatroner.rainbow-csv
      #   eriklynd.json-tools
      #   pomdtr.excalidraw-editor
      #   bierner.markdown-mermaid
      # ]);
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

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
        privacy-badger
        # captainfact - not in NUR, install manually
        # postlight-reader - not in NUR, install manually
        # tomato-clock - not in NUR, install manually
      ];
      settings = {
        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        # Enable HTTPS-only mode
        "dom.security.https_only_mode" = true;
        # Disable pocket
        "extensions.pocket.enabled" = false;
        # Force English to prevent auto-translated sites
        "intl.accept_languages" = "en-US,en";
        "intl.locale.requested" = "en-US";
        # Auto-enable extensions installed via nix
        "extensions.autoDisableScopes" = 0;
      };
    };
  };

}
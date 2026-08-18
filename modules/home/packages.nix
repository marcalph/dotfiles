{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    remmina
    bitwarden-cli
    magic-wormhole
    google-cloud-sql-proxy
    google-cloud-sdk
    terraform
    ookla-speedtest
    # Python interpreters are managed by uv, not nix: `uv python install 3.12 …`
    # symlinks pythonX.Y into ~/.local/bin (on PATH), so uv and poetry projects
    # pick the version per project (`uv python pin` / `poetry env use 3.12`).
    uv
    ngrok
    pkgs.nerd-fonts.hack
    shellcheck
    pay-respects
    jq
    dotenv-cli
    poetry
    pandoc
    prek # fast Rust reimplementation of pre-commit (reads .pre-commit-config.yaml)
    act # run GitHub Actions workflows locally (needs Docker)
    ghostty # GPU-accelerated terminal emulator
    commitizen # conventional-commit prompt / changelog / version bump (`git cz`)
    worktrunk # git worktree manager for parallel AI-agent workflows
    tldr
    ranger
    diesel-cli
    gnumake
    cmake
    pkg-config
    turbo
    readline
    postgresql
    openssl
    openssl.dev
    zlib
    xz
    zulu
    nodejs
    pnpm
    rustup
    graphviz
    # Tcl/Tk for Python tkinter support (not bundled with uv's standalone Python)
    tcl
    tk
    # Audio/video processing
    ffmpeg-full
    # Viewer for streams of multimodal data (robotics/ML), egui-based. It
    # renders through wgpu, so on pro (Ubuntu, non-NixOS) it needs nixGL like
    # kitty/obsidian do — see modules/hosts/pro.nix. Unwrapped, its Nix
    # vulkan-loader finds only Ubuntu's ICD manifests, whose library_path is a
    # bare soname ("libvulkan_intel.so") that Nix's ld.so never resolves, and
    # there is no libEGL in its closure either → wgpu gets *zero* backends and
    # dies with "Failed to create surface for any enabled backend: {}". The
    # wrapper puts Nix's own Mesa on LD_LIBRARY_PATH, which satisfies both the
    # ICD soname and EGL. No-op on air/tower, where nixGL is unconfigured.
    #
    # nixpkgs builds the native binary with --no-default-features 
    (config.lib.nixGL.wrap (rerun.overrideAttrs (old: {
      cargoBuildFeatures = old.cargoBuildFeatures ++ [ "map_view" ];
      cargoCheckFeatures = old.cargoCheckFeatures ++ [ "map_view" ];
    })))
  ];

  home.sessionVariables = {
    PAGER = "less";
    CLICLOLOR = 1;
    VISUAL = "code --wait";
    EDITOR = "code --wait";
    # Tcl/Tk paths for Python tkinter support
    TCL_LIBRARY = "${pkgs.tcl}/lib/tcl8.6";
    TK_LIBRARY = "${pkgs.tk}/lib/tk8.6";
    # build flags for python c extensions
    LDFLAGS = "-L${pkgs.openssl.out}/lib -L${pkgs.zlib}/lib -L${pkgs.xz}/lib -L${pkgs.postgresql}/lib -L${pkgs.tcl}/lib -L${pkgs.tk}/lib";
    CPPFLAGS = "-I${pkgs.openssl.out}/include -I${pkgs.zlib}/include -I${pkgs.xz}/include -I${pkgs.postgresql}/include -I${pkgs.tcl}/include -I${pkgs.tk}/include";
    PKG_CONFIG_PATH = "${pkgs.openssl.out}/lib/pkgconfig:${pkgs.zlib}/lib/pkgconfig:${pkgs.xz}/lib/pkgconfig:${pkgs.postgresql}/lib/pkgconfig:${pkgs.tcl}/lib/pkgconfig:${pkgs.tk}/lib/pkgconfig";
  };
}

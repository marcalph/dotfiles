{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-cli
    magic-wormhole
    google-cloud-sql-proxy
    google-cloud-sdk
    ookla-speedtest
    (python313.withPackages (ps: [ ps.tkinter ]))
    uv
    ngrok
    pkgs.nerd-fonts.hack
    shellcheck
    pay-respects
    jq
    pandoc
    pre-commit
    tldr
    ranger
    diesel-cli
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

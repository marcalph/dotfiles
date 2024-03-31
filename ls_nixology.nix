let 
  pkgs = import <nixpkgs> {};
  LS_COLORS = pkgs.fetchurl {
    url = "https://github.com/trapd00r/LS_COLORS/blob/a283d79dcbb23a8679f4b1a07d04a80cab01c0ba/LS_COLORS";
    sha256 = "042r07rgc3ivmx0gp5vqlcpsj60cf90i161bzww1w8ifvxmz5hpw";
  };
in 
  pkgs.runCommand "ls-colors" {} ''
    mkdir -p $out/bin $out/share
    ln -s ${pkgs.coreutils}/bin/ls $out/bin/ls
    ln -s ${pkgs.coreutils}/bin/dircolors $out/bin/dircolors
    ln -s ${LS_COLORS} $out/share/LS_COLORS
  ''
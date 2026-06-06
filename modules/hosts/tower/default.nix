{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # Per-host wallpaper (placeholder: wallpapers/tower-wallpaper.png). Sway paints
  # the bg via `output * bg`, which spawns swaybg. Dropping the directive in
  # /etc/sway/config.d keeps the stock config + keybindings intact — sway's
  # default config does `include /etc/sway/config.d/*`. Swap the file to change.
  environment.systemPackages = [ pkgs.swaybg ];
  environment.etc."sway/config.d/10-wallpaper.conf".text =
    "output * bg ${../../../wallpapers/tower-wallpaper.png} fill";
}

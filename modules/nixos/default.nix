{ pkgs, lib, inputs, hostname, ... }: {
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = lib.mkDefault hostname;
  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "Europe/Paris";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
    openFirewall = true;
  };

  users.users.marcalph = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "input" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9gfA2oYQo8CcWnSB7gX+1Tjf25lMXdS5cC/Ogi3sSd marcalph@air"
    ];
  };

  programs.zsh.enable = true;

  # No DE / no DM — default boot target becomes multi-user.target.
  programs.sway.enable = true;
  security.polkit.enable = true;
  hardware.graphics.enable = true;

  # Disable every sleep target so nothing can suspend the box.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  services.logind.lidSwitch = "ignore";

  services.getty.autologinUser = "marcalph";

  system.stateVersion = lib.mkDefault "25.11";
}

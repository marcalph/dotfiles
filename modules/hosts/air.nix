{ ... }: {
  # Per-host wallpaper (placeholder: wallpapers/air-wallpaper.png). The path
  # literal copies the image into the nix store; swap the file to change it.
  
  system.activationScripts.postActivation.text = ''
    consoleUser=$(/usr/bin/stat -f%Su /dev/console)
    /usr/bin/sudo -u "$consoleUser" /usr/bin/osascript -e \
      'tell application "System Events" to tell every desktop to set picture to "${../../wallpapers/air-wallpaper.png}"' || true
  '';
}

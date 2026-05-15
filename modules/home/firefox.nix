{ pkgs, ... }:

{
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
        # Touch ID / WebAuthn platform authenticator (macOS Sequoia+)
        "security.webauthn.ctap2" = true;
        "security.webauthn.enable_usbtoken" = true;
        "security.webauthn.enable_softtoken" = false;
        "security.webauthn.webauthn_enable_macos_passkeys" = true;
        "security.webauthn.enable_macos_passkeys" = true;
      };
    };
  };
}

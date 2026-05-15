{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # From nixpkgs (more stable)
        bbenoist.nix
        hashicorp.terraform
        ms-azuretools.vscode-docker
        ms-python.python
        ms-vscode.cpptools
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-vsliveshare.vsliveshare
        tamasfe.even-better-toml
        eamodio.gitlens
        rust-lang.rust-analyzer
        ms-vscode-remote.remote-ssh
      ]
      # Additional marketplace extensions can be added here:
      # ++ (with pkgs.vscode-marketplace; [
      #   google.colab  # installed manually from marketplace
      # ]);
      ;
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

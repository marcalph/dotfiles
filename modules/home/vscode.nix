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
        tamasfe.even-better-toml
        eamodio.gitlens
        rust-lang.rust-analyzer
      ]
      ++ (with pkgs.vscode-marketplace; [
        anthropic.claude-code
        pomdtr.excalidraw-editor
        google.colab
        # per-window color from a hash of the folder path → tells projects apart
        stuart.unique-window-colors
        # diagram visualization
        bierner.markdown-mermaid # render Mermaid in the markdown preview
        jebbs.plantuml # PlantUML preview/export — renders locally via java + dot
        hediet.vscode-drawio # edit .drawio/.dio diagrams inline (offline, no account)
      ]);

      # No keybindings block, and no remap layer under it either (xremap is gone
      # from modules/hosts/pro.nix). vscode uses its stock keys: Ctrl+C/V/X,
      # Ctrl+A, Ctrl+Z, Ctrl+S, Ctrl+F.
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

  # Zed is a trial, kept in this file so one deletion removes it again. Its
  # settings.json and keymap.json stay mutable (module defaults), so zed writes
  # its own in-app changes. No keymap here either: zed uses its stock Ctrl keys.
  programs.zed-editor.enable = true;
}

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
      # macOS-style Super (⌘) bindings. xremap leaves the Super key untouched in
      # VSCode (see modules/hosts/pro.nix) precisely so these focus-aware rules
      # can fire: ⌘C/V/etc. resolve to the editor, integrated terminal, or file
      # explorer depending on what's focused. Ctrl is never rebound, so Ctrl+C in
      # the terminal stays SIGINT. ("meta" is Super on Linux.)
      keybindings = [
        # ── copy ──
        { key = "meta+c"; command = "editor.action.clipboardCopyAction"; when = "editorTextFocus"; }
        { key = "meta+c"; command = "workbench.action.terminal.copySelection"; when = "terminalFocus && terminalTextSelected"; }
        { key = "meta+c"; command = "filesExplorer.copy"; when = "filesExplorerFocus && !inputFocus"; }
        # ── paste ──
        { key = "meta+v"; command = "editor.action.clipboardPasteAction"; when = "editorTextFocus"; }
        { key = "meta+v"; command = "workbench.action.terminal.paste"; when = "terminalFocus"; }
        { key = "meta+v"; command = "filesExplorer.paste"; when = "filesExplorerFocus && !inputFocus"; }
        # ── cut ──
        { key = "meta+x"; command = "editor.action.clipboardCutAction"; when = "editorTextFocus && !editorReadonly"; }
        { key = "meta+x"; command = "filesExplorer.cut"; when = "filesExplorerFocus && !inputFocus"; }
        # ── select all ──
        { key = "meta+a"; command = "editor.action.selectAll"; when = "editorTextFocus"; }
        { key = "meta+a"; command = "workbench.action.terminal.selectAll"; when = "terminalFocus"; }
        # ── undo / redo ──
        { key = "meta+z"; command = "undo"; when = "editorTextFocus && !editorReadonly"; }
        { key = "meta+shift+z"; command = "redo"; when = "editorTextFocus && !editorReadonly"; }
        # ── save / find ──
        { key = "meta+s"; command = "workbench.action.files.save"; }
        { key = "meta+f"; command = "actions.find"; when = "editorFocus"; }
        { key = "meta+f"; command = "workbench.action.terminal.focusFind"; when = "terminalFocus"; }
        # Preserved from the previous hand-edited keybindings.json: Shift+Enter
        # sends ESC+CR in the terminal (lets TUIs/REPLs insert a newline).
        { key = "shift+enter"; command = "workbench.action.terminal.sendSequence";
          args.text = builtins.fromJSON ''"\u001b\r"''; when = "terminalFocus"; }
      ];

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

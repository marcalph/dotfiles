{ config, lib, pkgs, ... }:

let
  # Source of truth for Obsidian CSS snippets. Auto-discovers every *.css here,
  # so dropping a new file in this dir wires it on the next rebuild.
  snippetsSrc = ./obsidian/snippets;
  entries = builtins.readDir snippetsSrc;
  cssFiles = builtins.filter
    (name: entries.${name} == "regular" && lib.hasSuffix ".css" name)
    (builtins.attrNames entries);
  # Basenames without ".css" are what Obsidian stores in enabledCssSnippets.
  snippetNames = map (name: lib.removeSuffix ".css" name) cssFiles;
  enabledJson = builtins.toJSON snippetNames;
  # Space-separated file list for the activation shell (snippet names never
  # contain spaces).
  cssList = lib.concatStringsSep " " cssFiles;
in
{
  # Obsidian owns files under .obsidian/ and is usually running, which fights
  # home.file symlinks: a live Obsidian re-materialises a snippet as a plain
  # file, and standalone home-manager (pro) has no declarative backupFileExtension
  # to recover from the resulting clobber. So instead deploy by copy from the repo
  # (the source of truth) on every activation and reconcile enabledCssSnippets
  # in place. Both steps are idempotent and friendly to a live Obsidian. Runs on
  # all hosts via modules/home; a no-op where the vault's .obsidian dir is absent.
  home.activation.obsidianSnippets =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      obsidian="${config.home.homeDirectory}/Work-vault/.obsidian"
      if [ -d "$obsidian" ]; then
        snippets="$obsidian/snippets"
        manifest="$snippets/.hm-managed"
        want="${cssList}"

        $DRY_RUN_CMD mkdir -p "$snippets"

        # Prune snippets this module deployed previously but that are no longer in
        # the repo. The manifest lists only files we wrote, so snippets you add by
        # hand are never touched.
        if [ -f "$manifest" ]; then
          while IFS= read -r old; do
            [ -n "$old" ] || continue
            case " $want " in
              *" $old "*) ;;
              *) $DRY_RUN_CMD rm -f "$snippets/$old" ;;
            esac
          done < "$manifest"
        fi

        # Deploy the current set (repo wins; overwrite on every switch).
        for name in $want; do
          $DRY_RUN_CMD install -m644 "${snippetsSrc}/$name" "$snippets/$name"
        done

        # Record what we manage so the next switch can prune removals.
        if [ -z "''${DRY_RUN_CMD:-}" ]; then
          printf '%s\n' $want > "$manifest"
        fi

        # Enable exactly these snippets, preserving every other appearance key
        # (theme, font size, …). Only writes when the result actually changes.
        appearance="$obsidian/appearance.json"
        existing='{}'
        [ -f "$appearance" ] && existing="$(cat "$appearance")"
        updated="$(printf '%s' "$existing" \
          | ${pkgs.jq}/bin/jq --argjson enabled '${enabledJson}' \
              '.enabledCssSnippets = $enabled')"
        if [ "$updated" != "$existing" ]; then
          if [ -z "''${DRY_RUN_CMD:-}" ]; then
            printf '%s\n' "$updated" > "$appearance"
          else
            echo "obsidian: would set enabledCssSnippets in $appearance"
          fi
        fi
      fi
    '';
}

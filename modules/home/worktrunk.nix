{ pkgs, lib, ... }:

# worktrunk (`wt`) — git-worktree manager for parallel AI-agent work.
# The binary ships from modules/home/packages.nix; this module owns its two
# imperative-by-default pieces declaratively:
#   1. the zsh integration (the `wt` shell function + completions), which the
#      upstream `wt config shell install` would otherwise write into ~/.zshrc.
#   2. ~/.config/worktrunk/config.toml, which `wt config create` would scaffold.
#
# Workflow it sets up — many worktrees in ONE VS Code window, each driven by its
# own Claude in its own integrated terminal:
#   • open an integrated terminal, run `wsc <branch>`
#   • post-start adds the new worktree as a folder to *this* window (`code --add`)
#   • `-x claude` turns *this* terminal into that worktree's Claude session
#   • repeat in a new integrated terminal for the next branch
{
  # Shell integration. eval'd at startup like pay-respects in shell.nix; mkAfter
  # keeps it past that file's compinit so completions register.
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
  '';

  # `wsc <branch>` as a bare command. This MUST be a shell alias, not a wt
  # `[aliases]` entry — the latter is invoked as `wt wsc`. It expands to a call
  # of the `wt` shell function (defined by the eval above), so the cd-into-worktree
  # and `-x claude` exec directives are still honored.
  programs.zsh.shellAliases.wsc = "wt switch --create -x claude";

  xdg.configFile."worktrunk/config.toml".text = ''
    # Managed by home-manager (modules/home/worktrunk.nix). Edit there, then
    # `home-manager switch --flake ~/dotfiles#pro`.

    # New worktrees go in a sibling dir: <repo>.<branch>  (e.g. kalari.feature-x).
    worktree-path = "{{ repo_path }}/../{{ repo }}.{{ branch | sanitize }}"

    # One VS Code session, many roots: add each new worktree as a folder to the
    # *current* window (`--add`) instead of opening a new window per worktree.
    # Runs in the background once the worktree is ready.
    post-start = "code --add {{ worktree_path }}"

    # The `wsc` convenience command is a zsh shell alias (see above), not a wt
    # alias, so it can be invoked bare. Usage, from a VS Code integrated terminal:
    #   wsc feature-auth                 # create + add folder + Claude here
    #   wsc fix-login -- 'Fix the 500'   # ...and start Claude with a prompt
    #   wsc spike --base production       # branch from a different base
  '';
}

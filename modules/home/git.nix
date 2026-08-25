{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "CLAUDE.md"
      "TODO.md"
      "marcalph/"
      ".vscode"
    ];
    settings = {
      user.name = "marcalph";
      user.email = "marcalph@protonmail.com";
      init.defaultBranch = "main";
      rerere.enabled = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };

    # Host-independent invariant: anything under ~/Projects/personal/ is authored
    # with the personal identity — even on the pro (work) host, where pro.nix
    # mkForce-overrides the shared user.* above to the harmattan one. This
    # includeIf is spliced in *after* the [user] block, so it wins for repos in
    # that subtree while work repos elsewhere keep the professional identity.
    # (The trailing "/" matches the whole tree; git expands "~" in gitdir:.)
    includes = [
      {
        condition = "gitdir:~/Projects/personal/";
        contents.user = {
          name = "marcalph";
          email = "marcalph@protonmail.com";
        };
      }
    ];
  };
}

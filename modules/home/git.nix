{ ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "CLAUDE.md"
      "TODO.md"
    ];
    settings = {
      user.name = "marcalph";
      user.email = "marcalph@protonmail.com";
      init.defaultBranch = "main";
      rerere.enabled = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };
}

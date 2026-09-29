{ ... }:
{
  programs.git = {
    enable = true;
    # Home Manager >= 25.11 uses the `settings` interface directly.
    settings = {
      user = {
        name = "Jitendra Malakalapalli";
        email = "jitendra8911@gmail.com";
      };
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
}

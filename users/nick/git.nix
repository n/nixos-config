{ hostname, ... }:
let
  keys = import ../../common/keys.nix;
in
{
  programs.git = {
    enable = true;
    signing = {
      key = keys.nick.${hostname};
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Nick McCann";
        email = "n@users.noreply.github.com";
      };
      gpg.format = "ssh";
      init.defaultBranch = "main";
      push.default = "current";
      pull.ff = "only";
      merge.ff = "only";
      core.editor = "vim";
      core.excludesFile = "~/.gitignore_global";
      color = {
        status = "auto";
        branch = "auto";
        ui = "true";
      };
      alias = {
        ic = "commit -m \"Initial commit\"";
        lc = "!git commit -m \"$(git log -1 --pretty=%B)\"";
        l = "log --oneline";
        i = "status --ignored";
        amend = "commit --amend -C HEAD";
        head1 = "rebase --interactive HEAD~1";
        head2 = "rebase --interactive HEAD~2";
        head3 = "rebase --interactive HEAD~3";
        head4 = "rebase --interactive HEAD~4";
        head5 = "rebase --interactive HEAD~5";
        head6 = "rebase --interactive HEAD~6";
        rebase-root = "rebase -i --root";
      };
    };
  };
}

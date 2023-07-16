{
  # commit-msg = {
  #   commands = {
  #     commitlint = {
  #       run = ''
  #         # allow WIP, fixup!/squash! commits locally
  #         [[ "$(head -n 1 {1})" =~ ^WIP(:.*)?$|^wip(:.*)?$|fixup\!.*|squash\!.* ]] \
  #           || commitlint --edit {1}
  #       '';
  #       skip = ["merge" "rebase"];
  #     };
  #   };
  # };
  pre-commit = {
    commands = {
      lint-then-fmt = {
        run = "just fmt {staged_files}";
        skip = [ "merge" "rebase" ];
      };
    };
  };
  pre-push = {
    commands = {
      # FIXME: i consider myself "non-compliant"
      # check-licenses.run = "reuse lint";
    };
  };
}

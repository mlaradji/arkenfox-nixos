{pkgs, ...}: {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [pkgs.git];

  # https://devenv.sh/languages/
  languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks.alejandra.enable = true;
  pre-commit.hooks.prettier.enable = true;
  pre-commit.hooks.shellcheck.enable = true;
  pre-commit.hooks.taplo.enable = true;
  pre-commit.hooks.yamllint.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";
}

{ ... }:
{
  programs.zsh = {
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "brave";
    };

    shellAliases = {
      rebuild = "nh home switch $HOME/nix-config";
      pp = "pulumi";
      creds = "source ~/.config/2fctl/credentials.sh";
      shell = "nix develop -c $SHELL";
      homecfg = "cd ~/nix-config && zed .";
      rl = "source ~/.zshrc";
      extip = "curl icanhazip.com/v4";
      kcu = "2fctl kubeconfig update";
      gcat = "git commit --all --template ~/.gitmessage";
      gwup = "pushd ~/workspace/govcloud && 2fctl git clone && popd";
    };
  };
}

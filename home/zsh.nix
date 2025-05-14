{ ... }:
{
  programs.zsh = {
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "brave";
    };
    history = {
      size = 100000;           # Max lines kept in memory
      save = 200000;           # Max lines saved to file
      share = true;            # Share history between sessions
      ignoreDups = true;       # Ignore duplicate commands
      ignoreSpace = true;      # Ignore commands that start with a space
      extended = true;         # Save timestamps
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

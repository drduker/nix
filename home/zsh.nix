{ ... }: {

  programs.zsh = {
    sessionVariables = {
      EDITOR = "vim";
      BROWSER = "firefox";
    };
    history = {
      size = 100000; # Max lines kept in memory
      save = 200000; # Max lines saved to file
      share = true; # Share history between sessions
      ignoreDups = true; # Ignore duplicate commands
      ignoreSpace = true; # Ignore commands that start with a space
      extended = true; # Save timestamps
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
      add = "f() { sed -i \"/home\\.packages = with pkgs; \\[/a \\ \\ \\ \\ $1\" ~/nix-config/home/home.nix; rbh; }; f";
      open = "xdg-open";
      lastMR = "curl -H \"PRIVATE-TOKEN: $(awk -F'[:@]' '/code.il2/ {print $3}' ~/.git-credentials)\" \"https://code.il2.gamewarden.io/api/v4/merge_requests?scope=all&order_by=created_at&sort=desc&per_page=1\" | jq -r '.[].web_url'";
    };
  };
}

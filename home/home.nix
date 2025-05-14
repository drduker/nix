{ pkgs, lib, ... }: {
  imports = [ ./zsh.nix ./vscode.nix ./firefox.nix ];

  secondfront.hyprland.monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1200;
      refreshRate = 60;
      position = "1920x3134";
    }
    {
      name = "DP-2";
      width = 3840;
      height = 2160;
      refreshRate = 60;
      position = "0x974";
    }
    {
      name = "DP-3";
      width = 3840;
      height = 2160;
      refreshRate = 60;
      position = "3840x0";
    }
    {
      name = "DP-3";
      transform = true;
      scale = "3";
    }
  ];
  home.packages = with pkgs; [
    twofctl
    pulumi-bin
    nixfmt
    base16-schemes
    pulseaudio
    bash
    xarchiver
    go
    kubectx
    signal-desktop
    rustup
    rustls-libssl
    typescript
    gcc
    nodejs_24
    openssl
    signal-desktop
    stern
    cosign
    spotify
    dig
    dive
    lsof
    brightnessctl
    discord
    wget
    cloud-utils # for vm tools like cloud-localds
    yq-go
    pcsc-tools
    (pkgs.writeShellScriptBin "setup-browser-CAC" ''
      NSSDB="''${HOME}/.pki/nssdb"
      mkdir -p ''${NSSDB}

      ${pkgs.nssTools}/bin/modutil -force -dbdir sql:$NSSDB -add yubi-smartcard \
        -libfile ${pkgs.opensc}/lib/opensc-pkcs11.so
    '')
  ];

  programs = {
    # Add packages from home Manager that you want
    obs-studio.enable = true;
    foot.enable = true;
    chromium = {
      enable = true;
      package = pkgs.brave;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Darkreader
        { id = "acacmjcicejlmjcheoklfdchempahoag"; } # JSON Lite
        { id = "fmkadmapgofadopljbjfkapdkoienihi"; } # React Dev Tools
        { id = "clngdbkpkpeebahjckkjfobafhncgmne"; } # Stylix
        { id = "dhdgffkkebhmkfjojejmpbldmpobfkfo"; } # Tampermonkey
      ];
      commandLineArgs = [ "--disable-features=AutofillSavePaymentMethods" ];
    };
  };
  stylix = {
    enable = true;
    cursor = {
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 24;
    };
  };

  programs.zed-editor.userSettings.vim_mode = lib.mkForce false;
  programs.zed-editor.userSettings.relative_line_numbers = lib.mkForce false;
  wayland.windowManager.hyprland = {

    settings = {
      input = { natural_scroll = true; };
      exec-once = [
        "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
      ];
      bind = [
        "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
        "$mainMod, escape, exec, hyprlock"
        "$mainMod, G, togglegroup"
        "$mainMod, Return, exec, kitty"
        "$mainMod, Y, exec, ykmanoath"
        "$mainMod, Q, killactive,"
        "$mainMod, E, exec, thunar"
        "$mainMod, F, togglefloating,"
        "$mainMod, SPACE, exec, fuzzel"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, S, togglesplit, # dwindle"
        "$mainMod, TAB, workspace, previous"
        ",F11,fullscreen"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod ALT, J, changegroupactive, f"
        "$mainMod ALT, K, changegroupactive, b"
        "$mainMod SHIFT, h, movewindoworgroup, l"
        "$mainMod SHIFT, l, movewindoworgroup, r"
        "$mainMod SHIFT, k, movewindoworgroup, u"
        "$mainMod SHIFT, j, movewindoworgroup, d"
        "$mainMod CTRL, h, resizeactive, -60 0"
        "$mainMod CTRL, l, resizeactive,  60 0"
        "$mainMod CTRL, k, resizeactive,  0 -60"
        "$mainMod CTRL, j, resizeactive,  0  60"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, F3, exec, brightnessctl -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, brightnessctl -d *::kbd_backlight set 33%-"
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%- "
        ", XF86MonBrightnessUp, exec, brightnessctl set +5% "
        '', Print, exec, grim -g "$(slurp)" - | swappy -f -''
        "$mainMod, B, exec, pkill -SIGUSR1 waybar"
        "$mainMod, W, exec, pkill -SIGUSR2 waybar"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}

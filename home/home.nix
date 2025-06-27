{ pkgs, user, lib, ... }: {
  imports = [ ./zsh.nix ./vscode.nix ./firefox.nix  ];

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
    cilium-cli
    inkscape
    gimp
    skopeo
    crane
    manifest-tool
    easyeffects
    envsubst
    zip
    pre-commit
    usbutils
    bastet
    pong3d
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
    sops
    kail
    qalculate-gtk
    spotify
    dig
    dive
    lsof
    brightnessctl
    discord
    trivy
    grype
    syft
    wget
    sqlite
    kubeconform
    # spice-vdagent # dynamic resolution for VMs
    cloud-utils # for vm tools like cloud-localdsdl
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
    kitty.settings = {
      scrollback_lines = 100000;
      copy_on_select = "clipboard";
      tab_bar_edge = "left";
      tab_bar_style = "separator";
      tab_bar_min_tabs = 1;
      tab_separator = " │ ";
      active_tab_foreground = "#000";
      active_tab_background = "#eee";
      inactive_tab_foreground = "#444";
      inactive_tab_background = "#999";
    };
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
    k9s = {
      plugin = {
        network-test = {
          shortCut = "Shift-4";
          description = "ntwrk-util";
          scopes = [ "pods" ];
          command = "sh";
          background = true;
          args = [
            "-c"
            ''
              kubectl run -it -n $NAMESPACE network-utility \
                --image=registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9 \
                --overrides='{
                  "apiVersion": "v1",
                  "spec": {
                    "containers": [{
                      "name": "network-utility",
                      "image": "registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9",
                      "command": ["/bin/bash"],
                      "args": ["-c", "sleep 10000"],
                      "serviceAccount": "default",
                      "securityContext": {
                        "capabilities": {
                          "drop": ["ALL"]
                        }
                      }
                    }],
                    "imagePullSecrets": [{
                      "name": "private-registry"
                    }]
                  }
                }' \
                --command -- bash
            ''
          ];
        };

        aws-cli = {
          shortCut = "Shift-3";
          description = "aws-cli";
          scopes = [ "pods" ];
          command = "sh";
          background = true;
          args = [
            "-c"
            ''
              kubectl run -it -n $NAMESPACE aws-cli \
                --image=registry1.dso.mil/ironbank/opensource/amazon/aws-cli:2.11.2 \
                --overrides='{
                  "apiVersion": "v1",
                  "spec": {
                    "containers": [{
                      "name": "aws-cli",
                      "image": "registry1.dso.mil/ironbank/opensource/amazon/aws-cli:2.11.2",
                      "command": ["/bin/bash"],
                      "args": ["-c", "sleep 10000"],
                      "serviceAccount": "default",
                      "securityContext": {
                        "runAsUser": 1001,
                        "runAsGroup": 1001,
                        "fsGroup": 1001,
                        "capabilities": {
                          "drop": ["ALL"]
                        }
                      }
                    }],
                    "imagePullSecrets": [{
                      "name": "private-registry"
                    }]
                  }
                }' \
                --command -- bash
            ''
          ];
        };
        psql-client = {
          shortCut = "Shift-1";
          description = "psql";
          scopes = [ "pods" ];
          command = "sh";
          background = true;
          args = [
            "-c"
            ''
              kubectl run -it -n $NAMESPACE psql-client \
                --image=registry.gamewarden.io/ironbank-proxy/ironbank/bitnami/postgres:16.3.0 \
                --overrides='{
                  "apiVersion": "v1",
                  "spec": {
                    "containers": [{
                      "name": "psql-client",
                      "image": "registry.gamewarden.io/ironbank-proxy/ironbank/bitnami/postgres:16.3.0",
                      "command": ["/bin/bash"],
                      "args": ["-c", "sleep 10000"],
                      "serviceAccount": "default",
                      "env": [
                        {
                          "name": "POSTGRES_USER",
                          "value": "DBAdmin"
                        },
                        {
                          "name": "DATABASE_URL",
                          "valueFrom": {
                            "secretKeyRef": {
                              "name": "app-secrets",
                              "key": "DATABASE_URL",
                              "optional": true
                            }
                          }
                        },
                        {
                          "name": "PGPASSWORD",
                          "valueFrom": {
                            "secretKeyRef": {
                              "name": "generated-secrets",
                              "key": "GENERATED_DB_PASSWORD",
                              "optional": true
                            }
                          }
                        },
                        {
                          "name": "PGPASSWORD",
                          "valueFrom": {
                            "secretKeyRef": {
                              "name": "$NAMESPACE",
                              "key": "DB_PASSWORD",
                              "optional": true
                            }
                          }
                        },
                        {
                          "name": "PGPASSWORD",
                          "valueFrom": {
                            "secretKeyRef": {
                              "name": "$NAMESPACE",
                              "key": "DATABASE_PASSWORD",
                              "optional": true
                            }
                          }
                        }
                      ],
                      "securityContext": {
                        "capabilities": {
                          "drop": ["ALL"]
                        }
                      }
                    }],
                    "imagePullSecrets": [{
                      "name": "private-registry"
                    }]
                  }
                }' \
                --command -- bash
            ''
          ];
        };
        mysql-client = {
          shortCut = "Shift-2";
          description = "mysql-client";
          scopes = [ "pods" ];
          command = "sh";
          background = true;
          args = [
            "-c"
            ''
              kubectl run -it -n $NAMESPACE mysql-client \
                --image=registry1.dso.mil/ironbank/opensource/mysql/mysql8:8.0.29 \
                --overrides='{
                  "apiVersion": "v1",
                  "spec": {
                    "containers": [{
                      "name": "mysql-client",
                      "image": "registry1.dso.mil/ironbank/opensource/mysql/mysql8:8.0.29",
                      "command": ["/bin/bash"],
                      "args": ["-c", "sleep 10000"],
                      "serviceAccount": "default",
                      "env": [
                        {
                          "name": "MYSQL_PASSWORD",
                          "valueFrom": {
                            "secretKeyRef": {
                              "name": "$NAMESPACE",
                              "key": "MYSQL_PASSWORD",
                              "optional": true
                            }
                          }
                        },
                        {
                          "name": "MYSQL_USER",
                          "value": "DBAdmin"
                        }
                      ],
                      "securityContext": {
                        "capabilities": {
                          "drop": ["ALL"]
                        }
                      }
                    }],
                    "imagePullSecrets": [{
                      "name": "private-registry"
                    }]
                  }
                }' \
                --command -- bash
            ''
          ];
        };
      };
      views = {
        "kustomize.toolkit.fluxcd.io/v1/kustomizations" = {
          columns =
            [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
        };
        "helm.toolkit.fluxcd.io/v2/helmreleases" = {
          columns =
            [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
        };
      };
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
        "$mainMod, R, exec, xdg-open \"$(curl -H \"PRIVATE-TOKEN: $(awk -F'[:@]' '/code.il2/ {print $3}' ~/.git-credentials)\" \"https://code.il2.gamewarden.io/api/v4/merge_requests?scope=all&order_by=created_at&sort=desc&per_page=1\" | jq -r '.[].web_url')\"" # open last MR
        "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
        "$mainMod CTRL, escape, exec, systemctl suspend" 
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

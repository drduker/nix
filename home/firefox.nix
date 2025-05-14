{ pkgs, ... }: {
  programs = {
    firefox = {
      policies.ExtensionSettings = with pkgs.nur.repos.rycee.firefox-addons;
        builtins.mapAttrs (_: install_url: {
          installation_mode = "force_installed";
          inherit install_url;
        }) {
          # "${vimium.addonId}" = "${vimium.src.url}";
          "${darkreader.addonId}" = "${darkreader.src.url}";
          "${bitwarden.addonId}" = "${bitwarden.src.url}";
          "${ublock-origin.addonId}" = "${ublock-origin.src.url}";
          "${privacy-badger.addonId}" = "${privacy-badger.src.url}";
          "${tampermonkey.addonId}" = "${tampermonkey.src.url}";
        };
      profiles.lucaspick = {
        search = {
          force = true;
          default = "google";
          order = [ "google" ];
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }];
              icon =
                "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            "bing".metaData.hidden = true;
            "google".metaData.alias =
              "@g"; # builtin engines only support specifying one additional alias
          };
        };
        settings = { "extensions.autoDisableScopes" = 0; };
      };
    };
  };
}

# nix
# nix
# nix
### notes
nix flake update twofctl


# Update all flake inputs (including secondfront)
nix flake update

# Or update just the secondfront input specifically
nix flake lock --update-input secondfront

# Then rebuild your system configuration
sudo nixos-rebuild switch --flake .#nixtop

# And update your home-manager configuration
nix run home-manager -- switch --flake .#lucaspick

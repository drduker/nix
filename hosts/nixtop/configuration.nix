{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  modules = {
    hostName = "nixtop";
    peripherals = {
      enable = true;
      obs.enable = true;
      scarlettRite.enable = true;
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.font-awesome
  ];

  time.timeZone = lib.mkForce "America/Chicago";

  system.stateVersion = "24.05";
  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x046d" ATTR{device}=="0xc547" ATTR{power/wakeup}="disabled"
  '';
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

}

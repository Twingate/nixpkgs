{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.twingate;

in {

  options.services.twingate = {
    enable = mkEnableOption "Twingate Client daemon";
  };

  config = mkIf cfg.enable {

    networking.firewall.checkReversePath = lib.mkDefault false;
    networking.networkmanager.enable = true;

    environment.systemPackages = [ pkgs.twingate ]; # for the CLI
    systemd.packages = [ pkgs.twingate ];

    system.activationScripts.twingate = stringAfter ["etc"] ''
      mkdir -p '/etc/twingate'
      cp -r -n ${pkgs.twingate}/etc/twingate/. /etc/twingate/
    '';

    systemd.services.twingate.wantedBy = [ "multi-user.target" ];
  };
}

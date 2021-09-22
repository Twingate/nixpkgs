{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.twingate;

in {

  options.services.twingate = {
    enable = mkEnableOption "Twingate Client daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.twingate;
      defaultText = "pkgs.twingate";
      description = "The package to use for Twingate";
    };
  };

  config = mkIf cfg.enable {

    networking.firewall.checkReversePath = lib.mkDefault false;

    environment.systemPackages = [ cfg.package ]; # for the CLI
    systemd.packages = [ cfg.package ];

    system.activationScripts.twingate = stringAfter ["etc"] ''
      mkdir -p '/etc/twingate'

      cp -r -n ${cfg.package}/etc/twingate/. /etc/twingate/
    '';

    # copy from twingate.service
    # passed as raw text to reset ExecStart, because of weird error: 
    # twingate.service: Service has more than one ExecStart= setting...
    systemd.units."twingate.service".text = ''
      [Unit]
      Description=Twingate Remote Access Client
      After=network.target

      [Service]
      ExecStart=
      ExecStart=${cfg.package}/bin/twingated /etc/twingate/config.json
      Restart=on-failure
      RestartSec=5s
      RuntimeDirectory=twingate
      RuntimeDirectoryMode=0755
      StateDirectory=twingate
      StateDirectoryMode=0700
      WorkingDirectory=/var/lib/twingate
      ConfigurationDirectory=twingate

      ProtectSystem=full
      ProtectHome=yes
      PrivateTmp=yes
      NoNewPrivileges=yes
      ProtectControlGroups=yes
      RestrictSUIDSGID=yes
      ProtectKernelLogs=yes
      ProtectKernelModules=yes
      ProtectHostname=yes
      CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW
      RestrictAddressFamilies=AF_UNIX AF_NETLINK AF_INET AF_INET6
      RestrictNamespaces=~user
      SystemCallArchitectures=native
      LockPersonality=yes
      MemoryDenyWriteExecute=yes
      RestrictRealtime=yes

      [Install]
      WantedBy=multi-user.target
    '';

    # copy from twingate-desktop-notifier.service
    systemd.user.services.twingate-notifier = {
      description = "Desktop notifications for Twingate Client";
      serviceConfig = {
          ExecStart = ''${cfg.package}/bin/twingate-notifier'';
      };
    };
  };
}

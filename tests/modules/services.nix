let
  t = import ../lib.nix;
  config = t.eval [
    ../../services/adguard.nix
    ../../services/apcupsd.nix
    ../../services/bluetooth.nix
    ../../services/fstrim.nix
    ../../services/keyd.nix
    ../../services/libvirtd.nix
    ../../services/mihomo.nix
    ../../services/nfs.nix
    ../../services/pipewire.nix
    ../../services/postgresql.nix
    ../../services/prometheus.nix
    ../../services/qbittorrent.nix
    ../../services/resolved.nix
    ../../services/samba.nix
    ../../services/sshd.nix
    ../../services/syncthing.nix
    ../../services/timesyncd.nix
    { users.users.mingcheng.isNormalUser = true; }
  ];
  changed = t.eval [
    ../../services/adguard.nix
    ../../services/fstrim.nix
    ../../services/mihomo.nix
    ../../services/qbittorrent.nix
    ../../services/samba.nix
    ../../services/sshd.nix
    ../../services/syncthing.nix
    {
      users.users.mingcheng = {
        isNormalUser = true;
        linger = true;
      };
      networking = {
        nameservers = [ "9.9.9.9" ];
        networkmanager.insertNameservers = [ "9.9.9.9" ];
        proxy = {
          default = "http://127.0.0.1:1080";
          noProxy = "localhost";
        };
      };
      services.adguardhome = {
        allowDHCP = true;
        openFirewall = true;
        mutableSettings = false;
        host = "0.0.0.0";
        port = 3001;
        settings = {
          dhcp.enabled = true;
          dns = {
            bind_hosts = [ "0.0.0.0" ];
            port = 5353;
            bootstrap_dns = [ "1.1.1.1" ];
            upstream_dns = [ "https://cloudflare-dns.com/dns-query" ];
          };
          filters = [ ];
        };
      };
      services.resolved.settings.Resolve.DNS = [ "9.9.9.9" ];
      services.mihomo = {
        configFile = "/srv/mihomo/config.yaml";
        tunMode = false;
        processesInfo = true;
        webui = null;
      };
      systemd.user.services.syncthing = {
        unitConfig.ConditionUser = "custom";
        serviceConfig.ExecStart = "/srv/syncthing/bin/syncthing --no-browser";
      };
      services.fstrim.enable = false;
      services.qbittorrent = {
        user = "downloads";
        group = "downloads";
        profileDir = "/srv/downloads";
        webuiPort = 9090;
      };
      services.samba.settings.global.interfaces = "enp1s0";
      services.openssh = {
        openFirewall = true;
        settings = {
          MaxAuthTries = 5;
          MaxStartups = "20:30:60";
          LogLevel = "INFO";
        };
      };
    }
  ];
  ssh = config.services.openssh.settings;
  adguard = config.services.adguardhome;
  mihomo = config.services.mihomo;
  syncthingSvc = config.systemd.user.services.syncthing;
in
t.check "modules/services" {
  evaluates = t.validSystem config && t.validSystem changed;
  adguard-system-service =
    adguard.enable
    && !adguard.allowDHCP
    && !adguard.settings.dhcp.enabled
    && !adguard.openFirewall
    && adguard.mutableSettings
    && adguard.host == "127.0.0.1"
    && adguard.port == 9527
    && adguard.settings.dns.bind_hosts == [ "127.0.0.1" ]
    && adguard.settings.dns.port == 53
    &&
      map (f: f.name) adguard.settings.filters == [
        "AdGuard DNS filter"
        "AdAway Default Blocklist"
        "Steven Black's List"
        "CHN: anti-AD"
        "CHN: AdRules DNS List"
      ]
    && t.lib.all (f: f.enabled) adguard.settings.filters
    && config.networking.nameservers == [ "127.0.0.1" ]
    && config.networking.networkmanager.insertNameservers == [ "127.0.0.1" ]
    && config.services.resolved.settings.Resolve.DNS == [ "127.0.0.1" ]
    &&
      config.systemd.services.adguardhome.serviceConfig.AmbientCapabilities == [
        "CAP_NET_BIND_SERVICE"
      ];
  adguard-overridable =
    !changed.services.adguardhome.allowDHCP
    && !changed.services.adguardhome.settings.dhcp.enabled
    && !changed.services.adguardhome.openFirewall
    && changed.services.adguardhome.mutableSettings
    && changed.services.adguardhome.host == "127.0.0.1"
    && changed.services.adguardhome.port == 9527
    && changed.services.adguardhome.settings.dns.bind_hosts == [ "127.0.0.1" ]
    && changed.services.adguardhome.settings.dns.port == 53
    && changed.services.adguardhome.settings.dns.bootstrap_dns == [ "1.1.1.1" ]
    &&
      changed.services.adguardhome.settings.dns.upstream_dns == [
        "https://cloudflare-dns.com/dns-query"
      ]
    && changed.services.adguardhome.settings.filters == [ ]
    && changed.networking.nameservers == [ "127.0.0.1" ]
    && changed.networking.networkmanager.insertNameservers == [ "127.0.0.1" ]
    && changed.services.resolved.settings.Resolve.DNS == [ "127.0.0.1" ];
  mihomo-system-service =
    let
      defaultFile = config.systemd.tmpfiles.settings.mihomo."/etc/mihomo.yaml".f;
    in
    mihomo.enable
    && mihomo.configFile == "/etc/mihomo.yaml"
    && mihomo.tunMode
    && !mihomo.processesInfo
    && mihomo.webui == t.pkgs.metacubexd
    && config.networking.proxy.default == "http://127.0.0.1:7890"
    && config.networking.proxy.noProxy == "127.0.0.1,localhost,internal.domain"
    && defaultFile.mode == "0600"
    && t.lib.hasInfix "mixed-port: 7890" defaultFile.argument
    && t.lib.hasInfix "bind-address: 127.0.0.1" defaultFile.argument
    && t.lib.hasInfix "mode: direct" defaultFile.argument
    && t.lib.hasInfix "- MATCH,DIRECT" defaultFile.argument
    && builtins.elem "adguardhome.service" config.systemd.services.mihomo.after
    &&
      config.systemd.services.mihomo.serviceConfig.AmbientCapabilities == [
        "CAP_NET_ADMIN"
      ];
  mihomo-overridable =
    changed.services.mihomo.configFile == "/srv/mihomo/config.yaml"
    && changed.systemd.tmpfiles.settings.mihomo."/srv/mihomo/config.yaml".f.mode == "0600"
    && changed.networking.proxy.default == "http://127.0.0.1:1080"
    && changed.networking.proxy.noProxy == "localhost"
    && !changed.services.mihomo.tunMode
    && changed.services.mihomo.processesInfo
    && changed.services.mihomo.webui == null
    &&
      changed.systemd.services.mihomo.serviceConfig.AmbientCapabilities == [
        "CAP_DAC_READ_SEARCH"
        "CAP_SYS_PTRACE"
      ];
  syncthing-user-service =
    config.users.users.mingcheng.linger == false
    && t.hasPackages config.users.users.mingcheng.packages [ "syncthing" ]
    && !(t.hasPackages config.environment.systemPackages [ "syncthing" ])
    && syncthingSvc.wantedBy == [ "default.target" ]
    && syncthingSvc.unitConfig.ConditionUser == "mingcheng"
    && syncthingSvc.environment.STNORESTART == "yes"
    && syncthingSvc.environment.STNOUPGRADE == "yes"
    && t.lib.hasInfix "--no-browser" syncthingSvc.serviceConfig.ExecStart
    && t.lib.hasInfix "--gui-address=127.0.0.1:8384" syncthingSvc.serviceConfig.ExecStart
    && t.lib.hasInfix "--config=%h/Syncthing/config" syncthingSvc.serviceConfig.ExecStart
    && t.lib.hasInfix "--data=%h/Syncthing/config" syncthingSvc.serviceConfig.ExecStart
    && syncthingSvc.serviceConfig.Restart == "on-failure";
  syncthing-overridable =
    changed.users.users.mingcheng.linger == true
    && changed.systemd.user.services.syncthing.unitConfig.ConditionUser == "custom"
    &&
      changed.systemd.user.services.syncthing.serviceConfig.ExecStart
      == "/srv/syncthing/bin/syncthing --no-browser";
  ups =
    config.services.apcupsd.enable && t.lib.hasInfix "UPSTYPE usb" config.services.apcupsd.configText;
  bluetooth =
    config.hardware.bluetooth.enable
    && config.hardware.bluetooth.powerOnBoot
    && config.services.blueman.enable;
  trim-overridable = config.services.fstrim.enable && !changed.services.fstrim.enable;
  keyd = config.services.keyd.enable;
  virtualisation =
    config.virtualisation.libvirtd.enable
    && !config.virtualisation.libvirtd.qemu.runAsRoot
    && config.environment.variables.LIBVIRT_DEFAULT_URI == "qemu:///system";
  nfs =
    config.services.nfs.server.enable
    && config.fileSystems."/public".device == "/data"
    && builtins.elem "bind" config.fileSystems."/public".options;
  pipewire =
    config.security.rtkit.enable
    && config.services.pipewire.enable
    && config.services.pipewire.alsa.support32Bit
    && config.services.pipewire.pulse.enable
    && config.services.pipewire.jack.enable
    && !config.services.pulseaudio.enable;
  database =
    config.services.postgresql.enable
    && config.services.postgresql.dataDir == "/data/postgresql"
    && t.lib.versions.major config.services.postgresql.package.version == "14";
  metrics = config.services.prometheus.exporters.node.enable;
  downloads =
    config.services.qbittorrent.enable
    && config.services.qbittorrent.profileDir == "/data/qbittorrent"
    && config.services.qbittorrent.webuiPort == 8080;
  downloads-overridable =
    changed.services.qbittorrent.user == "downloads"
    && changed.services.qbittorrent.group == "downloads"
    && changed.services.qbittorrent.profileDir == "/srv/downloads"
    && changed.services.qbittorrent.webuiPort == 9090;
  resolver =
    config.services.resolved.enable && config.services.resolved.settings.Resolve.DNSSEC == "false";
  samba =
    config.services.samba.enable
    && !config.services.samba.nmbd.enable
    && !config.services.samba.winbindd.enable
    && config.services.samba.settings.global."server min protocol" == "SMB2";
  samba-interface-overridable = changed.services.samba.settings.global.interfaces == "enp1s0";
  ssh-public-key-only =
    !config.services.openssh.openFirewall
    && ssh.PubkeyAuthentication
    && ssh.AuthenticationMethods == "publickey"
    && !ssh.PasswordAuthentication
    && !ssh.KbdInteractiveAuthentication
    && ssh.PermitRootLogin == "no"
    && !ssh.X11Forwarding
    && ssh.MaxAuthTries == 3
    && ssh.MaxStartups == "10:30:30"
    && ssh.LogLevel == "VERBOSE";
  ssh-limits-overridable =
    changed.services.openssh.openFirewall
    && changed.services.openssh.settings.MaxAuthTries == 5
    && changed.services.openssh.settings.MaxStartups == "20:30:60"
    && changed.services.openssh.settings.LogLevel == "INFO";
  time-sync =
    !config.services.ntp.enable
    && config.services.timesyncd.enable
    &&
      config.services.timesyncd.servers == [
        "cn.pool.ntp.org"
        "ntp.aliyun.com"
      ];
}

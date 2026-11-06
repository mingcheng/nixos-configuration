let
  t = import ../lib.nix;
  config = t.eval [
    ../../services/apcupsd.nix
    ../../services/bluetooth.nix
    ../../services/fstrim.nix
    ../../services/keyd.nix
    ../../services/libvirtd.nix
    ../../services/nfs.nix
    ../../services/pipewire.nix
    ../../services/postgresql.nix
    ../../services/prometheus.nix
    ../../services/qbittorrent.nix
    ../../services/resolved.nix
    ../../services/samba.nix
    ../../services/sshd.nix
    ../../services/timesyncd.nix
    { users.users.mingcheng.isNormalUser = true; }
  ];
  changed = t.eval [
    ../../services/fstrim.nix
    ../../services/qbittorrent.nix
    ../../services/samba.nix
    {
      services.fstrim.enable = false;
      services.qbittorrent = {
        user = "downloads";
        group = "downloads";
        profileDir = "/srv/downloads";
        webuiPort = 9090;
      };
      services.samba.settings.global.interfaces = "enp1s0";
    }
  ];
  ssh = config.services.openssh.settings;
in
t.check "modules/services" {
  evaluates = t.validSystem config;
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
    ssh.PubkeyAuthentication
    && ssh.AuthenticationMethods == "publickey"
    && !ssh.PasswordAuthentication
    && !ssh.KbdInteractiveAuthentication
    && ssh.PermitRootLogin == "no";
  time-sync =
    !config.services.ntp.enable
    && config.services.timesyncd.enable
    &&
      config.services.timesyncd.servers == [
        "cn.pool.ntp.org"
        "ntp.aliyun.com"
      ];
}

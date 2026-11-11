let
  t = import ../lib.nix;
  inherit (t) lib;
  config = t.eval [ ../../system/security.nix ];
  ssh = t.eval [
    ../../system/security.nix
    ../../services/sshd.nix
  ];
  sysctls = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kexec_load_disabled" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.randomize_va_space" = 2;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.unprivileged_bpf_disabled" = 2;
    "net.core.bpf_jit_harden" = 2;
    "fs.protected_fifos" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_regular" = 2;
    "fs.protected_symlinks" = 1;
    "fs.suid_dumpable" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.tcp_syncookies" = 1;
  };
in
t.check "modules/security" {
  evaluates = t.validSystem config;
  ssh-evaluates = t.validSystem ssh;
  firewall-lockdown =
    config.networking.nftables.enable
    && config.networking.firewall.enable
    && config.networking.firewall.allowedTCPPorts == [ ]
    && config.networking.firewall.allowedUDPPorts == [ ]
    && config.networking.firewall.allowedTCPPortRanges == [ ]
    && config.networking.firewall.allowedUDPPortRanges == [ ]
    && config.networking.firewall.trustedInterfaces == [ "lo" ]
    && !config.networking.firewall.allowPing
    && config.networking.firewall.checkReversePath == "loose";
  sudo-hardening =
    lib.hasInfix "Defaults timestamp_timeout=5" config.security.sudo.extraConfig
    && lib.hasInfix "Defaults use_pty" config.security.sudo.extraConfig;
  kernel-hardening = lib.all (name: config.boot.kernel.sysctl.${name} == sysctls.${name}) (
    builtins.attrNames sysctls
  );
  hibernation-preserved =
    !config.security.protectKernelImage && !(builtins.elem "nohibernate" config.boot.kernelParams);
  namespaces-preserved = config.security.allowUserNamespaces && config.nix.settings.sandbox;
  coredump-disabled =
    config.systemd.coredump.settings.Coredump.Storage == "none"
    && config.systemd.coredump.settings.Coredump.ProcessSizeMax == 0;
  docker-loopback =
    config.virtualisation.docker.daemon.settings.ip == "127.0.0.1"
    &&
      config.virtualisation.docker.daemon.settings.default-network-opts.bridge."com.docker.network.bridge.host_binding_ipv4"
      == "127.0.0.1";
  no-implicit-services =
    !config.services.openssh.enable
    && !config.virtualisation.docker.enable
    && !(config.systemd.services ? docker)
    && !(config.systemd.services ? sshd);
  no-implicit-open-ports =
    !ssh.services.openssh.openFirewall
    && ssh.networking.firewall.allowedTCPPorts == [ ]
    && ssh.networking.firewall.allowedUDPPorts == [ ];
}

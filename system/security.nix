{ lib, ... }:
{
  networking = {
    nftables.enable = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [ ];
      allowedUDPPorts = lib.mkForce [ ];
      allowedTCPPortRanges = lib.mkForce [ ];
      allowedUDPPortRanges = lib.mkForce [ ];
      trustedInterfaces = lib.mkForce [ "lo" ];
      allowPing = false;
      checkReversePath = "loose";
    };
  };

  security.sudo = {
    # wheelNeedsPassword = lib.mkForce true;
    extraConfig = ''
      Defaults timestamp_timeout=5
      Defaults use_pty
    '';
  };

  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1;
    # Unlike security.protectKernelImage, disabling kexec alone preserves hibernation.
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

  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };

  virtualisation.docker.daemon.settings = {
    ip = "127.0.0.1";
    default-network-opts.bridge = {
      "com.docker.network.bridge.host_binding_ipv4" = "127.0.0.1";
    };
  };
}

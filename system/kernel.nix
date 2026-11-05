{ lib, ... }: {
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
    "vm.overcommit_memory" = lib.mkDefault 0;
    "vm.panic_on_oom" = lib.mkDefault 0;
  };
}

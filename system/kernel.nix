# TCP defaults for the network and workstation profiles: BBR congestion
# control paced by the fq qdisc keeps throughput up on lossy Wi-Fi and
# long-distance links. Both stay overridable per host.
{ lib, ... }:
{
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";
  };
}

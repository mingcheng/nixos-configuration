let
  t = import ../lib.nix;
  resume =
    swaps:
    (t.eval [
      ../../system/swap.nix
      { swapDevices = swaps; }
    ]).boot.resumeDevice;
  rejected = swaps: !(builtins.tryEval (resume swaps)).success;
in
t.check "modules/swap" {
  partition = resume [ { device = "/dev/nvme0n1p2"; } ] == "/dev/nvme0n1p2";
  uuid = resume [ { device = "/dev/disk/by-uuid/test-swap"; } ] == "/dev/disk/by-uuid/test-swap";
  label = resume [ { label = "test-swap"; } ] == "/dev/disk/by-label/test-swap";
  no-swap-rejected = rejected [ ];
  swap-file-rejected = rejected [ { device = "/swapfile"; } ];
  multiple-partitions-rejected = rejected [
    { device = "/dev/sda2"; }
    { device = "/dev/sdb2"; }
  ];
  random-encryption-rejected = rejected [
    {
      device = "/dev/sda2";
      randomEncryption.enable = true;
    }
  ];
  zram-not-a-resume-device =
    !(builtins.tryEval (
      (t.eval [
        ../../system/swap.nix
        {
          swapDevices = [ ];
          zramSwap.enable = true;
        }
      ]).boot.resumeDevice
    )).success;
}

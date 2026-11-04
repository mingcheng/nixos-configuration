{ lib, ... }:
{
  # X1 Carbon Gen 8: i7-10510U (4C/8T), 16 GiB RAM, WD NVMe, F2FS.
  # PPD already controls intel_pstate/HWP and ThinkPad platform_profile.
  # Do not add TLP/tuned or force a governor/EPP that competes with Plasma.
  # Thermald exits on this machine because thinkpad_acpi/dytc_lapmode is
  # present; respect its compatibility check instead of forcing it to run.
  services.thermald.enable = lib.mkForce false;

  # About 4 GiB logical compressed swap, allocated on demand, ahead of NVMe.
  # Keep the existing 16.9 GiB disk swap and boot.resumeDevice for hibernation.
  # Leave swappiness at the kernel default: disk swap is still the fallback.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  # Bound local build pressure on a 15 W CPU / 16 GiB desktop. These are
  # scheduling hints, not hard CPU or memory limits; retain binary substitutes.
  nix.settings = {
    max-jobs = lib.mkDefault 2;
    cores = lib.mkDefault 4;
  };
}

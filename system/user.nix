{ config, pkgs, ... }: {
  users = {
    users.mingcheng = {
      isNormalUser = true;
      group = "users";
      extraGroups = [ "wheel" "libvirtd" "docker" ];
      shell = pkgs.bash;

      openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ5bbZz8LqLOCt5t4yX1RT61d3coI8P5rcbgX53Nw85e lyum@windrunner"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOD0EBDaEuYOqtNQqslfz4OL5Gyr/d6zZq4NKCNlo2i76P1/uEu41GuO9tzM3yTb31r6tZ1kuJkhVlHGBx5EWytMYU55Dwrxs487UocSGuctZUHLW9WOJ4RioZ/4shtuwIUEeqfMv7pRzaUA1Ye+FiRLMAp/PPknS/2UJbjTHEEY1OI8EhpEx6XZ8bap/53He9MDysQXsjG281cR+JVi6VFGHr9ONT73C+QiQcJm6k2K24UxM0/n/djPKNKZVLEvwqAzxcyU7HIL2vn9mNGMONFbT3S2HlLc8Kf6yS/1/aBrNNBwKSbG9bJ/q+R8CCcE5b1cnplNqbgnopIqiFwZLzh+lzutgBWYzc+cYeRjH4/QvSlTwoDCtcvoywb/Q1QTNNLr1b/YBW0oiK/zp1zPTIugd99N5+QEbhYIE79S4z8Iv+ePWRtaJppt5g6nMimyWJXTwXhQ9H+uIMKZvkVRtV07a8EVWyRtPGy3hFNmeEdMFHL2pD5DUuyYE0Lvi9XSU= mingcheng@skybreakers"
      ];
    };
  };
}

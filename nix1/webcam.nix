{ config, pkgs, lib, ... }: {

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };

}

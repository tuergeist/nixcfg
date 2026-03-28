{ pkgs, ... }:

let vpnDesktopItem = pkgs.makeDesktopItem {
    name = "VSX-RDP";
    desktopName = "Make RDP Connection, VN neeeded";
    exec = "/home/cb/.local/bin/rdp_vsx.sh";
#    terminal = true;
  };
in {
  home.packages = [ 
    vpnDesktopItem 
  ]; 
}

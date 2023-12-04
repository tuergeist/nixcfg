# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ../hosts/common/nix.nix
    # ./webcam.nix
    ../users/cb
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelParams = [ "i915.force_probe=46a6i" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Setup keyfile
  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # larger terminal font also during boot
  console = {
    keyMap = "us-acentos";
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-4eba8888-e30d-46f4-a2c9-76f6d54f4919".device =
    "/dev/disk/by-uuid/4eba8888-e30d-46f4-a2c9-76f6d54f4919";
  boot.initrd.luks.devices."luks-4eba8888-e30d-46f4-a2c9-76f6d54f4919".keyFile =
    "/crypto_keyfile.bin";

  networking.hostName = "nix1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  services.nebula.networks."nebula1" = {
    ca = "/opt/nebula/ca.crt";
    #tun.disable = true;
    cert = "/opt/nebula/host.crt";
    key = "/opt/nebula/host.key";
    lighthouses = [ "192.168.100.1" ];
    staticHostMap = { "192.168.100.1" = [ "18.196.133.48:4242" ]; };
    firewall.outbound = [{
      host = "any";
      port = "any";
      proto = "any";
    }];
    firewall.inbound = [{
      host = "any";
      port = "any";
      proto = "any";
    }];
    #  relays = [ "192.168.100.100" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable and Configure keymap in X11
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # steam https://github.com/NixOS/nixpkgs/issues/47932#issuecomment-447508411
  hardware.opengl.driSupport32Bit = true;

  # Thunderbolt
  services.hardware.bolt.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cb = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Christoph Becker";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
    packages = with pkgs; [ firefox vim mc obsidian ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # symlink chrome to google-chrome
  environment.systemPackages = let
    chromeSymlinkPackage = pkgs.writeShellScriptBin "google-chrome"
      "exec -a $0 ${pkgs.google-chrome}/bin/google-chrome-stable $@";

  in with pkgs; [
    thunderbird
    vim
    mc
    dig
    gcc
    obsidian
    killall
    thonny
    steam
    spotify
    spotify-tray
    terminator
    wget
    home-manager
    docker
    google-chrome
    chromeSymlinkPackage
    chromedriver
    nix-direnv
    zsh
    git
    gittyup
    libsForQt5.kdenlive
    mediainfo
    rclone
    tlp
    jhead

    slack
    gnomeExtensions.vitals
    canon-cups-ufr2
    insync
    libxkbcommon

    docker
    google-chrome
    direnv
    zsh
    powerline-fonts
    git
    libsForQt5.kdenlive
    mediainfo
    #insync-v3
    rclone
    tlp
    # Python development
    jetbrains.pycharm-professional

    streamlit

    pipenv
    pdm
    python3Full
    gnome-browser-connector
    python311Packages.virtualenv
    nebula
    jetbrains.idea-ultimate
    jdk
    jq
    terminator
    wget

    #  wget
    # machine learning
    tesseract
    jq
  ];
  #		programs.direnv.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  virtualisation.docker.enable = true;

  #virtualisation.virtualbox.host.enable = true;
  #users.extraGroups.vboxusers.members = [ "cb" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable tlp management for batt etc
  services.tlp.enable = true;

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
    CPU_MIN_PERF_ON_BAT = 1;
    CPU_MAX_PERF_ON_BAT = 30;
  };
  services.power-profiles-daemon.enable = false;

  # flakes
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Zsh
  programs.zsh.enable = true;

  # Enable java to set JAVA_HOME
  programs.java.enable = true;

  # Networking

  systemd.services.NetworkManager-wait-online.enable = false;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

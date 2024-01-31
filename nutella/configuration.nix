# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    ../hosts/common/nix.nix
    ../users/cb
  ];

  # fix for buildifiert swbng  
  system.activationScripts.binbash = ''
    mkdir -m 0755 -p /bin
    ln -sfn ${pkgs.bash}/bin/bash /bin/bash
  '';
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Setup keyfile
  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-c89bf8f8-0c2c-4097-af94-9e08e83afe8f".device =
    "/dev/disk/by-uuid/c89bf8f8-0c2c-4097-af94-9e08e83afe8f";
  boot.initrd.luks.devices."luks-c89bf8f8-0c2c-4097-af94-9e08e83afe8f".keyFile =
    "/crypto_keyfile.bin";

  networking.hostName = "nutella"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Disable Speedport port scanns as log entries
  networking.firewall.extraCommands = ''
    # Silence refusal of speedport scans
    iptables \
      --insert nixos-fw-log-refuse 1 \
      --source 172.16.2.1 \
      --protocol tcp \
      --match multiport \
      --dports 80,443,8081,8080 \
      --jump nixos-fw-refuse
  '';

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
    videoDrivers = [ "nvidia" ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # steam https://github.com/NixOS/nixpkgs/issues/47932#issuecomment-447508411
  hardware.opengl = {
    driSupport32Bit = true;
    enable = true;

  };
  programs.steam.enable = true;
  # Thunderbolt
  services.hardware.bolt.enable = true;

  hardware.rtl-sdr.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  hardware.nvidia = {
    modesetting.enable = true;
    #      prime.sync.allowExternalGpu = true;
    #      prime.offload.enable = true;
    nvidiaSettings = true;
  };

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

  # Home Manager global packages
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cb = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Christoph Becker";
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" "plugdev" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = let
    chromeSymlinkPackage = pkgs.writeShellScriptBin "google-chrome"
      "exec -a $0 ${pkgs.google-chrome}/bin/google-chrome-stable $@";

  in with pkgs; [
    firefox
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
    ngrok
    vim
    wget
    home-manager
    docker
    google-chrome
    chromeSymlinkPackage
    chromedriver
    nix-direnv
    zsh
    git
    git-lfs
    gittyup
    libsForQt5.kdenlive
    mediainfo
    rclone
    tlp
    jhead
    jetbrains.pycharm-professional

    poedit
    gettext
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers

    pipenv
    python311Full
    python311Packages.virtualenv
    python311Packages.pip
    python311Packages.pyarrow
    python311Packages.pillow
    python311Packages.numpy
    #streamlit
    pdm
    slack
    gnomeExtensions.vitals
    canon-cups-ufr2
    nodejs
    insync
    libxkbcommon
    #python39Full
    #jdk17
    #jdk19
    gradle
    jq
    krita
    # sdr
    rtl-sdr
    rtl_433
    wsjtx
    gqrx
    sdrpp
    # video
    losslesscut-bin
    libsForQt5.kdenlive
    # building
    cmake
    gnumake
    openssl
    # OCR
    tesseract
    # kartenlernen
    anki
  ];

  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];


  virtualisation.docker.enable = true;

  #virtualisation.virtualbox.host.enable = true;
  #users.extraGroups.vboxusers.members = [ "cb" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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

  # Open ports in the firewall.
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

  # Test fix sound problems on nuc
  environment.etc."wireplumber/main.lua.d/99-custom.lua".text = ''
    table.insert(alsa_monitor.rules, {
      matches = {
          {
            -- Matches all sources.
            { "node.name", "matches", "alsa_input.*" },
          },
          {
            -- Matches all sinks.
            { "node.name", "matches", "alsa_output.*" },
          },
        },

      apply_properties = {
        ["api.alsa.headroom"] = 1024,
      }    
    })
  '';

  # sony buzz devices
  services.udev.extraRules = ''
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0002", MODE="0666"
  '';

}

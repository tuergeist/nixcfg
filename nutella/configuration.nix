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
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Unlock the root volume with the FIDO2 key if present, passphrase otherwise.
  # Scripted initrd + fido2luks because the volume is LUKS1 (systemd-cryptenroll
  # needs LUKS2).
  # systemd stage 1 is the default by now; fido2luks only exists in the scripted one.
  boot.initrd.systemd.enable = false;
  boot.initrd.luks.fido2Support = true;
  boot.initrd.luks.devices."luks-0664968d-53dc-4117-9a5d-6fae7a0c0f56".fido2 = {
    credential = "d3a89798a35f7d9c408e8c46803d090ea8b4b01f5b90d54bf225d1ca217875f739c4c3b32ff7681dc26f1d807a0666f4";
    passwordLess = true;
  };

  # SSH in stage 1 to type the LUKS passphrase remotely (LAN only):
  #   ssh -p 2222 root@172.16.2.99
  # Host key is not in the repo, create it once with
  #   sudo mkdir -p /etc/secrets/initrd && sudo ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
  boot.initrd.availableKernelModules = [ "e1000e" ];
  boot.initrd.network = {
    enable = true;
    udhcpc.enable = true;
    ssh = {
      enable = true;
      port = 2222;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsPcs/lOuThM80yG/RlFcVdeTVjWfLjCJ4jq0znsxUArO3e8dyITs+KDlI8pv0bid9FD/mBoqn0NV6Mw7a2ICrahWmK6fqIlGO7hY3UXmETAuXAR7OMqgk7IyZc/QMIQiFcf5Yk5D65MhESmbM2V1U/7cfg/19vm15swgSTEZm/KYyhDO5eW/iKCfuSOxTaKZiodXi2t3paD1skfvIej3p4kEsyq3HMSx2BY6HMai7rLKbR7mZ2xWudokK51SFySM6PgJAyLwCBvCC2x+5K26Jx4xkz9BevFY0KJ4N63bm2tcP+vH1+fml5EiHVsSFoMoYQmxDaFpENZwHuZ32+XpqiK6a6oFhaju2I382usdl+kE31nmPFCQ8ESOtaYLlPTjrXHWlPkkjecQYhj4Y0BSAqWWutFpuRUQNylhQfzla4hEj0d7X1h1KLnLz0OPvDJAT44aaaPCbYQTgb/UBKJ47UmFDkDirePNN47kluox4GZ6UmVG7+Wr12s8OMi4aG2M= cb@nixos"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCEv6YxesBTOkEqHWgWupk9m0kkU78dt/VwKxxjVMGcRbi5qdAZsynyB2szvIYRmQ+N136wenolp1hgztXE8jtZW9qT04JToPmXp2tReKNdSURgD0Yjyik9PnBEFn3DAXt6Vz5eyMupAsN8haoz03Bu3j4JBy+2SGEjQLhDETJq9ppUqMZ6Y4BYTvGiYXXZ5xYVOCU+ut/NlVpTyI1RDsLsDZ55H94GrESg6N9ZZnM/kgf2yp3k0JkHM9+5nxXrvkZMgYpCf9V2ABowTCzOuJASvLZ2QiP0nJWVIWCsTeuJMVGkEBWiBMRtDmxp7j852ehAg/Kwy7tKqtWgu1vfrSmPkTzVgevLmKD9hnpl0MvX4PRzGqnK+HOlaZVMZ7WL0r2x4x5Dy42tq7dpTuuXg/lActDbmHMIhDeUDkguxOaZ7k1hAOv9Hvzw6X7EkhxzVG/9X/RdBLzyhX2YrAI9VydcYIKpQj3ajMaIkw7tPNOY69yq2cV3PWadCVQqHbdMA2k= cb@nixos"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp8KJwyraNNlByrIOoOPJS0vCL8lrkpu3yb59tth5+ZyRRGsQLTm6v7WtHF1ArBXJIfEjaEnyMmeBV2y91XKLeBYttKrtBWVQBHKQrpfKG7ZftPLwiVrZ6Jboyzke8DJI0mmgz/UUtrbLohXSqz+hnqaElV+aQdGGaC+xyruUbo1bbMUkQPXcsdgUqK32Fsngtbe7StiilXfPoodubEo/0k/WgOJVxCTsHcVT39L10k79AUQKFSkpFnSUNJkVzWW3Q01bxb6H8XyX7jTPHUWPqU8HS2k5GYwzcZwobsb5v+mAsDOaLJlkicNiGxHt9t7ZA6k0rtsil9PYG8ZJuYXcOeBxjQRzqDdVYimI7d+hrQcMETzcjRnH+Ns87Vs2rUH3FAngM77eWW+mDooxcpLyYmVM5yY5ywycYLVzZOy3C+k4fvBSJDmx/ZoxGSfoBPY5gGXXX9fGMniXX2yep9g0DPt0U3+YOyTCxITCUWPD/V90PhxkHdj4u+GXIkKLUMSE= cb@MacBook-Pro-von-Christoph.local"
      ];
    };
    postCommands = "echo cryptsetup-askpass >> /root/.profile";
  };

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
  systemd.services.NetworkManager-wait-online.enable = false;  

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


#  services.nebula.networks."nebula1" = {
#    enable = false;
#    ca = "/opt/nebula/ca.crt";
#    #tun.disable = true;
#    cert = "/opt/nebula/host.crt";
#    key = "/opt/nebula/host.key";
#    lighthouses = [ "192.168.100.1" ];
#    staticHostMap = { "192.168.100.1" = [ "18.196.133.48:4242" ]; };
#    firewall.outbound = [{
#      host = "any";
#      port = "any";
#      proto = "any";
#    }];
#    firewall.inbound = [{
#      host = "any";
#      port = "any";
#      proto = "any";
#    }];
#    #  relays = [ "192.168.100.100" ];
#  };
  
  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "e3918db4839f8cb9"
      "632ea2908582e8d5"
    ];
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "altgr-intl";
    videoDrivers = [ "nvidia" ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  # for a WiFi printer
  services.avahi.openFirewall = true;

  # steam https://github.com/NixOS/nixpkgs/issues/47932#issuecomment-447508411
  hardware.graphics ={
    enable = true;  
    enable32Bit = true;
  };
  programs.steam.enable = true;
  # Thunderbolt
  services.hardware.bolt.enable = true;

  hardware.rtl-sdr.enable = true;
  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;

  hardware.nvidia = {
    modesetting.enable = true;
    #      prime.sync.allowExternalGpu = true;
    #      prime.offload.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
 #   pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

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
    llm-agents.claude-code
    llm-agents.agent-deck
    llm-agents.backlog-md
    llm-agents.beads
    llm-agents.bernstein
    llm-agents.spec-kit
    llm-agents.td
    llm-agents.ralph-tui
    tmux
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
    gh
    #libsForQt5.kdenlive
    mediainfo
    rclone
    tlp
    jhead
    jetbrains.pycharm
    vscodium
    esptool
    #poedit
    gettext
    aspell
    aspellDicts.de
    aspellDicts.en

    pre-commit
    pipenv
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
    jdk21
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
    #libsForQt5.kdenlive
    # Sound
    pavucontrol
    # building
    cmake
    gnumake
    openssl
    # OCR
    tesseract
    # kartenlernen
    #anki

    # Deployment
    terraform
    awscli2
    # edtor
    gedit

    # office
    libreoffice-fresh
    # clipboard manager, gnome extension
    dconf-editor
    gnome-tweaks
    #gnomeExtensions.gnome-clipboard
    gnomeExtensions.clipboard-history
    gsound
    
    # peer network
    nebula

    # ML
    ollama

    vlc

    # Screenshot
    ksnip

    #microsoft
    teams-for-linux
    #microsoft-edge
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

  # Disable automatic suspend (for headless SSH access)
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # flakes
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Zsh
  programs.zsh.enable = true;

  # Enable java to set JAVA_HOME
  programs.java.enable = true;

  programs.nix-ld.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5173 ];
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
  ## old
  # environment.etc."wireplumber/main.lua.d/99-custom.lua".text = ''
  ## after 292115 is merged
  #services.pipewire.wireplumber.extraLuaConfig.main."99-custom" = '' 
  ## 12.3.24
  #services.pipewire.wireplumber.configPackages = [
  #(pkgs.writeTextDir "share/wireplumber/main.lua.d/99-alsa.lua" ''
  #  alsa_monitor.rules = {
  #    matches = {
  #        {
  #          -- Matches all sources.
  #          { "node.name", "matches", "alsa_input.*" },
  #        },
  #        {
  #          -- Matches all sinks.
  #          { "node.name", "matches", "alsa_output.*" },
  #        },
  #      },
#
 #     apply_properties = {
 #       ["api.alsa.headroom"] = 0,
 #     }    
 #   }
 # '')];

  # sony buzz devices
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0002", MODE="0666"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-one-%k", MODE="660", GROUP="plugdev"
  '';

  # enable .local/bin in path
  environment.localBinInPath = true;

  #VSX
  security.pki.certificateFiles = [
    ./vsxca.pem
  ];

}

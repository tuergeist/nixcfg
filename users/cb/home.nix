{ config, pkgs, ... }:

{

  nixpkgs.config.allowUnfree = true;
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "cb";
  home.homeDirectory = "/home/cb";
  # Packages that should be installed to the user profile.
  home.packages = [                               
    pkgs.htop
    pkgs.fortune
    pkgs.unzip
    pkgs.git
    pkgs.git-lfs
    pkgs.direnv
    pkgs.libxcrypt
    pkgs.powerline-fonts
    pkgs.wget
    pkgs.heroku


    pkgs.jetbrains.idea-ultimate
    pkgs.jetbrains.webstorm
#    pkgs.maven
#    pkgs.jdk19

    pkgs.nix-direnv
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  # ZSH https://nixos.wiki/wiki/Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    autocd = true;
    syntaxHighlighting.enable = true;
    plugins  = [
     {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
    #dotDir = ".config/zsh";
  };


   programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-nix ];
    settings = { ignorecase = true; };
    extraConfig = ''
      set mouse=a
    '';
  };

  programs.git = {
    enable = true;
    userName  = "Christoph Becker";
    userEmail = "mail@ch-becker.de";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    lfs.enable = true;
  };

  dconf.settings = {
    # Min, Max clos buttons on the right
    "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";

    # plugins
    "org/gnome/shell" = {
      enabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "window-list@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
      ];
    };
    # vitals
    "org/gnome/shell/extensions/vitals" = {
      show-battery = false;
      show-fan = false;
      show-storage = false;
      show-voltage = false;
    };
    "org/gnome/settings-daemon/plugins/color".night-light-enabled = true;
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
      sleep-inactive-ac-timeout = 7200;
    };
    # blank after
    "org/gnome/desktop/session".idle-delay = 900;
    # Key binding, CTRL-ESC to directly switch app windws
    "org/gnome/desktop/wm/keybindings" = {
      cycle-group = [ "<Control>Escape" ];
      cycle-group-backward = [ "<Shift><Control>Escape" ];
    };
  };

  # Terminator default size
  programs.terminator.config = {
    profiles.default = {
      scrollback_lines = 5000;
      font = "Space Mono Regular 12";
    };
  };


  # htop basename
  programs.htop = {
    enable = true;
    settings.highlight_base_name = 1;
    settings.show_program_path = 0;
  };

  # direnv
    programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  # set global LD LIb ath
  home.sessionVariables.LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
}

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  ## Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "nvidia" ];

  # Enable NixOS automatic updates and garbage collection
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";                   # Set the interval for garbage collection
    options = "--delete-older-than 7d";
  };

  # Network and hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Time zone and locales
  time.timeZone = "Europe/London";

  # Internationalisation properties
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # KDE Plasma Desktop Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;                       # Enable experimental Wayland support
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.enable = true;                # Enable the X11 windowing system

  # Keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Console keymap
  console.keyMap = "uk";

  # Printing
  services.printing.enable = true;

  # Enable sound with pipewire
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

  # Enable touchpad support (enabled default in most desktopManager)
  services.libinput.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;

  # Optional: Enable Blueman for easier Bluetooth management (GUI)
  # services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.mylaptoptitle = {
    isNormalUser = true;
    description = "My Name";
    extraGroups = [ "docker" "input" "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [
      autoAddDriverRunpath
      autoFixElfFiles
      clang
      cni-plugins
      direnv
      docker
      docker-compose
      dolphin-emu
      dpkg
      evdevremapkeys
      eww
      gamemode
      gcc
      ghc
      go
      htop
      iotop
      iptables
      jdk23
      kubernetes
      kubernetes-helm
      lxd-lts
      lxd-unwrapped-lts
      mullvad-vpn
      nixfmt-classic
      nixfmt-rfc-style
      nodejs_22
      nvidia-docker
      nvtopPackages.full
      nvidia-system-monitor-qt
      python311Full
      python311Packages.alpha-vantage
      python311Packages.jupyterlab
      python311Packages.matplotlib
      python311Packages.numpy
      python311Packages.pandas
      python311Packages.pip
      python311Packages.pyaml
      python311Packages.python-daemon
      python311Packages.pytorch-lightning
      python311Packages.pyxdg
      quantlib
      rapidjson
      rustup
      tgpt
      tmux
      vscode
      wget
      wine
      winetricks
      wineWowPackages.stable
      wireshark
    ];
  };

 # NixOS fan control
  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon3=devices/virtual/thermal/thermal_zone2 hwmon4=devices/platform/f71882fg.656
      DEVNAME=hwmon3=soc_dts1 hwmon4=f71869a
      FCTEMPS=hwmon4/device/pwm1=hwmon3/temp1_input
      FCFANS=hwmon4/device/pwm1=hwmon4/device/fan1_input
      MINTEMP=hwmon4/device/pwm1=35
      MAXTEMP=hwmon4/device/pwm1=65
      MINSTART=hwmon4/device/pwm1=150
      MINSTOP=hwmon4/device/pwm1=0
    '';
  };

  # All things docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  hardware.nvidia-container-toolkit.enable = true;

  # Enable browsers, git, mullvad, and steam
  programs.firefox.enable = true;
  programs.git.enable = true;
  services.mullvad-vpn.enable = true;
  programs.steam.enable = true;

  # Enable Vulkan, OpenGl and 32-bit support for steam.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs.pkgsCross.musl32; [
    ];
    extraPackages32 = with pkgs.pkgsCross.musl32; [
    ];
  };

  # Hybrid graphics (Intel + NVIDIA)
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true;

    prime = {
      # offload = {
        # enable = true;
        # enableOffloadCmd = true;
      # };
      sync.enable = true;
      intelBusId = "PCI:0:2:0";  # Intel iGPU Bus ID
      nvidiaBusId = "PCI:1:0:0"; # NVIDIA dGPU Bus ID
    };
  };

  # Enable fix for Intel CPU throttling
  services.throttled.enable = true;

  # Add missing firmware files
  # hardware.firmware = [ pkgs.linux-firmware ];

  # Enable ALL firmware regardless of license
  hardware.enableAllFirmware = true;

  # Enable wireshark
  programs.wireshark.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # OpenSSH Security
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password"; # Disable root login
      PasswordAuthentication = false;        # Disable password authentication, use SSH keys instead
    };
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kirigami
    kdePackages.ksvg
    kdePackages.plasma5support
    kdePackages.qt5compat
    kdePackages.sddm
    kdePackages.sddm-kcm
    kdePackages.systemsettings
    libsForQt5.qt5.qtgraphicaleffects
  ];
  system.stateVersion = "24.11";

}

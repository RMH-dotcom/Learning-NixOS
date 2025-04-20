{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Enable NixOS automatic updates and garbage collection
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Network and hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;     # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties
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
  #   package = pkgs.lib.mkForce pkgs.libsForQt5.sddm;
  #   extraPackages = pkgs.lib.mkForce [ pkgs.libsForQt5.qt5.qtgraphicaleffects ];
  #  theme = "corners";
  };
  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };
  services.xserver.enable = true;                # Enable the X11 windowing system

  # Configure keymap in X11
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
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.myusername = {
    isNormalUser = true;
    description = "My Username";
    extraGroups = [ "docker" "input" "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [
      docker
      docker-compose
      dolphin-emu
      dpkg
      fwupd
      gcc
      gdb
      git
      jetbrains-mono
      jetbrains.clion
      jetbrains.pycharm-professional
      libreoffice
      mullvad-vpn
      osu-lazer-bin
      python312Full
      python312Packages.jupyterlab
      python312Packages.matplotlib
      python312Packages.matplotlib-inline
      python312Packages.numpy
      python312Packages.pandas
      python312Packages.scikit-learn
      spotify
      tgpt
      # virtualbox
      wireshark
      xorg.xhost

    ];
  };

  # Virtual Machine
  # virtualisation.virtualbox.host = {
    # enable = true; 
    # enableExtensionPack = true;
  # };

  # All things docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Enable browsers, git, mullvad, steam, and wireshark
  programs.firefox.enable = true;
  programs.git.enable = true;
  services.mullvad-vpn.enable = true;
  programs.steam.enable = true;
  programs.wireshark.enable = true;

  # All things Firmware
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # NixOS-NVIDIA configuration guide at: https://nixos.wiki/wiki/Nvidia
  # Prime offload executable script at: $HOME/.local/bin/nvidia-offload

  # Enable Vulkan, OpenGL and 32-bit support for steam
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      dxvk
      vkd3d-proton
      vulkan-extension-layer
      vulkan-loader
      vulkan-tools-lunarg
    ];
    extraPackages32 = with pkgs.pkgsCross.musl32; [
      dxvk
      vulkan-loader
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";  # lspci | grep VGA | grep Intel
      nvidiaBusId = "PCI:1:0:0"; # lspci | grep VGA | grep NVIDIA
    };
  };

  environment.systemPackages = with pkgs; [
    catppuccin-sddm
    kdePackages.sddm-kcm
    sddm-astronaut
    sddm-chili-theme
    where-is-my-sddm-theme
  ];

  system.stateVersion = "24.11"; # Did you read the comment?
}

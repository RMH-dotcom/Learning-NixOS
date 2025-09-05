{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ninja ];

  # Network and hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Time zone
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

  # Console keymap
  console.keyMap = "uk";

  # KDE Plasma Desktop Environment
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm = {
    enable = true;
    #package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha";
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # X11 windowing system
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchpad support
  services.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # User account
  users.users.nixoslaptopmak = {
    isNormalUser = true;
    description = "Ryan Henry";
    extraGroups = [ "docker" "input" "kvm" "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
      #brave
      claude-code
      #cudaPackages.cudatoolkit
      #cudaPackages.cudnn
      #cudaPackages.cuda_cudart
      #docker
      #docker-compose
      dolphin-emu
      discord
      #dpkg
      emacs-pgtk
      firefox-bin
      fwupd
      gcc
      gdb
      git
      heroic
      #iproute2
      jetbrains-mono
      #jetbrains.clion
      #jetbrains.pycharm-professional
      #jdk23
      (koboldcpp.override { config.cudaSupport = true; })
      #libguestfs
      #libreoffice
      linuxKernel.packages.linux_zen.cpupower
      maven
      #mono
      mullvad-browser
      mullvad-vpn
      #osu-lazer-bin
      #OVMFFull
      parabolic
      protonup-qt
      #qemu_full
      #quickemu
      #spice-gtk
      #spice-vdagent
      spotify
      tgpt
      #ubootQemuX86
      #virglrenderer
      #virtio-win
      #virtualbox
      #virt-manager
      #virt-viewer
      vlc
      xorg.xhost
    ];
  };

  # Docker
  #virtualisation.docker = {
    #enable = true;
    #rootless = {
      #enable = true;
      #setSocketVariable = true;
    #};
  #};

  # Nixpkgs settings
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
    cudaCapabilities = [ "7.5" ];
    permittedInsecurePackages = [ "qtwebkit-5.212.0-alpha4" ];
    packageOverrides = pkgs: {
      firefox = pkgs.firefox-bin;
    };
  };

  # Programs and services
  programs = {
    firefox.enable = true;
    gamemode.enable = true;
    git.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk17;
    };
    steam.enable = true;
  };
  services = {
    mullvad-vpn.enable = true;
    #qemuGuest.enable = true;
    #spice-vdagentd.enable = true;
  };

  # Virtualisation
  #virtualisation = {
    #libvirtd = {
      #enable = true;
      #qemu = {
        #ovmf.enable = true;
        #package = pkgs.qemu_kvm;
      #};
    #};
    #spiceUSBRedirection.enable = true;
  #};

  # Firmware
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      dxvk
      gamemode
      gamescope
      glslang
      libdecor
      libdrm
      libGL
      libstrangle
      libva
      libva-utils
      libvdpau
      libvdpau-va-gl
      mesa
      nvidia-vaapi-driver
      vkbasalt
      vkd3d-proton
      vulkan-extension-layer
      vulkan-loader
      vulkan-utility-libraries
      wine64Packages.waylandFull
      xmake
    ];
    extraPackages32 = with pkgs.pkgsCross.musl32; [
      dxvk
      vulkan-loader
    ];
  };

  # Nvidia drivers
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
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    jetbrains-mono
    (pkgs.catppuccin-sddm.override {
      background = "${/home/nixoslaptopmak/Pictures/bvs01.jpg}";
      font = "jetbrains-mono";
      fontSize = "12";
    })
  ];

  # Firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

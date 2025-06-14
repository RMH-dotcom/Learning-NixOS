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

  # Enable NixOS flakes, libraries, automatic updates and garbage collection
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ninja  ];
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
  #  package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha";
  };
  services.desktopManager.plasma6 = {
    enable = true;
  };
  services.xserver.enable = true;       # Enable the X11 windowing system

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
  services.pulseaudio.enable = false;
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
    extraGroups = [ "docker" "input" "kvm" "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
      #cudaPackages.cudatoolkit
      #cudaPackages.cudnn
      #cudaPackages.cuda_cudart
      #docker
      #docker-compose
      dolphin-emu
      #dpkg
      emacs-pgtk
      fwupd
      gcc
      gdb
      git
      #iproute2                                           # For virtualisation
      jetbrains-mono
      #jetbrains.clion
      #jetbrains.pycharm-professional
      #jdk23
      (
        koboldcpp.override { config.cudaSupport = true; }
      )
      #libguestfs                                          # For virtualisation
      #libreoffice
      #mono
      mullvad-vpn
      #osu-lazer-bin
      #OVMF                                               # For virtualisation
      #qemu_full                                          # For virtualisation
      #quickemu                                           # For virtualisation
      #spice-gtk                                          # For virtualisation
      #spice-vdagent                                      # For virtualisation
      spotify
      tgpt
      #ubootQemuX86                                       # For virtualisation
      #virglrenderer                                      # For virtualisation
      #virtio-win                                         # For virtualisation
      #virtualbox                                         # For virtualisation
      #virt-manager                                       # For virtualisation
      #virt-viewer                                        # For virtualisation
      wineWowPackages.full
      wineWowPackages.waylandFull
      xorg.xhost
    ];
  };

  # All things docker
  #virtualisation.docker = {
    #enable = true;
    #rootless = {
      #enable = true;
      #setSocketVariable = true;
    #};
  #};

  # Enable programs, services and virtualisation software
  programs = {
    firefox.enable = true;
    git.enable = true;
    steam.enable = true;
  };
  services = {
    mullvad-vpn.enable = true;
    #qemuGuest.enable = true;
    #spice-vdagentd.enable = true;
  };
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

  # All things Firmware
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;

  # Allow unfree packages Hardware acceleration (CUDA)
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;              # Enable CUDA functionality
    cudaCapabilities = [ "7.5" ];     # GPU architecture for Quadro T1000
  };

  # NixOS-NVIDIA configuration guide at: https://nixos.wiki/wiki/Nvidia
  # Prime offload executable script at: $HOME/.local/bin/nvidia-offload
  # GPU architecture code list at: https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/

  # Enable Vulkan, OpenGL and 32-bit support for steam
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      clblast
      dxvk
      libdrm
      libGL
      libva
      libva-utils
      libvdpau
      libvdpau-va-gl
      mesa
      vkd3d-proton
      vulkan-extension-layer
      vulkan-headers
      vulkan-loader
      vulkan-memory-allocator
      vulkan-tools
      vulkan-tools-lunarg
      vulkan-volk
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
    jetbrains-mono
  (
    pkgs.catppuccin-sddm.override {
      background = "${/home/nixoslaptopmak/Pictures/warframerhino02.png}";
      font = "jetbrains-mono";
      fontSize = "12";
    }
  )];

  system.stateVersion = "24.11"; # Did you read the comment?
}

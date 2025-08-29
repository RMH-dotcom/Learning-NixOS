{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "i915" ];

  # Enable NixOS settings, flakes, libraries, automatic updates and garbage collection
  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ninja ];
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
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm = {
    enable = true;
    #package = pkgs.kdePackages.sddm;
    theme = "catppuccin-mocha";
    wayland.enable = true;
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
   services.libinput.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixoslaptopmak = {
    isNormalUser = true;
    description = "myusername";
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
      electron-bin
      emacs-pgtk
      firefox-bin
      fwupd
      gcc
      gdb
      git
      heroic
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
      maven
      #mono
      mullvad-browser
      mullvad-vpn
      #osu-lazer-bin
      #OVMFFull                                           # For virtualisation
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

  # Enable nixpkgs, programs, services and virtualisation software
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebkit-5.212.0-alpha4"
  ];
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

  # Allow unfree packages, and Hardware acceleration (CUDA)
  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;              # Enable CUDA functionality
    cudaCapabilities = [ "7.5" ];     # GPU architecture for Quadro T1000
  };

  # NixOS-NVIDIA opengl configuration guide at: https://nixos.wiki/wiki/Nvidia
  # Prime offload executable script at: $HOME/.local/bin/nvidia-offload
  # GPU architecture code list at: https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-v>

  # Enable Vulkan, OpenGL and 32-bit support for steam
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
      mangohud
      mesa
      nvidia-vaapi-driver
      vkbasalt
      vkd3d-proton
      vulkan-extension-layer
      vulkan-loader
      vulkan-utility-libraries
      wine64Packages.waylandFull
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
      background = "${/home/nixoslaptopmak/Pictures/bvs01.jpg}";
      font = "jetbrains-mono";
      fontSize = "12";
    }
  )];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # X11
  services.xserver.enable = true;

  # KDE Plasma Desktop Environment
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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
  services.blueman.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.mylaptoptitle = {
    isNormalUser = true;
    description = "My Name";
    extraGroups = [ "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [
      kdePackages.kate
      vscode
      wget
    ];
  };

  # Install firefox
  programs.firefox.enable = true;

  # Install git
  programs.git.enable = true;

  # Install steam
  programs.steam.enable = true;

  # Enable Vulkan, OpenGl and 32-bit support for steam.
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vulkan-loader vulkan-tools-lunarg ];  # Adds Vulkan tools for testing
    extraPackages32 = with pkgs.pkgsCross.musl32; [ vulkan-loader ]; # Ensures 32-bit Vulkan support
  };

  # Hybrid graphics (Intel + NVIDIA)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true;

    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0"; # Intel iGPU Bus ID
      nvidiaBusId = "PCI:1:0:0"; # NVIDIA dGPU Bus ID
    };
  };

  # Enable fix for Intel CPU throttling
  services.throttled.enable = true;

  #Install waybar
  programs.waybar.enable = true;

  # Install wireshark
  programs.wireshark.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  ];
  system.stateVersion = "24.05";

}

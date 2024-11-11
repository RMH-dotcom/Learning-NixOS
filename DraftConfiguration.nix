{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  # Enable NixOS automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Enable NixOS automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly"; # Set the interval for garbage collection
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
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # GNOME Desktop Environment, GDM, and all things GNOME
  services.xserver.displayManager.gdm.enable = true;    # Enable Wayland for GNOME
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-browser-connector.enable = true; # Manages GNOME extensions from the browser
  services.gnome.tracker-miners.enable = true;
  services.gnome.gnome-initial-setup.enable = true;

  # Enable the X11 windowing system
  services.xserver.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "wireshark" ];
    packages = with pkgs; [
      clang
      gcc
      ghc
      go
      jdk22
      mullvad-vpn
      nodejs_22
      python311Full
      python311Packages.pip
      rustup
      vscode
      wget
      wireshark
    ];
  };

  # Install firefox
  programs.firefox.enable = true;

  # Install git
  programs.git.enable = true;

  # Install mullvad
  services.mullvad-vpn.enable = true;

  # Install steam
  programs.steam.enable = true;

  # Enable Vulkan, OpenGl and 32-bit support for steam.
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver  # Optimized Intel driver for UHD graphics
      vulkan-loader       # Vulkan loader for 64-bit support
      vulkan-tools-lunarg # Tools like vulkaninfo for testing and diagnostics
    ];
    extraPackages32 = with pkgs.pkgsCross.musl32; [
      vulkan-loader       # 32-bit Vulkan loader for compatibility with Steam games
      libva               # Ensures 32-bit VA-API support for video acceleration
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

  # Install wireshark
  programs.wireshark.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # OpenSSH Security
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password"; # Disable root login
  services.openssh.settings.PasswordAuthentication = false;        # Disable password authentication, use SSH keys instead

  environment.systemPackages = with pkgs; [
  ];
  system.stateVersion = "24.05";

}

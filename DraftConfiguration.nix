{ config, lib, pkgs, ... }: {
imports = [
./hardware-configuration.nix
];
# Uncomment to update to the Latest kernel (stable/mainline/longterm)
# boot kernelPackages = pkgs.linuxPackages_6_11;

# Whether to enable VirtualBox
virtualisation.virtualbox.host.enable = true;

# Boot loader
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;

# Network and hostname
networking.hostName = "nixos";
networking.networkmanager.enable = true;

# Time zone and locales
time.timeZone = "Europe/London";
i18n.defaultLocale = "en_GB.UTF-8";
i18n.extraLocaleSettings = { LC_ALL = "en_GB.UTF-8"; };

# X11 and KDE Plasma
services.xserver.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
services.xserver.xkb = {
  layout = "gb";
};
console.keyMap = "uk";

# Printing and sound
services.printing.enable = true;
services.pipewire = {
  enable = true;
  alsa = {
    enable = true;
    support32Bit = true;
  };
  pulse.enable = true;
};

# Enable Bluetooth
hardware.bluetooth.enable = true;

# Optional: Enable Blueman for easier Bluetooth management (GUI)
services.blueman.enable = true;

# Optional: Ensure Bluetooth is powered on at boot
hardware.bluetooth.powerOnBoot = true;

# User account
users.users.mylaptopusername = {
  isNormalUser = true;
  description = "My Name";
  extraGroups = [ "wheel" "networkmanager" "wireshark" ];
};
# Unfree packages
nixpkgs.config.allowUnfree = true;

# Enable steam
programs.steam.enable = true;

# Enable Vulkan and OpenGl support
hardware.opengl.enable = true;

# Enable 32-bit support for steam
hardware.opengl.driSupport32Bit = true;

# System-wide packages
environment.systemPackages = with pkgs; [
bluetooth_battery
bluez
bluez-tools
firefox
git
kdePackages.bluedevil
kdePackages.bluez-qt
kdePackages.elisa
kdePackages.kate
kdePackages.konsole
kdePackages.kwalletmanager
kdePackages.gwenview
kdePackages.okular
unzip
vscode
wireshark
];

# Hybrid graphics (Intel + NVIDIA)
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
powerManagement = {
  enable = true;
  };

# Uses stable NVIDIA drivers
package = config.boot.kernelPackages.nvidiaPackages.stable;

# Fixes a glitch
nvidiaPersistenced = true;

# Intel + NVIDIA pairings
modesetting.enable = true;
prime = {
  offload.enable = true;
  sync.enable = true;

  intelBusId = "PCI:0:2:0"; # Intel iGPU Bus ID
  nvidiaBusID = "PCI:1:0:0"; #NVIDIA dGPU Bus ID
};
};

# DPI settings (for 1920x1080)
services.xserver.dpi = 120;
# services.xserver.displayManager.plasma6.scalingFactor = 1.25;

# Power management and CPU throttling
services.throttled.enable = lib.mkDefault true;

# System state version
system.stateVersion = "24.05";
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs , ... }:
let 
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.editor = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "nowatchdog"
      "modprobe.blacklist=iTCO_wdt"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
  systemd.settings.Manager.RebootWatchdogSec = "...";

  networking.hostName = "Asuncion"; 
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };
  services.xserver.xkb = {
    layout = "latam";
    variant = "";
  };
  console.keyMap = "la-latin1";

  # Environments
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = pkgs-unstable.mesa;
    package32 = pkgs-unstable.pkgsi686Linux.mesa;

  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
	enableOffloadCmd = true;
      };
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };
  };

  # System services
  services.printing.enable = true;
  services.pipewire = { enable = true; pulse.enable = true; };
  services.libinput.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim wget xclip xsel wl-clipboard curl git
    nvtopPackages.full heroic unzip gvfs libmtp 
    mtpfs

  ];

  users.users."daniel" = {
    isNormalUser = true;
    description = "Daniel De La Asuncion";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "storage" 
      "audio" 
      "video" 
      "input" 
      "docker" 
    ];
    shell = pkgs.zsh;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  };

  programs.zsh = { 
    enable = true; 
    enableCompletion = true; 
    autosuggestions.enable = true; 
    syntaxHighlighting.enable = true;
    ohMyZsh = { enable = true; plugins = [ "git" "sudo" "docker" ]; };

    shellAliases = { 
      ls = "lsd --color=auto"; 
      cl = "clear"; 
      adocker = "sudo systemctl start docker"; 
      ddocker = "sudo systemctl stop docker"; 
      sdocker = "sudo systemctl status docker";
      niv = "cd ~/.config/nixos; nvim";
      nird = "sudo nixos-rebuild switch --flake ~/.config/nixos/.#daniel";
    };
  };
  programs.starship = { 
    enable = true; 
    settings = {
      add_newline = false;
    }; 
  };

  programs.hyprland = {
    enable = true;
    withUWSM = false;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  };
  services.displayManager.ly = { 
    enable = true;
    settings = {
      logfile = "/var/log/ly/session.log";
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  virtualisation.docker = { 
    enable = true; 
    enableOnBoot = false; 
  };
  virtualisation.waydroid = { 
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    trusted-users = [ "root" "daniel" ];
  };

  system.stateVersion = "26.05"; 
}

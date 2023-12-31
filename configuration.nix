# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
 

  # habilita o nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
 
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # adicione o nome do pacote de codigo fechado aqui >:)
      "nvidia"       
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
      "epson_201207w"
      "discord"
      "steam"
      "steam-original"
      "steam-run"
    ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  # GRUB
  boot = {
    # habilita o intel vt-d ou intel vt-x
    # kernelParams = [ "intel_iommu=on" ];
    # habilita esses modulos
    # kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
    loader = {
      efi = {
       canTouchEfiVariables = true;
       efiSysMountPoint = "/boot/efi";
      };
      grub = {
       enable = true;
       device = "nodev";
       efiSupport = true;
       configurationLimit = 5;
      };
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
  #  font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  #  useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable hyprland on NixOS
  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
    xwayland.enable = true;
  };
  
  # servicos do X11
  services = {
    xserver ={
      # Diz ao Xorg pra usar o teclado br
      layout = "br";
      # habilita o X11 
      enable = true;
      # Diz ao Xorg pra usar o driver da nvidia (tambem é valido pra wayland)
      videoDrivers = ["nvidia"];
      # habilita o sevico do displaymanager (SDDM)
      displayManager.sddm.enable = true;
    };
  };
  
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # hardware
  hardware = {
    opengl = {
      # habilita o OpenGL
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      # Os compositors do wayland precisam disso ^o.o^
      modesetting.enable = true;
      # Bloqueia os drivers de codigo aberto
      open = false;
      # habilita e instala o nvidia-settings
      nvidiaSettings = true;
    };
  };
  
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # habilita os flatpaks
  services.flatpak.enable = true;  

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # adiciona o usuario ao grupo  libvirtd
  users.groups.libvirtd.members = [ "root" "kohi"];
 
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kohi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # Usuario
      firefox
      unzip
      epson_201207w
      skanlite
      # xfce.thunar
      pcmanfm
      discord
      sxiv
      gimp
      heroic
      sonobus
      ranger
      emacs
      lolcat
      gnumake
      libgccjit
      binutils
      virt-manager
      qemu
      # OVMF
      # pciutils
    ];
  };
    
  # Security
  security.sudo.wheelNeedsPassword = false;

  # virt-manager
  # habilita o libvirtd 
  virtualisation.libvirtd.enable = true;
  # habilita o dconf
  programs.dconf.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = { 
    systemPackages = with pkgs; [
      # Sistema
      # udev
      killall
      htop
      hyprland
      pywal
      git
      home-manager
      (waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
      neofetch
      swww
      kitty
      rofi-wayland
      pmutils
      sddm
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
    ];
  sessionVariables = {
      # Resolve o problema do cursor invisivel
      WLR_NO_HARDWARE_CURSOS = "1";
      # Resolve o problema da tela preta em aplicações electron
      NIXOS_OZONE_WL = "1";
    };
  };

  # Firewall
  
  # habilita o Nftables
  #config.networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };

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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      #nix.settings.trusted-users = ["harshthakur"];
      nix.settings.extra-trusted-users = ["@admin"];
     # nix.trusted-users = [ "@admin" ];
      nix.linux-builder.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
        
      security.pam.enableSudoTouchIdAuth = true;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

     nix.distributedBuilds = true;
      nix.buildMachines = [{
    hostName = "127.0.0.1@60022";
    sshUser = "harshthakur";
    sshKey = "/Users/harshthakur/.lima/_config/user";
    systems = [ "x86_64-linux" ];
    maxJobs = 2;
    speedFactor = 2;
    supportedFeatures = [ "kvm" ];
    mandatoryFeatures = [ ];
}];



    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#harshs-MacBook-Pro
    darwinConfigurations."harshs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."harshs-MacBook-Pro".pkgs;
  };
}

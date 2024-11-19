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
          pkgs.go_1_22
          pkgs.yq
          pkgs.jq
          pkgs.oh-my-zsh
          pkgs.zsh
          pkgs.zsh-completions
          pkgs.zsh-powerlevel10k
          pkgs.gnupg
          pkgs.kubectl
          pkgs.krew
          pkgs.k9s      
          pkgs.go-containerregistry
          pkgs.kustomize
	  pkgs.lima
          pkgs.skopeo
          pkgs.goreleaser
          pkgs.turso-cli
          pkgs.buf
          (pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin])

];




    nix.distributedBuilds = true;
    nix.buildMachines = [{
     hostName = "lima-default";
     sshUser = "harsh";
     protocol = "ssh-ng";
     sshKey = "/Users/harsh/.lima/_config/user";
     systems = [ "x86_64-linux" ];
     maxJobs = 2;
     speedFactor = 2;
     supportedFeatures = [ "kvm" ];
     mandatoryFeatures = [ ];
}];



      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
       programs.zsh.enable = true;  # default shell on catalina

      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#harshs-Mac-mini
    darwinConfigurations."harshs-Mac-mini" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."harshs-Mac-mini".pkgs;
  };
}

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
      environment.systemPackages = [ pkgs.vim
          pkgs.go_1_24
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
          pkgs.skopeo
          pkgs.goreleaser
          pkgs.buf
          pkgs.grpcui
          pkgs.grpcurl
          pkgs.azure-cli
          pkgs.libpq
          pkgs.gum
          pkgs.buf
          pkgs.aws-iam-authenticator
          (pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin]) 
        ];
      

# nix.package = pkgs.nix;
       nix.enable = false;
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
        
      security.pam.services.sudo_local.touchIdAuth = true;


      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";


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

{
  description = "NixOS configuration for all my machines — feature modules, every one off until a host enables it";

  # ---------------------------------------------------------------------------
  # INPUTS — every external source this configuration depends on.
  # Exact revisions are pinned in flake.lock.
  # Update them all with:  nix flake update   (or: nh os switch --update)
  # ---------------------------------------------------------------------------
  inputs = {
    # Rolling package set — closest match to CachyOS/Arch.
    # For the stable release instead, use "github:NixOS/nixpkgs/nixos-26.05"
    # and change home-manager below to "github:nix-community/home-manager/release-26.05".
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # Make Home Manager use *our* nixpkgs instead of downloading its own copy.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # OUTPUTS — what this flake builds.
  # ---------------------------------------------------------------------------
  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # ---- EDIT THESE ---------------------------------------------------------
      # Values about *you*, identical on every machine. Passed to every NixOS
      # and Home Manager module as `vars`. Anything that differs per machine
      # lives in hosts/<name>/default.nix instead.
      # (Your git email lives in modules/programs/dev.nix.)
      vars = rec {
        username = "lucas"; # your login name
        timezone = "Europe/London";
        locale = "en_GB.UTF-8";
        keyboardLayout = "gb";
        # Where this repo lives on every machine (dotfile symlinks and `nh`)
        flakeDir = "/home/${username}/nixos-config";
      };
      # -------------------------------------------------------------------------

      # Every .nix file under modules/, found automatically, so a new feature
      # file is picked up without being listed here (remember to `git add` it).
      # A file or folder whose name starts with "_" is skipped, to park one.
      featureModules = lib.filter (
        file:
        let
          relative = lib.removePrefix (toString ./modules) (toString file);
        in
        lib.hasSuffix ".nix" relative && !lib.hasInfix "/_" relative
      ) (lib.filesystem.listFilesRecursive ./modules);

      # One NixOS system per host. Every host gets every module under
      # modules/ (features + your user), each OFF until the host's own
      # default.nix sets its `my.*.enable`.
      mkHost =
        hostName: hostDir:
        lib.nixosSystem {
          # Extra arguments made available to every NixOS module
          specialArgs = { inherit inputs vars; };

          modules = featureModules ++ [
            # Declares the home-manager.* options; does nothing until
            # my.system.home-manager.enable switches it on.
            home-manager.nixosModules.home-manager
            { networking.hostName = hostName; }
            hostDir
          ];
        };
    in
    {
      # The attribute name is the hostname. `nh os switch` and
      # `nixos-rebuild switch --flake .` pick the one matching the machine
      # they run on, so the same command works everywhere.
      # A new machine = a folder under hosts/ + a line here.
      nixosConfigurations = {
        PrimaryLaptop = mkHost "PrimaryLaptop" ./hosts/PrimaryLaptop;
        GamingDesktop = mkHost "GamingDesktop" ./hosts/GamingDesktop;
        # nixos-server = mkHost "nixos-server" ./hosts/nixos-server;  # from hosts/server-template
      };

      # `nix fmt` formats every .nix file in the repo
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}

{
  description = "Example Python development environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # also valid: "nixpkgs"
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/ARM Linux
        "aarch64-linux" # 64-bit AMD Linux
        "x86_64-darwin" # 64-bit Intel/ARM macOS
        "aarch64-darwin" # 64-bit Apple Silicon
      ];

      # Helper to provide system-specific attributes
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = f: genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default =
          let
            # Use Python 3.11
            python = pkgs.python311;
            pythonPackages = pkgs.python311Packages;
          in
          pkgs.mkShell {
            venvDir = "./.venv";
            # The Nix packages provided in the environment
            buildInputs = [
              python
              pythonPackages.venvShellHook

              pkgs.libxml2
              pkgs.libxslt
              pkgs.curl
            ];

              # Run this command, only after creating the virtual environment
              postVenvCreation = ''
                unset SOURCE_DATE_EPOCH
              '';

              # Now we can execute any commands within the virtual environment.
              # This is optional and can be left out to run pip manually.
              postShellHook = ''
                # allow pip to install wheels
                unset SOURCE_DATE_EPOCH
              '';
          };
      });
    };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        packageJSON = pkgs.lib.importJSON ./package.json;
      in {
        packages = rec {
          site-src = pkgs.mkYarnPackage rec {
            name = "${packageJSON.name}-site-${version}";
            version = packageJSON.version;
            src = ./.;
            packageJson = "${src}/package.json";
            yarnLock = "${src}/yarn.lock";
            buildPhase = ''
              yarn --offline build
            '';
            distPhase = "true";
          };

          default = pkgs.writeShellApplication {
            name = packageJSON.name;
            runtimeInputs = [site-src pkgs.nodejs];
            text = ''
              node ${site-src}/libexec/${packageJSON.name}/deps/${packageJSON.name}/build
            '';
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = [pkgs.yarn pkgs.nodejs];
        };
      }
    );
}

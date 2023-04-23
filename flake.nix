{
  description = "Piaf Nix Flake";

  inputs.nix-filter.url = "github:numtide/nix-filter";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.inputs.flake-utils.follows = "flake-utils";
  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_5_0.overrideScope' (oself: osuper: {
            reason = osuper.reason.overrideAttrs (o: {
              src = super.fetchFromGitHub {
                owner = "reasonml";
                repo = "reason";
                rev = "6401d10f2d1e2c8e1973c0de61d3c27d70b37248";
                hash = "sha256-QJORWjqGuz6pLhZTFLhWxofDsa4dAquVtwhdbGrv0pE=";
              };
              propagatedBuildInputs = o.propagatedBuildInputs ++ (with oself; [ dune-build-info ppxlib ]);
            });
          });
        });
      in
      rec {
        packages.default = pkgs.callPackage ./nix {
          nix-filter = nix-filter.lib;
        };
        devShells.default = pkgs.callPackage ./nix/shell.nix { inherit packages; };
      });
}

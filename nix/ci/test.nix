{ ocamlVersion }:

let
  flake = builtins.getFlake (builtins.unsafeDiscardStringContext ./../..);
  system = builtins.currentSystem;
  pkgs = flake.inputs.nixpkgs.legacyPackages."${system}".extend (self: super: {
    ocamlPackages = super.ocaml-ng.ocamlPackages_5_0.overrideScope' (oself: osuper: { });
  });

  lock = builtins.fromJSON (builtins.readFile ./../../flake.lock);
  nix-filter-src = builtins.fetchGit {
    url = with lock.nodes.nix-filter.locked; "https://github.com/${owner}/${repo}";
    inherit (lock.nodes.nix-filter.locked) rev;
    # inherit (lock.nodes.nixpkgs.original) ref;
    allRefs = true;
  };
  nix-filter = import "${nix-filter-src}";

  inherit (pkgs) stdenv ocamlPackages callPackage;

  pkg = callPackage ./.. {
    doCheck = false;
    inherit nix-filter;
  };
in

stdenv.mkDerivation {
  name = "ppx_jsx_embed-tests";
  src = ./../..;

  dontBuild = true;

  installPhase = ''
    touch $out
  '';

  nativeBuildInputs = with ocamlPackages; [ ocaml dune findlib ocamlformat ];
  buildInputs = [ pkg ];

  doCheck = true;
  checkPhase = ''
    # Check code is formatted with OCamlformat
    dune build @fmt
  '';
}

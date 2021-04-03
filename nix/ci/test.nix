{ ocamlVersion }:

let
  pkgs = import ../sources.nix { inherit ocamlVersion; };
  inherit (pkgs) lib stdenv fetchTarball ocamlPackages;

  pkg = pkgs.callPackage ./.. {
    doCheck = true;
  };
  drvs = lib.filterAttrs (_: value: lib.isDerivation value) pkg;

in

stdenv.mkDerivation {
  name = "ppx_jsx_embed-tests";
  src = lib.filterGitSource {
    src = ./../..;
    files = [ ".ocamlformat" ];
  };

  dontBuild = true;

  installPhase = ''
    touch $out
  '';

  buildInputs = (lib.attrValues drvs) ++ (with ocamlPackages; [ ocaml dune findlib pkgs.ocamlformat ]);

  doCheck = true;
  checkPhase = ''
    # Check code is formatted with OCamlformat
    dune build @fmt
  '';
}

{ lib, ocamlPackages, doCheck ? false, nix-filter }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_jsx_embed";
  version = "0.0.0";

  src = with nix-filter; filter {
    root = ./..;
    include = [ "src" "test" "dune" "dune-project" "ppx_jsx_embed.opam" ];
  };
  propagatedBuildInputs = [ reason ppxlib ];

  inherit doCheck;
}

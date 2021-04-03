{ lib, ocamlPackages, doCheck ? false }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_jsx_embed";
  version = "0.0.0";

  src = lib.filterGitSource {
    src = ./..;
    dirs = [ "src" "test" ];
    files = [ "dune" "dune-project" "ppx_jsx_embed.opam" ];
  };

  useDune2 = true;
  propagatedBuildInputs = [ reason ppxlib ];

  inherit doCheck;
}

{ release-mode ? false }:
let
  pkgs = import ./nix/sources.nix { };
  inherit (pkgs) lib;
  pkg = pkgs.callPackage ./nix { };
  drvs = lib.filterAttrs (_: value: lib.isDerivation value) pkg;

  filterDrvs = inputs:
    lib.filter
      (drv:
        # we wanna filter our own packages so we don't build them when entering
        # the shell. They always have `pname`
        !(lib.hasAttr "pname" drv) ||
        drv.pname == null ||
        !(lib.any (name: name == drv.pname || name == drv.name) (lib.attrNames drvs)))
      inputs;

in
with pkgs;

(mkShell {
  inputsFrom = lib.attrValues drvs;
  buildInputs =
    (if release-mode then [
      cacert
      curl
      ocamlPackages.dune-release
      git
      opam
    ] else [ ]) ++
    (with ocamlPackages; [ merlin ocamlformat utop ]);
}).overrideAttrs (o: {
  propagatedBuildInputs = filterDrvs o.propagatedBuildInputs;
  buildInputs = filterDrvs o.buildInputs;
})

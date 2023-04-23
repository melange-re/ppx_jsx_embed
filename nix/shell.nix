{ packages, ocamlPackages, lib, mkShell }:

mkShell {
  inputsFrom = lib.attrValues packages;
  buildInputs = with ocamlPackages; [ merlin ocamlformat utop ];
}

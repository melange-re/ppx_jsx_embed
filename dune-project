(lang dune 2.0)

(name ppx_jsx_embed)

(generate_opam_files true)

(source
 (github melange/ppx_jsx_embed))

(license BSD-3-clause)

(maintainers "Antonio Monteiro <anmonteiro@gmail.com>")

(authors "Antonio Monteiro <anmonteiro@gmail.com>")

(package
 (name ppx_jsx_embed)
 (synopsis "A preprocessor extension for embedding Reason JSX in OCaml")
 (description
  "Ppx_jsx_embed allows using Reason JSX inside `{%jsx| <reason-here> |}`")
 (depends
  (ocaml
   (>= "4.08"))
  reason
  (ppxlib
   (>= "0.22"))))

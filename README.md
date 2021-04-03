# ppx_jsx_embed

`ppx_jsx_embed` allows embedding of Reason JSX within `.ml` files.

## Installation

Install the library and its dependencies via [OPAM][opam]:

[opam]: http://opam.ocaml.org/

```bash
opam install ppx_jsx_embed
```

## Usage

```ocaml
let[@react.component] my_component ~children = {%jsx|
    <div id="jsx_works" />
  |}
```

## License

ppx_jsx_embed is distributed under the 3-Clause BSD License, see
[LICENSE](./LICENSE).


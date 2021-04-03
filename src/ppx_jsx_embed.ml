(*----------------------------------------------------------------------------
 *  Copyright (c) 2021 António Nuno Monteiro
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *
 *  3. Neither the name of the copyright holder nor the names of its
 *  contributors may be used to endorse or promote products derived from this
 *  software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *---------------------------------------------------------------------------*)

open Ppxlib
module RE = Reason_toolchain.RE

let setup_lexbuf_from_string ~loc ~parser source =
  try
    let lexbuf = Lexing.from_string source in
    Lexing.set_position lexbuf loc.loc_start;
    parser lexbuf
  with
  | Reason_errors.Reason_error _ as rexn ->
    raise rexn
  | Sys_error _ as exn ->
    (* file doesn't exist *)
    raise exn
  | _ ->
    failwith "NYI: different error"

let parse_reason_impl omp_ast =
  let omp_ast =
    Reason_syntax_util.(
      apply_mapper_to_structure
        omp_ast
        (backport_letopt_mapper remove_stylistic_attrs_mapper))
  in
  Reason_toolchain.To_current.copy_structure omp_ast

let parse_implementation_source ~loc source =
  let omp_ast =
    setup_lexbuf_from_string ~loc ~parser:RE.implementation source
  in
  parse_reason_impl omp_ast

let mapper =
  object
    inherit Ast_traverse.map as super

    method! expression expr =
      match expr.pexp_desc with
      | Pexp_extension
          ( { txt = "jsx"; _ }
          , PStr
              [ { pstr_desc =
                    Pstr_eval
                      ( { pexp_desc =
                            Pexp_constant (Pconst_string (reason, loc, _))
                        ; _
                        }
                      , _attrs )
                ; _
                }
              ] ) ->
        (match parse_implementation_source ~loc reason with
        | [ { pstr_desc = Pstr_eval (reason_expression, _); _ } ] ->
          super#expression reason_expression
        | _ ->
          assert false)
      | _ ->
        super#expression expr
  end

let structure_mapper s = mapper#structure s

let () =
  Ppxlib.Driver.register_transformation
    ~preprocess_impl:structure_mapper
    "jsx_embed"

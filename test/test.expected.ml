let x ~children  = ((div ~id:"omg" ~children:[] ())[@JSX ])[@@react.component
                                                             ]
let x ~some_prop  ~children  =
  ((div ~some_prop ~other_prop:some_prop ~children:[] ())[@JSX ])[@@react.component
                                                                   ]

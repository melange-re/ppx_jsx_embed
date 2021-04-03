let[@react.component] x ~children = {%jsx|
    <div id="omg" />
  |}

let[@react.component] x ~some_prop ~children =
  {%jsx|
    <div some_prop other_prop=some_prop />
  |}

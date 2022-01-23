let hello name = ("Hello, " ^ name) |> print_endline

let add a b = a + b |> string_of_int |> print_endline

let do_nativeint_string a =
  a
  |> Ctypes.(!@)
  |> print_endline
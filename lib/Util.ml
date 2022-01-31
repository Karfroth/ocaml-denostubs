let hello name = ("Hello, " ^ name) |> print_endline

let add a b = a + b |> string_of_int |> print_endline

let do_nativeint_string a =
  let asdf = a |> (Ctypes.from_voidp Ctypes.char) |> Ctypes.coerce (Ctypes.ptr Ctypes.char) (Ctypes.string) in
  let res = String.concat " " ["String from Deno:"; asdf] in
  (Ctypes.coerce (Ctypes.string) (Ctypes.ptr Ctypes.char) res) |> Ctypes.to_voidp

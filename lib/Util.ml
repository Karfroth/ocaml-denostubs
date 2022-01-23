let hello name = ("Hello, " ^ name) |> print_endline

let add a b = a + b |> string_of_int |> print_endline

let do_nativeint_string a =
  a |> Ctypes.to_voidp |> Ctypes.raw_address_of_ptr |> Nativeint.to_string |> print_endline;
  let asdf = a |> (Ctypes.from_voidp Ctypes.char) in
  print_endline "coerce";
  (Ctypes.coerce (Ctypes.ptr Ctypes.char) (Ctypes.string) asdf) |> print_endline;
  print_endline "I did something";
  (Ctypes.coerce (Ctypes.string) (Ctypes.ptr Ctypes.char) "String from ocaml") |> Ctypes.to_voidp

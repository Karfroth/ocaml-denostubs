open Denostubs_types

module Denostubs_inverted = Denostubs_inverted

module Export = struct
  let prim_to_deno_typ (type a) (p: a Ctypes_primitive_types.prim) =
    match p with
    | Char | Schar -> Some "i8"
    | Uchar -> Some "u8"
    | Short -> Some "i16"
    | Ushort -> Some "u16"
    | Int | Sint -> Some "i32"
    | Uint -> Some "u32"
    | Long | Llong -> Some "i64"
    | Ulong | Ullong -> Some "u64"
    | Size_t -> Some "isize"
    | Float -> Some "f32"
    | Double -> Some "f64"
    | Nativeint -> Some "pointer"
    | _ -> None
    (* Hope someday supports all *)
    (* 
      Int8_t -> Some "i8"
      Int16_t -> Some "i16"
      Int32_t -> Some "i32"
      Int64_t -> Some "i64"
      Uint8_t -> Some "u8"
      Uint16_t -> Some "u16"
      Uint32_t -> Some "u32"
      Uint64_t -> Some "u64"
      Bool
      Camlint
      LDouble
      Complex32
      Complex64
      Complexld
    *)

  let static_typ_to_deno_typ (type a) (t: a Ctypes.typ) =
    match t with
    | Ctypes_static.Void -> Some "void"
    | Ctypes_static.Primitive p -> prim_to_deno_typ p
    | Ctypes_static.Pointer _ -> Some "pointer"
    | _ -> print_endline "Only primitive and void types are supported"; None

  let rec fn_to_deno_typ: type a. a Ctypes.fn -> string option list = function
  | Returns t -> [static_typ_to_deno_typ t]
  | Function (l, r) -> (static_typ_to_deno_typ l) :: (fn_to_deno_typ r)

  let process_structure fmt = function
  | Structure (Struct { tag; _ }) ->
    Format.fprintf fmt "type %s = Deno.UnsafePointer & { _ocamlFFI: %s } " tag tag;
  | Structure (Ctypes_static.Primitive _) -> print_endline "Primitive not supported for structure"
  | Structure (Ctypes_static.View _) -> print_endline "View not supported for structure"
  | Structure (Ctypes_static.Bigarray _) -> print_endline "Bigarray not supported for structure"

  let gen_structures fmt structures =
    structures |> List.iter (fun s -> process_structure fmt s) |> ignore;
  ;;

  let gen_fn_imports fmt funcs =
    Format.fprintf fmt
      "function loadLib(libPath: string) {\n";
    Format.fprintf fmt
      "  return Deno.dlopen(libPath, {\n";
    Format.fprintf fmt
      "    'init': { parameters: [], result: 'void' },\n";
    let fns_deno_typs = List.map (fun (Func { fn_typ; name=fn_name; promisify; _ }) ->
      let fn_deno_typ = fn_typ
      |> fn_to_deno_typ in
      (fn_name, promisify, fn_deno_typ)
    ) funcs in
    let (valid_fns, invalid_fns) = List.partition (fun (_, _, fn_deno_typ) -> 
      Option.bind (List.find_opt (Option.is_none) fn_deno_typ) (fun x -> x)
      |> Option.is_some
    ) fns_deno_typs in
    List.iter (fun (name, _, _) ->
      print_endline ("Stub for " ^ name ^ " is not generated because it includes unsupported type(s)");
    ) invalid_fns;
    List.iter (fun (name, promisify, fn_deno_typ) ->
      print_endline ("Processing " ^ name);
      Format.fprintf fmt "    '%s': " name;
      Format.fprintf fmt "{ parameters: [";
      let rec aux = function
      | [] ->
        (Format.fprintf fmt "}") |> ignore;
      | t :: [] ->
        t
        |> Option.map(fun x -> (x, promisify))
        |> Option.iter (fun (r, p) -> Format.fprintf fmt "], result: '%s', nonblocking: %b },\n" r p)
      | h :: t ->
        Option.iter (Format.fprintf fmt "'%s', ") h;
        aux t
      in
      aux fn_deno_typ;
    ) valid_fns;
    Format.fprintf fmt
      "  });\n}";
    ()

  let write_ts fmt (module D: Denostubs_inverted.DEFINITIONS) =
    gen_structures fmt D.structures;
    gen_fn_imports fmt D.functions

  let write_deno_c_stub fmt =
    Format.fprintf fmt
      "#include <caml/callback.h>\n\n";
    Format.fprintf fmt
      "void init() {\n";
    Format.fprintf fmt
      "  char *argv = NULL;\n";
    Format.fprintf fmt
      "  caml_startup(&argv);\n";
    Format.fprintf fmt
      "}\n"
end

include Export
open Denostubs_types

module Denostubs_inverted = Denostubs_inverted

module Export = struct
  let functions decls =
    List.fold_right(fun v acc ->
      match v with
      | Decl_fn fn -> fn :: acc
      | _ -> acc
    ) decls []

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

  let gen_ts fmt funcs =
    Format.fprintf fmt
      "function loadLib(libPath: string) {\n";
    Format.fprintf fmt
      "  return Deno.dlopen(libPath, {\n";
    Format.fprintf fmt
      "    'init': { parameters: [], result: 'void' },\n";
    List.iter (fun (Fn (fn_name, fn)) ->
      print_endline ("Processing " ^ fn_name);
      let res = fn_to_deno_typ fn in
      match List.find_opt Option.is_none res with
      | None ->
        Format.fprintf fmt "    '%s': " fn_name;
        Format.fprintf fmt "{ parameters: [";
        let rec aux = function
        | [] ->
          (Format.fprintf fmt "}") |> ignore;
        | t :: [] ->
          Option.iter (Format.fprintf fmt "], result: '%s' },\n") t 
        | h :: t ->
          Option.iter (Format.fprintf fmt "'%s', ") h;
          aux t
        in
        aux res;
      | _ -> print_endline ("Stub for " ^ fn_name ^ " is not generated because it includes unsupported type(s)");
        (* List.iter (function Some x -> print_endline x | None -> print_endline "" ) res; *)
    ) funcs;
    Format.fprintf fmt
      "  });\n}";
    ()
  ;;

  let write_ts fmt (module B: Cstubs_inverted.BINDINGS) =
    let m, decls = collector () in
    let module M = B((val m)) in
    gen_ts fmt (functions (decls ()))

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
      "}\n";;
end

include Export
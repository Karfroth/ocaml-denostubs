type fn_meta = {
  fn_runtime_lock : bool;
  fn_name         : string;
}
type fn_info = Fn : fn_meta * (_ -> _) Ctypes.fn -> fn_info
type ty = Ty : _ Ctypes.typ -> ty
type typedef = Typedef : _ Ctypes.typ * string -> typedef
type enum = Enum : (string * int64) list * _ Ctypes.typ -> enum
type decl =
    Decl_fn of fn_info
  | Decl_ty of ty
  | Decl_typedef of typedef
  | Decl_enum of enum

let collector () : (module Cstubs_inverted.INTERNAL) * (unit -> decl list) =
  let decls = ref [] in
  let push d = decls := d :: !decls in
  ((module
    struct
      let enum constants typ = push (Decl_enum (Enum (constants, typ)))
      let structure typ = push (Decl_ty (Ty typ))
      let union typ = push (Decl_ty (Ty typ))
      let typedef typ name = push (Decl_typedef (Typedef (typ, name)))
      let internal ?(runtime_lock=false) name fn _ =
        let meta = { fn_runtime_lock = runtime_lock; fn_name = name } in
        push (Decl_fn ((Fn (meta, fn))))
    end),
    (fun () -> List.rev !decls))

let functions decls =
  List.fold_right(fun v acc ->
    match v with
    | Decl_fn fn -> fn :: acc
    | _ -> acc
  ) decls []

let prim_to_deno_typ (type a) (p: a Ctypes_primitive_types.prim) =
  match p with
  | Int8_t -> Some "i8"
  | Int16_t -> Some "i16"
  | Int -> Some "i32"
  | Int32_t -> Some "i32"
  | Uint -> Some "u32"
  | Long -> Some "i64"
  | Int64_t -> Some "i64"
  | Ulong -> Some "u64"
  | Size_t -> Some "isize"
  | Float -> Some "f32"
  | Double -> Some "f64"
  | _ -> None
  (* Hope someday supports all *)
  (* 
  | Char -> "Char"
  | Schar -> "Schar"
  | Uchar -> "Uchar"
  | Bool -> "Bool"
  | Short -> "Short"
  | Int -> "Int"
  | Long -> "Long"
  | Llong -> "Llong"
  | Ushort -> "Ushort"
  | Sint -> "Sint"
  | Uint -> "Uint"
  | Ulong -> "Ulong"
  | Ullong -> "Ullong"
  | Size_t -> "Size_t"
  | Int8_t -> "Int8_t"
  | Int16_t -> "Int16_t"
  | Int32_t -> "Int32_t"
  | Int64_t -> "Int64_t"
  | Uint8_t -> "Uint8_t"
  | Uint16_t -> "Uint16_t"
  | Uint32_t -> "Uint32_t"
  | Uint64_t -> "Uint64_t"
  | Camlint -> "Camlint"
  | Nativeint -> "Nativeint"
  | Float -> "Float"
  | Double -> "Double"
  | LDouble -> "LDouble"
  | Complex32 -> "Complex32"
  | Complex64 -> "Complex64"
  | Complexld -> "Complexld"
  *)

let static_typ_to_deno_typ (type a) (t: a Ctypes.typ) =
  match t with
  | Ctypes_static.Void -> Some "void"
  | Ctypes_static.Primitive p -> prim_to_deno_typ p
  | _ -> print_endline "static_typ_to_deno_typ not prim"; None

let rec asdf: type a. a Ctypes.fn -> string option list = function
| Returns t -> [static_typ_to_deno_typ t]
| Function (l, r) -> (static_typ_to_deno_typ l) :: (asdf r)

let gen_ts fmt register funcs =
  Format.fprintf fmt
    "let libSuffix = 'so';\n";
  Format.fprintf fmt
    "if (Deno.build.os == 'windows') {\n  libSuffix = 'dll'\n}\n";
  Format.fprintf fmt
    "const libName = `./mylib.${libSuffix}`;\n";
  Format.fprintf fmt
    "const dylib = Deno.dlopen(libName, {\n";
  Format.fprintf fmt
    "  'init': { parameters: [], result: 'void' },\n";
  List.iter (fun (Fn ({fn_name; _}, fn)) ->
    print_endline ("Processing " ^ fn_name);
    let res = asdf fn in
    match List.find_opt Option.is_none res with
    | None ->
      Format.fprintf fmt "  '%s': " fn_name;
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
    | _ -> print_endline (fn_name ^ " includes unsupported type");
      (* List.iter (function Some x -> print_endline x | None -> print_endline "" ) res; *)
  ) funcs;
  Format.fprintf fmt
    "});\n";
  ()
;;

let write_ts fmt ~prefix (module B: Cstubs_inverted.BINDINGS) =
  let register = prefix ^ "_register" in
  let m, decls = collector () in
  let module M = B((val m)) in
  gen_ts fmt register (functions (decls ()))

let write_deno_c fmt =
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

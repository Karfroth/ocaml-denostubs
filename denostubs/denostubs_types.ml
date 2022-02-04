type enum_def = Enum : (string * int64) list * _ Ctypes.typ -> enum_def
type structure_def = Structure : _ Ctypes.structure Ctypes.typ -> structure_def
type union_def = Union : _ Ctypes.union Ctypes.typ -> union_def
type typedef_def = Typedef : (_ Ctypes.typ * string) -> typedef_def

type ('a, 'b) func_info = {
  promisify: bool;
  fn_typ: ('a -> 'b) Ctypes_static.fn;
  fn: 'a -> 'b;
  name: string;
  runtime_lock: bool;
}
type func_def = Func: _ func_info -> func_def

let rec typ_to_deno_typ: type a. a Ctypes.typ -> string =
  function
  | Void -> ""
  | Primitive p -> ""
  | View { read; write; format_typ; format; ty } -> ""
  | Abstract { aname; asize; aalignment } -> ""
  | Struct { tag ; spec; fields } -> ""
  | Union { utag; uspec; ufields } -> ""
  | Pointer ty -> ""
  | Funptr fn -> ""
  | Array (ty, n) -> ""
  | Bigarray ba -> ""
  | OCaml String -> ""
  | OCaml Bytes -> ""
  | OCaml FloatArray -> ""
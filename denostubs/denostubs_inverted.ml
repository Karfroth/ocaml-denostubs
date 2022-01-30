module type DENOSTUBS_INTERNAL = sig
  val enum : (string * int64) list -> 'a Ctypes.typ -> unit
  val structure : _ Ctypes.structure Ctypes.typ -> unit
  val union : _ Ctypes.union Ctypes.typ -> unit
  val typedef : _ Ctypes.typ -> string -> unit

  val internal: ?promisify: bool -> ?runtime_lock:bool -> string -> ('a -> 'b) Ctypes_static.fn -> ('a -> 'b) -> unit
end
module type DENOSTUBS_BINDINGS = functor (I: DENOSTUBS_INTERNAL) -> sig end

module type DEF = functor () -> sig
  val enum : (string * int64) list -> 'a Ctypes.typ -> unit
  val structure : _ Ctypes.structure Ctypes.typ -> unit
  val union : _ Ctypes.union Ctypes.typ -> unit
  val typedef : _ Ctypes.typ -> string -> unit

  val internal: ?promisify: bool -> ?runtime_lock:bool -> string -> ('a -> 'b) Ctypes_static.fn -> ('a -> 'b) -> unit

  val cstubs_binding: unit -> (module Cstubs_inverted.BINDINGS)
  val denostubs_binding: unit -> (module DENOSTUBS_BINDINGS)
end

module DEF: DEF = functor () -> struct
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

  let enums = ref []
  let structures = ref []
  let unions = ref []
  let typedefs = ref[]
  let funcs = ref []

  let enum constants typ = enums := Enum (constants, typ) :: !enums
  let structure typ = structures := Structure typ :: !structures
  let union typ = unions := Union typ :: !unions
  let typedef typ name = typedefs := Typedef (typ, name) :: !typedefs

  let internal
    ?(promisify=false)
    ?(runtime_lock=false)
    (name: string)
    (fn_tpy: ('a -> 'b) Ctypes_static.fn)
    (fn: 'a -> 'b): unit = 
      let def = Func {
        promisify = promisify;
        fn_typ = fn_tpy;
        fn = fn;
        runtime_lock = runtime_lock;
        name = name
      } in
      funcs := def :: !funcs

    let cstubs_binding (): (module Cstubs_inverted.BINDINGS) =
      let module Bindings: Cstubs_inverted.BINDINGS = functor (I: Cstubs_inverted.INTERNAL) -> struct
        !enums |> List.rev |> List.iter (function Enum (constants, typ) -> I.enum constants typ) |> ignore;
        !structures |> List.rev |> List.iter (function Structure typ -> I.structure typ) |> ignore;
        !unions |> List.rev |> List.iter (function Union typ -> I.union typ) |> ignore;
        !typedefs |> List.rev |> List.iter (function Typedef (typ, name) -> I.typedef typ name) |> ignore;

        !funcs |> List.rev |> List.iter (function Func f -> 
          I.internal ~runtime_lock:f.runtime_lock f.name f.fn_typ f.fn
        ) |> ignore;
      end in
      (module Bindings)
    let denostubs_binding (): (module DENOSTUBS_BINDINGS) =
      let module Bindings: DENOSTUBS_BINDINGS = functor (I: DENOSTUBS_INTERNAL) -> struct
        !enums |> List.rev |> List.iter (function Enum (constants, typ) -> I.enum constants typ) |> ignore;
        !structures |> List.rev |> List.iter (function Structure typ -> I.structure typ) |> ignore;
        !unions |> List.rev |> List.iter (function Union typ -> I.union typ) |> ignore;
        !typedefs |> List.rev |> List.iter (function Typedef (typ, name) -> I.typedef typ name) |> ignore;

        !funcs |> List.rev |> List.iter (function Func f -> 
          I.internal ~promisify:f.promisify ~runtime_lock:f.runtime_lock f.name f.fn_typ f.fn
        ) |> ignore;
      end in
      (module Bindings)
end

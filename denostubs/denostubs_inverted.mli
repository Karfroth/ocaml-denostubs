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

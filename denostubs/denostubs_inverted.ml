module type INTERNAL = sig
  include Cstubs_inverted.INTERNAL

  val promise_fn: string -> unit
end

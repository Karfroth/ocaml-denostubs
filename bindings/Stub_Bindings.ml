open Ctypes

module Stubs(I: Cstubs_inverted.INTERNAL) = struct
  let () = I.internal "lib_add" (int @-> int @-> returning(void)) Lib.Util.add
  let () = I.internal "lib_hello" (string @-> returning(void)) Lib.Util.hello
  let () = I.internal "lib_do_nativeint_string" ((ptr void) @-> returning(ptr void)) Lib.Util.do_nativeint_string
end
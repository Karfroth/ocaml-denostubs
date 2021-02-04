open Ctypes

module Stubs(I: Cstubs_inverted.INTERNAL) = struct
  let () = I.internal "lib_add" (int @-> int @-> returning(void)) Lib.Util.add
  let () = I.internal "lib_hello" (string @-> returning(void)) Lib.Util.hello
end
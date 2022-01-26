(*
Copyright (c) 2013 Jeremy Yallop

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

type fn_info = Fn : string * (_ -> _) Ctypes.fn -> fn_info
type ty = Ty : _ Ctypes.typ -> ty
type typedef = Typedef : _ Ctypes.typ * string -> typedef
type enum = Enum : (string * int64) list * _ Ctypes.typ -> enum

type decl =
| Decl_fn of fn_info
| Decl_ty of ty
| Decl_typedef of typedef
| Decl_enum of enum

let collector () : (module Denostubs_inverted.INTERNAL) * (unit -> decl list) =
  let decls = ref [] in
  let push d = decls := d :: !decls in

  let promise_fns = ref [] in
  let push_promise_fns n = promise_fns := n :: !promise_fns in
  let module Internal: Denostubs_inverted.INTERNAL = struct
    let enum constants typ = push (Decl_enum (Enum (constants, typ)))
    let structure typ = push (Decl_ty (Ty typ))
    let union typ = push (Decl_ty (Ty typ))
    let typedef typ name = push (Decl_typedef (Typedef (typ, name)))
    let internal ?runtime_lock:_ name fn _ =
      push (Decl_fn ((Fn (name, fn))))
    let promise_fn name = push_promise_fns name
  end in
  (module Internal), (fun () -> List.rev !decls)

(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types (GADT) 
                              and higher order abstract syntax  (HOAS) *)

type ('a, 'b) poly = { f : 'a . 'a typ -> 'b }

and _ typ = 
  | TBase  :                       'a typ            (* base types *)
  | TFun   : 'a typ * 'b typ    -> ('a -> 'b) typ    (* function type *)
  | TAll   : ('a typ -> 'b typ) -> ('a, 'b) poly typ (* forall quantifier *)

and _ exp =
  | Const : 'a                          -> 'a exp            (* constants *)
  | Abs   : 'a typ * ('a exp -> 'b exp) -> ('a -> 'b) exp    (* lambda abstraction *)
  | App   : ('a -> 'b) exp * 'a exp     -> 'b exp            (* function application *)
  | TAbs  : ('a typ -> 'b exp)          -> ('a, 'b) poly exp (* type level abstraction *)
  | TApp  : ('a, 'b) poly exp * 'a typ  -> 'b exp            (* type level function application *)

let rec eval : type a. a exp -> a = function
  | Const  a       -> a
  | Abs    (_, ab) -> fun x -> eval (ab (Const x))
  (* i refuse to explain why this is okay (it's probably not) *)
  | TAbs   ab      -> { f = Obj.magic (fun a -> eval (ab a)) }
  | App    (ab, a) -> eval ab (eval a)
  | TApp   (ab, a) -> (eval ab).f a

let u = Const ()                              (* unit *)
let tunit: unit typ = TBase                   (* unit type *)
let tru = Const true                          (* true *)
let fls = Const false                         (* false *)
let tbool : bool typ = TBase                  (* bool type *)
let nat (a: int) = Const a                    (* naturals *)
let tnat: int typ = TBase                     (* nat type *)
let ( := ) t f = Abs (t, f)                   (* lambda abstraction *)
let ( => ) a b : ('a -> 'b) typ = TFun (a, b) (* function type *)              
let ( @ ) a b = App (a, b)                    (* application *)
let forall f = TAbs f                         (* type level abstraction *)
let tall f = TAll f                           (* forall type *)
let ( @@ ) a b = TApp (a, b)                  (* type level application *)

(* church numerals *) 
let bool_ () = tall (fun alpha -> (alpha => (alpha => alpha)))
let true_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> x)))
let false_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> y)))
let and_ () = bool_() := (fun x -> bool_() := (fun y -> ((x @@ bool_()) @ y) @ false_())) 
let or_ () = bool_() := (fun x -> bool_() := (fun y -> ((x @@ bool_()) @ true_()) @ y)) 
let not_ () = bool_() := (fun x -> ((x @@ bool_()) @ false_()) @ true_())
let if_then_else_ () = forall (fun alpha -> bool_() := fun x -> alpha := fun y -> alpha := fun z -> ((x @@ alpha) @ y) @ z)

(* identity function *)
let id_ () = forall (fun alpha -> alpha := (fun x -> x))
let app_int_id_: int = eval ((id_() @@ tnat) @ nat 42)
let app_bool_id_: bool = eval ((id_() @@ tbool) @ tru)

(* exp of all type as parameter *)
let tpoly_id_ () = tall (fun alpha -> (alpha => alpha))
let poly_id_ () = forall (fun alpha -> alpha := fun x -> x)
let build_nat_id_ () = tpoly_id_() := fun f -> f @@ tnat
let build_bool_id_ () = tpoly_id_() := fun f -> f @@ tbool
let nat_id_ () = build_nat_id_() @ poly_id_()
let bool_id_ () = build_bool_id_() @ poly_id_()
let app_int_id_: int = eval (nat_id_() @ nat 42)
let app_bool_id_: bool = eval (bool_id_() @ tru)
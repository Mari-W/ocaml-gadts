(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types (GADT) 
                              and higher order abstract syntax  (HOAS) *)

type poly = { f : 'a 'b . 'a typ -> 'b }

and _ typ = 
  | TBase  :                       'a typ         (* base types *)
  | TFun   : 'a typ * 'b typ    -> ('a -> 'b) typ (* function type *)
  | TAll   : ('a typ -> 'b typ) -> poly typ       (* forall quantifier *)

and _ exp =
  | Const : 'a                          -> 'a exp             (* constants *)
  | Abs   : 'a typ * ('a exp -> 'b exp) -> ('a -> 'b) exp     (* lambda abstraction *)
  | App   : ('a -> 'b) exp * 'a exp     -> 'b exp             (* function application *)
  | TAbs  : ('a typ -> 'b exp)          -> ('a typ -> 'b) exp (* type level abstraction *)
  | TApp  : ('a typ -> 'b) exp * 'a typ -> 'b exp             (* type level function application *)

let rec eval : type a. a exp -> a = function
  | Const  a       -> a
  | Abs    (_, ab) -> fun x -> eval (ab (Const x))
  | TAbs   ab      -> fun t -> eval (ab t)
  | App    (ab, a) -> eval ab (eval a)
  | TApp   (ab, a) -> (eval ab) a

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
(* note: to bypass the OCaml's value restriction TAbs 
   must be wrapped with an unit closure when applying a type,
   this would not be necessary in haskell *)
let ( @@ ) a b = TApp (a, b)                  (* type level application *)
(* note: to express the TAll type we need to hack higher rank polymorphism into OCaml,
   but this does not play well with the evaluator, so TAbs and TApp use a less general version
   of the TAll type as GADT parameter. The use of Obj.magic is only to lift the less general type of 
   an TAbs to TAll, so it should not introduce any logical inconsistencies. *)
let ( @- ) a b = TApp (Const (eval a).f, b)              (* apply typ to tall *)
let ( -@ ) a b = App (a, Const {f = Obj.magic (eval b)}) (* apply exp to tall exp *)

(* church numerals *) 
let bool_ () = tall (fun alpha -> (alpha => (alpha => alpha)))
let true_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> x)))
let false_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> y)))
let and_ () = bool_() := (fun x -> bool_() := (fun y -> ((x  @- bool_()) @ y) @ false_())) 
let or_ () = bool_() := (fun x -> bool_() := (fun y -> ((x @- bool_()) @ true_()) @ y)) 
let not_ () = bool_() := (fun x -> ((x @- bool_()) @ false_()) @ true_())
let if_then_else_ () = forall (fun alpha -> bool_() := fun x -> alpha := fun y -> alpha := fun z -> ((x @- alpha) @ y) @ z)

(* identity function *)
let id_ () = forall (fun alpha -> alpha := (fun x -> x))
let app_int_id_: int = eval ((id_() @@ tnat) @ nat 42)
let app_bool_id_: bool = eval ((id_() @@ tbool) @ tru)

(* exp of all type as parameter *)
let tpoly_id_ = tall (fun alpha -> (alpha => alpha))
let poly_id_ = forall (fun alpha -> alpha := (fun x -> x))
let build_nat_id_ = tpoly_id_ := fun f -> f @- tnat
let build_bool_id_ = tpoly_id_ := fun f -> f @- tbool
let nat_id_ = build_nat_id_ -@ poly_id_
let bool_id_ = build_bool_id_ -@ poly_id_
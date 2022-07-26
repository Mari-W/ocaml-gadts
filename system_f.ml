(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types (GADT) 
                              and higher order abstract syntax  (HOAS) *)
type _ typ = 
  | TBase  :                        'a typ                (* base types *)
  | TFun   : 'a typ * 'b typ    -> ('a -> 'b) typ         (* function type *)
  | TAll   : ('a typ -> 'b typ) -> ('a typ -> 'b) typ     (* forall quantifier *)

and _ exp =
  | Const : 'a                          -> 'a exp             (* constants *)
  | Abs   : 'a typ * ('a exp -> 'b exp) -> ('a -> 'b) exp     (* lambda abstraction *)
  | App   : ('a -> 'b) exp * 'a exp     -> 'b exp             (* function application *)
  | TAbs  : ('a typ -> 'b exp)          -> ('a typ -> 'b) exp (* type level abstraction *)
  | TApp  : ('a typ -> 'b) exp * 'a typ -> 'b exp             (* type level function application *)

let rec eval : type a. a exp -> a = function
  | Const  a       -> a
  | Abs    (_, ab) -> fun x -> eval (ab (Const x))
  | TAbs   ab      -> fun _ -> eval (ab TBase)
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
let all f = TAll f                            (* forall type *)
(* note: to bypass the OCaml's value restriction all TAbs 
   must be wrapped with an unit closure,
   this would not be necessary in haskell *)
let ( @@ ) a b = TApp (a(), b)                (* type level application *)

(* church numerals *) 
let bool_ () = all (fun alpha -> (alpha => (alpha => alpha)))
let true_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> x)))
let false_ () = forall (fun alpha -> alpha := (fun x -> alpha := (fun y -> y)))
let and_ () = bool_() := (fun x -> bool_() := (fun y -> (((fun _ -> x) @@ bool_()) @ y) @ false_())) 
let or_ () = bool_() := (fun x -> bool_() := (fun y -> (((fun _ -> x) @@ bool_()) @ true_()) @ y)) 
let not_ () = bool_() := (fun x -> (((fun _ -> x) @@ bool_()) @ false_()) @ true_())
let if_then_else_ () = forall (fun alpha -> bool_() := fun x -> alpha := fun y -> alpha := fun z -> (((fun _ -> x) @@ alpha) @ y) @ z)

(* other *)
let id_ () = forall (fun alpha -> alpha := (fun x -> x))
let app = (id_ @@ tnat) @ nat 42
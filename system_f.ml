(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types (GADT) 
                              and higher order abstract syntax  (HOAS) *)

type _ typ = 
  | TBase  :                        'a typ    
  | TFun   : 'a typ * 'b typ    -> ('a -> 'b) typ         (* function type *)
  | TAll   : ('a typ -> 'b typ) -> ('a typ -> 'b typ) typ (* forall quantifier *)

and _ exp =
  | Const : 'a                          -> 'a exp
  | Abs   : 'a typ * ('a exp -> 'b exp) -> ('a -> 'b) exp     (* lambda abstraction  *)
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
let pair a b = Const (a, b)                   (* pair *)
let tpair = (TBase, TBase)                    (* pair type *)
let lst (a: 'a list) = Const a                (* list *)
let tlst: 'a list typ = TBase                 (* list type *)
let ( := ) t f = Abs (t, f)                   (* lambda abstraction *)
let ( => ) a b : ('a -> 'b) typ = TFun (a, b) (* function type *)
let ( @ ) a b = App (a, b)                    (* application *)
let forall f = TAbs f                         (* type level abstraction *)
let all f = TAll f                            (* forall type *)

(* note: to bypass the OCaml's value restriction all TAbs must be wrapped with an unit lambda function! *)
let ( @@ ) a b = TApp (a(), b)                (* type level application *)


(* examples *) 
let poly_id () = forall (fun t -> t := (fun x -> x))
let app = (poly_id @@ tnat) @ nat 4
let app_2 = ((poly_id @@ (tbool => tbool)) @ (tbool := (fun x -> x))) @ tru
let two_insts () = all (fun x -> x) := (fun x -> pair (fun x -> x @@ tnat) (fun x -> x @@ tbool))
let poly_id_2 () = forall (fun t -> forall (fun t2 -> t := fun x -> t2 := fun y -> pair x y))
let app_3 = (((fun _ -> (poly_id_2 @@ tnat)) @@ tnat) @ nat 0) @ nat 42

(* todo: prevent double eval in a generic way for all custom constants *)
let (a, b) = eval app_3
let main = print_int (eval b)
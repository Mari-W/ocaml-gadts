(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types and higher order abstract syntax *)

(* represents some type in our language *)
(* the gadt parameter is used to represent the correspondig ocaml type *)
type _ typ = 
  | TBase  :                        'a typ    
  | TFun   : 'a typ * 'b typ     -> ('a -> 'b) typ  (* function type *)
  | TAll   : ('a typ -> 'b typ)  -> ('a -> 'b) typ  (* forall quantifier *)

(* represents some expression in our language *)
(* the gadt parameter is used to represent the correspondig type in our language *)
and _ exp =
  | Const : 'a -> 'a exp
  | Abs   : 'a typ * ('a exp -> 'b exp) -> ('a -> 'b) exp     (* lambda abstraction  *)
  | App   : ('a -> 'b) exp * 'a exp     -> 'b exp             (* function application *)
  | TAbs  : ('a typ -> 'b exp)          -> ('a typ -> 'b) exp (* type level abstraction *)
  | TApp  : ('a typ -> 'b) exp * 'a typ -> 'b exp             (* type level function application *)

let rec eval : type a. a exp -> a = function
  | Const  a        -> a
  | Abs    (_, ab)  -> fun x -> eval (ab (Const x))
  | TAbs   ab       -> fun _ -> eval (ab TBase)
  | App    (ab, a)  -> eval ab (eval a)
  | TApp   (ab, a)  -> (eval ab) a

(* syntax *) 
let u = Const ()                              (* unit *)
let un: unit typ = TBase                      (* unit type *)           
let tru = Const true                          (* true *)
let fls = Const false                         (* false *)
let boolean : bool typ = TBase                (* bool type *)
let num (a:int) = Const a                     (* naturals *)
let nat: int typ = TBase                      (* nat type *)
let pair a b = Const (a, b)                   (* pair *)
let tup = (TBase, TBase)                      (* pair type *)
let ( := ) t f = Abs (t, f)                   (* lambda abstraction *)
let ( => ) a b : ('a -> 'b) typ = TFun (a, b) (* function type *)
let ( @ ) a b = App (a, b)                    (* application *)
let forall f = TAbs f                         (* type level abstraction *)
let all f = TAll f                            (* forall type *)
let ( @@ ) a b = TApp (a(), b)                (* type level application  *)
let ( @: ) a b = fun a -> a @@ b              (* type level application variables of all types *)

(* examples *) 
let poly_id () = forall (fun t -> t := (fun x -> x))
let app = (poly_id @@ nat) @ num 4
let app2 = ((poly_id @@ (boolean => boolean)) @ (boolean := (fun x -> x))) @ tru
let twoInsts () = all (fun x -> x) := (fun x -> pair (x @: nat) (x @: boolean))

let program = app
let main = eval program
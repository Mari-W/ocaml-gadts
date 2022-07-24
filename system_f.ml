(* Marius Weidner <weidner@cs.uni-freiburg.de> *)
(* system f interpreter using generialized algebraic data types and higher order abstract syntax *)


(** represents forall type as ocaml type *)
type ('a, 'b) poly = P
 
(* flags to determine if some [exp] is a value *)
(** is also a value *)
type v
(** is not a value *)
type e

(* represents some type in our language *)
(* the gadt parameter is used to represent the correspondig ocaml type *)
type _ typ = 
  | Unit  :                        unit typ           (* first primitve type *)
  | Bool  :                        bool typ           (* second primitve type *)
  | Fun   : 'a typ * 'b typ     -> ('a -> 'b) typ     (* function type *)
  | All   : ('a typ -> 'b typ)  -> (('a, 'b) poly) typ (* forall quantifier *)

(* represents some expression in our language *)
(* the first gadt parameter is used to represent the correspondig type in our language *)
(* the second gadt parameter is used to differentiate between expressions which are also a value and non-value expressions *)
type (_, _) exp =
  | Unit  :                                            (unit, v) exp            (* unit *)
  | Bool  : bool                                    -> (bool, v) exp            (* bool *)
  | Abs   : 'a typ * (('a, v) exp -> ('b, _) exp)   -> (('a -> 'b), v) exp      (* lambda abstraction  *)
  | App   : (('a -> 'b), _) exp * ('a, _) exp       -> ('b, e) exp              (* function application *)
  | TAbs  : ('a typ -> ('b, v) exp)                 -> ((('a, 'b) poly), v) exp (* type level abstraction *)
  | TApp  : ((('a, 'b) poly), _) exp * 'a typ       -> ('b, e) exp              (* type level function application *)

(* evaluates a given expression *)
(* pattern matching is exhaustive because of the heave gadt usage *)
let rec eval : type a t. (a, t) exp -> (a, v) exp = function
  | Unit             -> Unit
  | Bool b           -> Bool b
  | Abs   (t, ab)    -> Abs (t, ab)
  | TAbs  ab         -> TAbs ab
  | App   (ab, a)    -> begin match eval ab with
    | Abs (t, ab)  -> (eval (ab (eval a)))
  end
  | TApp  (ab, a)    -> begin match eval ab with
    | TAbs ab      -> eval (ab a)
  end 

(* syntax *)
let u = Unit                                 (* unit *)
let un : unit typ = Unit                     (* unit type *)
let tru = Bool true                          (* true *)
let fls = Bool false                         (* false *)
let boolean : bool typ = Bool                (* bool type *)
let ( := ) t f = Abs (t, f)                  (* lambda abstraction *)
let ( => ) a b : ('a -> 'b) typ = Fun (a, b) (* function type *)
let ( @ ) a b = App (a, b)                   (* application *)
let forall f = TAbs f                        (* type level abstraction *)
let all f = All f                            (* forall type *)
let ( @@ ) a b = TApp (a, b)                 (* type level application *)

(* debug *)
let rec dummy : type a. a typ -> (a, v) exp = function
  | Unit        -> Unit
  | Bool        -> Bool true
  | Fun (a, b)  -> Abs (a, fun _ -> dummy b)
  | All ab      -> TAbs (fun x -> dummy (ab x))

let rec show_val : type a. (a, v) exp -> string = function
  | Unit    -> "()"
  | Bool b  -> if b then "true" else "false"
  | Abs (t, ab) -> "lambda"
  | TAbs ab -> "type lambda"

let rec show_typ : type a. a typ -> string = function
  | Unit -> "()"
  | Bool -> "Boolean"
  | Fun (a, b) -> "(" ^ show_typ a ^ " -> " ^ show_typ b ^ ")" 
  | All f -> "Forall"

(* examples *)


let poly_id = forall (fun t -> t := fun x -> x)
let app = (poly_id @@ boolean) @ tru
let program = app
let main = print_endline (show_val (eval program))
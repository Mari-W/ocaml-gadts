type _ atom =
  | Bool : bool -> bool atom
  | Int  : int  -> int  atom

type _ expr =
  | Atom : 'a atom -> 'a expr
  | If   : bool expr * 'a expr * 'a expr -> 'a expr

let rec _eval : 'a. 'a expr -> 'a = 
    fun (type a) (e : a expr) : a -> match e with
      | Atom (Bool b) -> b
      | Atom (Int i)  -> i
      | If (c, i, e)  -> if _eval c then _eval i else _eval e

let rec eval : type a. a expr -> a = function
  | Atom (Bool b) -> b
  | Atom (Int i)  -> i
  | If (c, i, e)  -> if eval c then eval i else eval e
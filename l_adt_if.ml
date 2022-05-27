type atom =
  | Bool of bool
  | Int  of int

type expr =
  | Atom of atom
  | If   of expr * expr * expr

let rec eval: expr -> atom = function
  | Atom a -> a
  | If (c, i, e) -> begin match eval c with
      | Bool true  -> eval i
      | Bool false -> eval e
      | _ -> failwith "expected bool!"
    end;;

eval (If 
     (Atom (Bool true),
     (Atom (Int 42)),
     (Atom (Int 0))));;

eval (If 
     (Atom (Int 42),
     (Atom (Bool false)),
     (Atom (Int 0))))
type expr =
  | Bool of bool
  | Int  of int
  | If   of expr * expr * expr

let rec eval: expr -> expr = function
  | If (c, i, e) -> begin match eval c with
      | Bool true  -> eval i
      | Bool false -> eval e
      | _ -> failwith "expected bool!"
    end
  | e -> e;;

eval (If 
     (Bool true,
     (Int 42),
     (Int 0)));;

eval (If 
     (Int 42,
     (Bool false),
     (Int 0)))
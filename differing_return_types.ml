type (_, _) mode = 
  | Unsafe : ('a, 'a) mode
  | Option : ('a, 'a option) mode

let first : type a r. a list -> (a, r) mode -> r = 
  fun lst mode -> match lst with
    | hd :: tl -> (match mode with
      | Unsafe -> hd
      | Option -> Some hd)
    | [ ] -> (match mode with
      | Unsafe -> failwith "list is empty"
      | Option -> None)

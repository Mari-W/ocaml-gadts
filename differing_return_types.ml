type (_, _) mode = 
  | Unsafe : ('a, 'a) mode
  | Option : ('a, 'a option) mode

let first : type a r. a list -> (a, r) mode -> r = 
  fun lst mde -> match lst with
    | hd :: tl -> (match mde with
      | Unsafe -> hd
      | Option -> Some hd)
    | [ ] -> (match mde with
      | Unsafe -> failwith "list is empty"
      | Option -> None)

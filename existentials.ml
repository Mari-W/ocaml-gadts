type stringable =                          
  Stringable : { 
    item: 'a; 
    to_string: 'a -> string 
  } -> stringable

let print (Stringable s) = 
  print_endline (s.to_string s.item);;

print (Stringable { 
  item = "I have an existential crisis."; 
  to_string = fun s -> s 
})
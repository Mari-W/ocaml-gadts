---
marp: true
title: Generalized Algebraic Data Types in OCaml
author: Marius Weidner
theme: uncover

paginate: true
math: katex
style: |
    :root {
        font-family: 'JetBrains Mono', serif !important;
        font-variant-ligatures: common-ligatures;
    }
    code {
        font-family: 'JetBrains Mono', serif !important;
        font-variant-ligatures: common-ligatures;
        border-radius: 12px;
    }
    pre {
        font-size: 1rem;
        border-radius: 12px;
    }
    p {
        font-family: 'JetBrains Mono', serif !important;
        font-variant-ligatures: common-ligatures;
    }
    section::after {
        background: none
    }
    .columns {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 0.75rem;
    }
    .subtitle {
        font-size: 0.7rem;
        letter-spacing: 0.00000001rem;
    }
    footer {
      color: black;
    }
    
---

<!-- _paginate: false -->
<!-- _footer: Marius Weidner ‒ Lehrstuhl für Programmiersprachen ‒ Proseminar '22 -->

<!-- 
- Wichtiges vorangegangenes Kapitel: Variants
- Der Plan
  - Eigene Sprache `L-If`
  - Nachteile bei Interpreterimplementierung ohne GADTs
  - Vorteile mit 
  - 2 weitere Konzepte mit GADTs
- Übergang: Beginn mit der eignen Sprache
-->

# Generalized Algebraic Data Types
### in OCaml

---

<!--
- Grammatik
- Atoms kleinste Einheit
- Bools & Ints
- Ifs

-->

#### Sprachdefinition

#
#

$$
\begin{align*}

Expr ::=& \text{ } \text{  true} \text{ } \\&| \text{ } \text{false}  \text{ } \\&| \text{ } -^?0..9^+ \\&| \textbf{ if } Expr \textbf{ then } Expr \textbf{ else } Expr
\end{align*}
$$

---

<style scoped> 
  pre {  
    font-size: 0.8rem;
  }
  div.error > pre {
    font-size: 0.777rem;
    border: 0.05rem;
    background-color: rgb(242, 241, 244); 
    border-color: #B00020;
    border-style: solid;
    border-radius: 12px;
  }
</style>

<div class="columns">
<div>

<!--
- atom ist program
- if ist program
- program nested

- ! invalid syntax
- ! int als condition
- ! verschiedene typen in zweigen
-->

Gültige Programme

#
#

```ocaml
true                     
```
```ocaml
if true then 42 else 0   
```
```ocaml
if true then 
  if true then 42 else 0 
else 
  0
```
</div>

<div class="error">

Ungültige Programme

#
#

```ocaml
if true then 0
```
```ocaml
if 0 then true else false
```
```ocaml
if true then 
  if true then 42 else 0
else
  false
```

</div>
</div>

---

<!--
- 
-->

#### In einer Welt ohne GADTs

# 

<style scoped> pre {  font-size: 1rem; }
</style>

```ocaml
type expr =
  | Bool of bool
  | Int  of int
  | If   of expr * expr * expr
```

_<p class="subtitle">Syntaxbaum ohne GADTs</p>_

---

```ocaml
let rec eval : expr -> expr = function
  | If (c, t, e) -> begin match eval c with
      | Bool true  -> eval t
      | Bool false -> eval e
      | _ -> failwith "need bool!"
    end
  | e -> e
```

_<p class="subtitle">Evaluationsfunktion ohne GADTs</p>_

---

<style scoped> pre { font-size: 0.7rem; }
</style>
<div class="columns">
<div>

```ocaml
eval (If 
     (Bool true,
     (Int 42),
     (Int 0)))
```

```ocaml
- : expr = Int 42
```

</div><div>

```ocaml
eval (If 
     (Int 42,
     (Bool false),
     (Int 0)))                  
```
```ocaml
Exception: Failure "need bool!"
```

</div>
</div>

_<p class="subtitle">Beispiele ohne GADTs</p>_

- Ungültige Programmdefinitionen
- Laufzeitfehler im Interpreter   
- Zweige mit verschiedenen Typen

---

#### In einer Welt mit GADTs

#

<style scoped> pre { font-size: 0.9rem; }
</style>

```ocaml
type _ expr =
  | Bool : bool -> bool expr
  | Int  : int  -> int  expr
  | If   : bool expr * 'a expr * 'a expr -> 'a expr
```

_<p class="subtitle">Syntaxbaum mit GADTs</p>_

# 
--- 

<style scoped>  pre { font-size: 0.85rem; }
</style>

```ocaml
let rec eval : .. = function
  | Bool b        -> b
  | Int i         -> i
  | If (c, t, e)  -> if eval c then eval t else eval e
```

_<p class="subtitle">Evaluationsfunktion mit GADTs</p>_

---


<style scoped> 
  pre {  
    font-size: 0.8rem;
  }
  div.error > pre {
    font-size: 0.77rem;
    border: 0.1rem;
    background-color: rgb(242, 241, 244); 
    border-color: #B00020;
    border-style: solid;
    border-radius: 12px;
  }
</style>
<div class="columns">
<div class="error">

```ocaml
eval (If 
     (Int 42,
     (Bool true),
     (Bool false)))
```


</div>
<div class="error">

```ocaml
eval (If 
     (Bool true,
     (Bool false),
     (Int 42)))
```

</div>
</div>

<div class="error">

```
Error: Type int is not compatible with type bool
```

</div>

_<p class="subtitle">Beispiele mit GADTs</p>_

- Nur gültige Programmdefinitionen
- Keine Laufzeitfehler im Interpreter
- Exhaustive Patternmatching

---

#### Locally Abstract Types


<style scoped>  
pre { 
  font-size: 0.85rem;
  border: 0.1rem;
  border-color: #B00020;
  border-style: solid;
  border-radius: 12px;
} 
</style>

```ocaml
let rec eval (type a) (e : a expr) : a = match e with
  | Bool b -> b
  | Int i  -> i
  | If (c, t, e)  -> if eval c then eval t else eval e
```

```
Error: This expression has type a expr but an
       expression was expected of type bool expr      
```

_<p class="subtitle">Evaluationsfunktion mit GADTs</p>_

---

#### Polymorphic Recursion

#
#

<style scoped>  pre { font-size: 0.75rem; }
</style>

```ocaml
let rec eval : 'a. 'a expr -> 'a = 
    fun (type a) (e : a expr) : a -> match e with
      | Bool b -> b
      | Int i  -> i
      | If (c, t, e)  -> if eval c then eval t else eval e
```

_<p class="subtitle">Evaluationsfunktion mit GADTs</p>_

---

#### Syntactic Sugar

# 
#

<style scoped>  pre { font-size: 0.8rem; }
</style>


```ocaml
let rec eval : type a. a expr -> a = function
  | Bool b -> b
  | Int i  -> i
  | If (c, t, e)  -> if eval c then eval t else eval e   
```

_<p class="subtitle">Evaluationsfunktion mit GADTs</p>_

---

#### Existential Types

```ocaml
type stringable =                          
  Stringable : { 
    item: 'a; 
    to_string: 'a -> string 
  } -> stringable
```
```ocaml
let print (Stringable s) = 
  print_endline (s.to_string s.item)       
```

---

#### Vertiefendes Beispiel 
<style scoped>  pre { font-size: 0.75rem;  }
</style>

```ocaml
type (_, _) mode = 
  | Unsafe : ('a, 'a) mode
  | Option : ('a, 'a option) mode                  
```

```ocaml
let first : type a r. a list -> (a, r) mode -> r = 
  fun lst mde -> match lst with
    | hd :: tl -> (match mde with
      | Unsafe -> hd
      | Option -> Some hd)
    | [ ] -> (match mde with
      | Unsafe -> failwith "list is empty"
      | Option -> None)
```

---

#### Limitationen
#

- Typinferenz unentscheidbar
   $\rightarrow$ Typannotationen notwendig

- `|`-Patterns nicht auflösbar
   $\rightarrow$ Manuell auflösen und Logik auslagern

- `[@@-deriving ..]`-Annotation nicht möglich
   $\rightarrow$ Non-GADT Version benötigt

---
#### Zusammengefasst
#


- GADTs erlauben Konstrukturen verschiedene Typparameter einzusetzen
- Stärkere Aussagen auf Typebene möglich
- Patternmatching nutzt die zusätzlichen Informationen
- GATDs erlauben existenziell quantifizierte Typen zu formen
- Typinferenz wird unentscheidbar

---
#### Folien & Code
[github.com/Mari-W/ocaml-gadts](https://github.com/Mari-W/ocaml-gadts)


#### Literatur
- [Real World OCaml: GADTs](https://dev.realworldocaml.org/gadts.html) <br> Yaron Minsky, Anil Madhavapeddy `2021`
- [Detecting use-cases for GADTs in OCaml](https://blog.mads-hartmann.com/ocaml/2015/01/05/gadt-ocaml.html) Mads Hartmann   `2015`
- [Stanford CS242: Programming Languages](https://stanford-cs242.github.io/assets/slides/04.2-polymorphism-existential.pdf)
Will Crichton `2019`
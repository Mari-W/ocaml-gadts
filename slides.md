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
        font-size: 0.55rem;
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
- ADTs <-> Variants
- Der Plan
  - Eigene Sprache `L-If`
  - Nachteile bei Interpreterimplementierung ohne GADTs
  - Vorteile mit 
  - 2 weitere coole Konzepte mit GADTs
- Introduction by Example & Intuition
- Fragen gerne zwischen rein stellen
-->

# Generalized Algebraic Data Types
### in OCaml

---

<!--
- CNF grammar
-->

#### Die Sprache `L-If`

#
#

$$
\begin{align*}
Atom &::= true \text{ } | \text{ } false \text{ } | \text{ } 0..9^+ \\
Expr &::= Atom \text{ } | \textbf{ if } Expr \textbf{ then } Expr \textbf{ else } Expr
\end{align*}
$$

---

<style scoped> 
  pre {  
    font-size: 0.8rem;
  }
  div.error > pre {
    font-size: 0.77rem;
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

- ! int als condition
- ! verschiedene typen in zweigen
- ! nested verschiedene typen in zweigen
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
if 0 then true else false
```
```ocaml
if true then 0 else false
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

#### In einer Welt ohne GADTs: `L-ADT-If`

# 

<style scoped> pre {  font-size: 1rem; }
</style>

```ocaml
type atom =
  | Bool of bool
  | Int  of int

type expr =
  | Atom of atom
  | If   of expr * expr * expr
```

_<p class="subtitle">Syntaxbaum für `L-ADT-If`</p>_

---

```ocaml
let rec eval : expr -> atom = function
  | Atom a -> a
  | If (c, i, e) -> begin match eval c with
      | Bool true  -> eval i
      | Bool false -> eval e
      | _ -> failwith "expected bool!"
    end
```

_<p class="subtitle">Evaluationsfunktion für `L-ADT-If`</p>_

---

#### Probleme von `L-ADT-If`

<style scoped> pre { font-size: 0.7rem; }
</style>
<div class="columns">
<div>

```ocaml
eval (If 
     (Atom (Bool true),
     (Atom (Int 42)),
     (Atom (Int 0))))
```

```ocaml
- : atom = Atom (Int 42)
```

</div><div>

```ocaml
eval (If 
     (Atom (Int 42),
     (Atom (Bool false)),
     (Atom (Int 0))))           
```
```ocaml
Exception: Failure "need bool!"
```

</div>
</div>

_<p class="subtitle">Beispiele in `L-ADT-If`</p>_

- Ungültige Programmdefinition möglich
- Laufzeitfehler im Interpreter   
- Zweige können verschiedene Typen haben

---

#### In einer Welt mit GADTs: `L-GADT-If`

#

<style scoped> pre { font-size: 0.9rem; }
</style>

```ocaml
type _ atom =
  | Bool : bool -> bool atom
  | Int  : int  -> int  atom

type _ expr =
  | Atom : 'a atom -> 'a expr
  | If   : bool expr * 'a expr * 'a expr -> 'a expr
```

_<p class="subtitle">Syntaxbaum für `L-GADT-If`</p>_

# 

---

#### ADTs vs GADTs

#

<style scoped> pre { font-size: 0.7rem; } 
</style>
<div class="columns">
<div>

```ocaml
type atom =
  | Bool : bool -> atom
  | Int  : int  -> atom
```
_<p class="subtitle">`L-ADT-If` atom</p>_
</div>
<div>

```ocaml
type _ atom =
  | Bool : bool -> bool atom
  | Int  : int  -> int  atom
```
_<p class="subtitle">`L-GADT-If` atom</p>_
</div>
</div>


#

Konstrukturen eines GADTs können _verschiedene_ Typen annehmen, während bei ADTs alle Konstruktoren den _selben_ Typ haben.

--- 

<style scoped>  pre { font-size: 0.85rem; }
</style>

```ocaml
let rec eval : .. = function
  | Atom (Bool b) -> b
  | Atom (Int i)  -> i
  | If (c, i, e)  -> if eval c then eval i else eval e
```

_<p class="subtitle">Evaluationsfunktion für `L-GADT-If`</p>_

---

#### Die Vorteile von `L-GADT-If`

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
<div>

```ocaml
eval (If 
     (Atom (Bool true),
     (Atom (Int 42)),
     (Atom (Int 0))))
```

```ocaml
- : int = 42
```

</div>
<div class="error">

```ocaml
eval (If 
     (Atom (Int 42),
     (Atom (Bool false)),
     (Atom (Int 0))))
```

</div>
</div>

_<p class="subtitle">Beispiele in `L-GADT-If`</p>_

- Keine ungültigen Programmdefinitionen
- Keine Laufzeitfehler im Interpreter
- Exhaustive Patternmatching

---

#### Lokal Abstrakte Typen

#
#

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
  | Atom (Bool b) -> b
  | Atom (Int i)  -> i
  | If (c, i, e)  -> if eval c then eval i else eval e
```

_<p class="subtitle">Evaluationsfunktion mit Lokal Abstrakten Typen für `L-GADT-If`</p>_

---

#### Polymorphe Rekursion

<style scoped>  pre { font-size: 0.75rem; }
</style>

```ocaml
let rec eval : 'a. 'a expr -> 'a = 
    fun (type a) (e : a expr) : a -> match e with
      | Atom (Bool b) -> b
      | Atom (Int i)  -> i
      | If (c, i, e)  -> if eval c then eval i else eval e
```

_<p class="subtitle">Evaluationsfunktion mit L.A.T. und polymorpher Rekursion für `L-GADT-If`</p>_

---

<style scoped>  pre { font-size: 0.85rem; }
</style>


```ocaml
let rec eval : type a. a expr -> a = function
  | Atom (Bool b) -> b
  | Atom (Int i)  -> i
  | If (c, i, e)  -> if eval c then eval i else eval e   
```

_<p class="subtitle">Evaluationsfunktion für `L-GADT-If`</p>_

---

#### Unterschiedliche Rückgabewerte

<style scoped>  pre { font-size: 0.75rem;  }
</style>

```ocaml
type (_, _) mode = 
  | Unsafe : ('a, 'a) mode
  | Option : ('a, 'a option) mode                  
```

```ocaml
let first : type a r. a list -> (a, r) mode -> r = 
  fun lst mode -> match lst with
    | hd :: tl -> (match mode with
      | Unsafe -> hd
      | Option -> Some hd)
    | [ ] -> (match mode with
      | Unsafe -> failwith "list is empty"
      | Option -> None)
```
_<p class="subtitle">Funktion mit unterschiedlichen Rückgabewerten</p>_

---

#### Existenzielle Typen

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
_<p class="subtitle">Existenzieller Typ</p>_

---
#### In einer Nussschale

<style scoped>  li { font-size: 0.75rem; letter-spacing: 0.00000001rem; }
</style>

- GADTs sind eine Erweiterung von ADTs, die es erlaubt, dass Variants verschiedene Typen, basierend auf jeweils eigenen Typvariablen, annehmen können
- Beim Patternmatching extrahiert der Compiler über GADTs mehr Informationen und kann somit mehr Fälle eliminieren
- Mit GADTs lassen sich einige interessante Konzepte realisieren, wie Existenzielle Typen, Funktionen mit verschiedenen Rückgabewerten und im generellen ausdrucksstärkere Typdefinitionen
- Allerdings wird mit GADTs die Typinferenz unentscheidbar, weshalb Typannotationen benötigt werden, zudem benötigt es neue Konzepte um rekursive Funktionen zu realisieren

---
#### Folien

[https://mari-w.github.io/ocaml-gadts/](https://mari-w.github.io/ocaml-gadts/)

#### Literatur
- [Real World OCaml: GADTs](https://dev.realworldocaml.org/gadts.html) <br> Yaron Minsky, Anil Madhavapeddy `2021`
- [Detecting use-cases for GADTs in OCaml](https://blog.mads-hartmann.com/ocaml/2015/01/05/gadt-ocaml.html) Mads Hartmann   `2015`
- [Stanford CS242: Programming Languages](https://stanford-cs242.github.io/assets/slides/04.2-polymorphism-existential.pdf)
Will Crichton `2019`
(* signature for the exercise 1 *)
module type QUEUE_FUN =
sig
  type 'a t
  exception Empty of string
  val empty: unit -> 'a t
  val enqueue: 'a * 'a t -> 'a t
  val dequeue: 'a t -> 'a t
  val first: 'a t -> 'a
  val is_empty: 'a t -> bool
end;;

(* ex 1 *)
(* define a module which supports basic operations on a queue represented by a regular list *)
module QueueA : QUEUE_FUN =
struct
  type 'a t = 'a list
  exception Empty of string

  let empty () = []

  let enqueue (e, q) = e :: q

  let rec dequeue = function
    [] -> []
    | e :: q -> if q <> [] then e :: dequeue q else []

  let rec first = function
    [] -> raise (Empty "module QueueA: first")
    | e :: q -> if q <> [] then first q else e

  let is_empty q = q = []
end;;

(* tests *)
let q = let open QueueA in enqueue (3, enqueue (2, enqueue (1, empty ())));;
QueueA.first q;;
let open QueueA in first (dequeue (dequeue q));;

(* define a module which supports basic operations on a queue represented by a pair or lists *)
module QueueB : QUEUE_FUN =
struct
  type 'a t = 'a list * 'a list
  exception Empty of string

  let empty () = ([], [])

  let enqueue = function
    (e, ([], _)) -> ([e], [])
    | (e, (xl, yl)) -> (xl, e :: yl)

  let dequeue = function
    ([], _) -> ([], [])
    | ([_], yl) -> (List.rev yl, [])
    | (_ :: tx, yl) -> (tx, yl)

  let first = function
    (h :: _, _) -> h
    | ([], _) -> raise (Empty "module QueueB: first")

  let is_empty (xl, _) = xl = []
end;;

(* tests *)
let q = let open QueueB in enqueue (3, enqueue (2, enqueue (1, empty ())));;
QueueB.first q;;
let open QueueB in first (dequeue (dequeue q));;

(* signature for the exercise 2 *)
module type QUEUE_MUT =
sig
  type 'a t
  exception Empty of string
  exception Full of string
  val empty: int -> 'a t
  val enqueue: 'a * 'a t -> unit
  val dequeue: 'a t -> unit
  val first: 'a t -> 'a
  val is_empty: 'a t -> bool
  val is_full: 'a t -> bool
end;;

(* ex 2 *)
(* define a module which supports basic operations on a queue represented by a cyclic array *)
module QueueC : QUEUE_MUT = 
struct
  type 'a t = {mutable f : int; mutable r : int; arr : 'a option array}
  exception Empty of string
  exception Full of string

  let empty n = {f = 0; r = 0; arr = Array.make (succ n) None}

  let is_empty q = q.f = q.r

  let is_full q = q.f = (succ q.r) mod (Array.length q.arr)

  let enqueue (e, q) =
    if is_full q then raise (Full "module QueueC: enqueue")
    else
      q.arr.(q.r) <- Some e;
      q.r <- (succ q.r) mod (Array.length q.arr)

  let dequeue q =
    if not (is_empty q) then
      q.arr.(q.f) <- None; 
      q.f <- (succ q.f) mod (Array.length q.arr)

  let first q = 
    if is_empty q then raise (Empty "module QueueC: first")
    else match q.arr.(q.f) with
      Some e -> e
      | None -> failwith "module QueueC: first (implementation error)"
end;;

(* tests *)
let q = QueueC.empty 3;;
QueueC.enqueue (1, q);;
QueueC.enqueue (2, q);;
QueueC.enqueue (3, q);;
QueueC.first q;;
QueueC.dequeue q;;
QueueC.dequeue q;;
QueueC.first q;;
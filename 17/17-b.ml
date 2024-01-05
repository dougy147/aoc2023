let filepath = "./assets/17.txt";;

let read_whole_file filename =
  let ch = open_in_bin filename in
  let s  = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s
  |> String.split_on_char '\n'
  |> List.filter ((<>) "")

let input_to_array list =
  let rec c acc list =
    match list with
    | [] -> acc
    | hd :: tl ->
        let array =
          hd
          |> String.to_seq
          |> List.of_seq
          |> List.map (fun c -> String.make 1 c)
          |> List.map int_of_string
          |> Array.of_list
        in
        c (array :: acc) tl
  in
  Array.of_list (List.rev (c [] list))

let city_blocks = input_to_array (read_whole_file filepath);;

let height = Array.length city_blocks;;
let width  = Array.length city_blocks.(0);;

let is_on_grid x y =
  if x < 0 || y < 0 || x >= height || y >= width then
    false
  else
    true

type direction = Init | Up | Down | Left | Right;;
type coordinates = { x: int; y: int } ;;
type crucible = { heat_loss: int; pos: coordinates; direction: direction; prev_direction: direction };;

let possible_moves (cruc: crucible) =
  match cruc.direction with
  | Init  -> [(0,+1,Right);(+1,0,Down)]
  | Left  -> [(-1,0,Up);(+1,0,Down)]
  | Right -> [(-1,0,Up);(+1,0,Down)]
  | Up    -> [(0,-1,Left);(0,+1,Right)]
  | Down  -> [(0,-1,Left);(0,+1,Right)];;

let source_cell = { heat_loss=0; pos = {x=0;y=0}; direction=Init; prev_direction=Init };;
let destination = {x=height-1; y=width-1};;

let visited = Hashtbl.create (141*141*4);;

module PQSet = Set.Make
  (* https://rosettacode.org/wiki/Priority_queue#OCaml *)
  (struct
     type t = crucible
     let compare = compare
   end);;

let () =
 let pq = PQSet.of_list [source_cell] in
 let rec aux pq' =
  if not (PQSet.is_empty pq') then begin
    let cruc = PQSet.min_elt pq' in
    if cruc.pos = destination then
      Printf.printf "Minimum heat loss: %d\n" cruc.heat_loss
    else
      let value = Hashtbl.find_opt visited ({x=cruc.pos.x;y=cruc.pos.y},cruc.direction) in
      match value with
      | None ->
        Hashtbl.add visited (cruc.pos,cruc.direction) cruc.heat_loss;
        let pq_copy = ref (PQSet.remove cruc pq') in
        let pmoves = possible_moves cruc in
        for i = 0 to List.length pmoves - 1 do
          let heat = ref cruc.heat_loss in
          let mx, my, dir = List.nth pmoves i in
          for step = 1 to 10 do
            let x = cruc.pos.x + (mx * step) in
            let y = cruc.pos.y + (my * step) in
            if x >= 0 && y >= 0 && is_on_grid x y then begin
              heat := !heat + city_blocks.(x).(y);
              if step < 4 then
                ()
              else
                let pstate = if step > 1 || cruc.direction = Init then
                  dir
                else
                  cruc.prev_direction
                in
                let new_cruc = { heat_loss=(!heat); pos={x=x;y=y}; direction=dir; prev_direction=pstate } in
                pq_copy := PQSet.add new_cruc (!pq_copy)
            end
          done;
        done;
        aux !pq_copy
    | _ ->
        aux (PQSet.remove cruc pq')
  end
 in aux pq;;

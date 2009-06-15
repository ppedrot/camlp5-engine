(* camlp5r *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007 *)

open Gramext;;

let trace =
  ref (try let _ = Sys.getenv "GRAMTEST" in true with Not_found -> false)
;;

(* LR(0) test (experiment) *)

let not_impl name x =
  let desc =
    if Obj.tag (Obj.repr x) = Obj.tag (Obj.repr "") then
      Printf.sprintf "\"%s\"" (Obj.magic x)
    else if Obj.is_block (Obj.repr x) then
      "tag = " ^ string_of_int (Obj.tag (Obj.repr x))
    else "int_val = " ^ string_of_int (Obj.magic x)
  in
  Printf.sprintf "\"gramalgo, not impl: %s; %s\"" name (String.escaped desc)
;;

module Fifo =
  struct
    type 'a t = { mutable bef : 'a list; mutable aft : 'a list };;
    let add x f = {bef = x :: f.bef; aft = f.aft};;
    let get f =
      if f.aft = [] then begin f.aft <- List.rev f.bef; f.bef <- [] end;
      match f.aft with
        x :: aft -> Some (x, {bef = f.bef; aft = aft})
      | [] -> None
    ;;
    let empty () = {bef = []; aft = []};;
    let single x = {bef = []; aft = [x]};;
    let to_list f = List.rev_append f.bef f.aft;;
  end
;;

type gram_symb =
    GS_term of string
  | GS_nterm of string
;;

let name_of_entry entry lev = entry.ename ^ "-" ^ string_of_int lev;;

let fold_rules_of_tree f init tree =
  let rec do_tree r accu =
    function
      Node n ->
        let accu = do_tree (n.node :: r) accu n.son in
        do_tree r accu n.brother
    | LocAct (_, _) -> f (List.rev r) accu
    | DeadEnd -> accu
  in
  do_tree [] init tree
;;

let fold_rules_of_level f lev init =
  let accu =
    fold_rules_of_tree f init
      (Node {node = Sself; son = lev.lsuffix; brother = DeadEnd})
  in
  fold_rules_of_tree f accu lev.lprefix
;;

let gram_symb_list cnt to_treat self_middle self_end =
  let rec loop anon_rules =
    function
      [Sself] -> [self_end ()], anon_rules
    | s :: sl ->
        let s =
          match s with
            Sfacto s -> s
          | Svala (ls, s) -> s
          | s -> s
        in
        let (gs, anon_rules) =
          match s with
            Snterm e ->
              to_treat := (e, 0) :: !to_treat;
              GS_nterm (name_of_entry e 0), anon_rules
          | Snterml (e, lev_name) ->
              let levn =
                match e.edesc with
                  Dlevels levs ->
                    let rec loop n =
                      function
                        lev :: levs ->
                          begin match lev.lname with
                            Some s ->
                              if s = lev_name then n else loop (n + 1) levs
                          | None -> loop (n + 1) levs
                          end
                      | [] -> n
                    in
                    loop 0 levs
                | Dparser _ -> 1
              in
              to_treat := (e, levn) :: !to_treat;
              GS_nterm (name_of_entry e levn), anon_rules
          | Slist0 _ ->
              incr cnt;
              let n = "x-list0-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Slist0sep (_, _) ->
              incr cnt;
              let n = "x-list0sep-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Slist1 _ ->
              incr cnt;
              let n = "x-list1-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Slist1sep (_, _) ->
              incr cnt;
              let n = "x-list1sep-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Sopt _ ->
              incr cnt;
              let n = "x-opt-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Sflag _ ->
              incr cnt;
              let n = "x-flag-" ^ string_of_int !cnt in
              let anon_rules = (n, s) :: anon_rules in GS_nterm n, anon_rules
          | Stoken p ->
              let n =
                match p with
                  "", prm -> "\"" ^ prm ^ "\""
                | con, "" -> con
                | con, prm -> "(" ^ con ^ " \"" ^ prm ^ "\")"
              in
              GS_term n, anon_rules
          | Sself -> self_middle (), anon_rules
          | Stree t ->
              incr cnt;
              let n = "x-rules-" ^ string_of_int !cnt in
              let anon_rules = (n, Stree t) :: anon_rules in
              GS_nterm n, anon_rules
          | Svala (ls, s) ->
              incr cnt;
              let n = "x-v-" ^ string_of_int !cnt in GS_nterm n, anon_rules
          | s -> GS_term (not_impl "gram_symb" s), anon_rules
        in
        let (gsl, anon_rules) = loop anon_rules sl in gs :: gsl, anon_rules
    | [] -> [], anon_rules
  in
  loop []
;;

let new_anon_rules cnt mar ename sy =
  let self () = GS_nterm ename in
  match sy with
    Slist0 s ->
      let (sl1, ar) = gram_symb_list cnt (ref []) self self [s; Sself] in
      let sl2 = [] in [ename, sl1; ename, sl2], ar @ mar
  | Slist0sep (s, sy) ->
      let ename2 = ename ^ "-0" in
      let sl1 = [GS_nterm ename2] in
      let sl2 = [] in
      let self () = GS_nterm ename2 in
      let (sl3, ar3) = gram_symb_list cnt (ref []) self self [s; sy; Sself] in
      let (sl4, ar4) = gram_symb_list cnt (ref []) self self [s] in
      [ename, sl1; ename, sl2; ename2, sl3; ename2, sl4], ar3 @ ar4 @ mar
  | Slist1 s ->
      let (sl1, ar1) = gram_symb_list cnt (ref []) self self [s; Sself] in
      let (sl2, ar2) = gram_symb_list cnt (ref []) self self [s] in
      [ename, sl1; ename, sl2], ar1 @ ar2 @ mar
  | Slist1sep (s, sy) ->
      let (sl1, ar1) = gram_symb_list cnt (ref []) self self [s; sy; Sself] in
      let (sl2, ar2) = gram_symb_list cnt (ref []) self self [s] in
      [ename, sl1; ename, sl2], ar1 @ ar2 @ mar
  | Sopt sy ->
      let (sl, ar) = gram_symb_list cnt (ref []) self self [sy] in
      [ename, sl; ename, []], ar @ mar
  | Sflag sy ->
      let (sl, ar) = gram_symb_list cnt (ref []) self self [sy] in
      [ename, sl; ename, []], ar @ mar
  | Stree t ->
      let f r accu =
        let (sl, ar) = gram_symb_list cnt (ref []) self self r in
        (ename, sl) :: accu
      in
      fold_rules_of_tree f [] t, mar
  | _ -> [], mar
;;

let flatten_gram entry levn =
  let cnt = ref 0 in
  let treat_level rules to_treat entry levn elev =
    let lev =
      try List.nth elev levn with
        Failure _ ->
          {assoc = NonA; lname = None; lsuffix = DeadEnd; lprefix = DeadEnd}
    in
    let to_treat_r = ref to_treat in
    let anon_rules_r = ref [] in
    let self_middle () =
      to_treat_r := (entry, 0) :: !to_treat_r;
      GS_nterm (name_of_entry entry 0)
    in
    let self_end () =
      let n =
        match lev.assoc with
          NonA | LeftA -> levn + 1
        | RightA -> levn
      in
      if n <> levn then to_treat_r := (entry, n) :: !to_treat_r;
      GS_nterm (name_of_entry entry n)
    in
    let name = name_of_entry entry levn in
    let f r accu =
      let (sl, anon_rules) =
        match r with
          Sself :: r ->
            let s =
              let n =
                match lev.assoc with
                  NonA | RightA ->
                    to_treat_r := (entry, levn + 1) :: !to_treat_r; levn + 1
                | LeftA -> levn
              in
              GS_nterm (name_of_entry entry n)
            in
            let (sl, anon_rules) =
              gram_symb_list cnt to_treat_r self_middle self_end r
            in
            s :: sl, anon_rules
        | r -> gram_symb_list cnt to_treat_r self_middle self_end r
      in
      anon_rules_r := anon_rules @ !anon_rules_r; Fifo.add (name, sl) accu
    in
    let rules = fold_rules_of_level f lev rules in
    let rules =
      match try Some (List.nth elev (levn + 1)) with Failure _ -> None with
        Some _ ->
          let r =
            name_of_entry entry levn,
            [GS_nterm (name_of_entry entry (levn + 1))]
          in
          to_treat_r := (entry, levn + 1) :: !to_treat_r; Fifo.add r rules
      | None -> rules
    in
    rules, !to_treat_r, !anon_rules_r
  in
  let treat_entry rules to_treat entry levn =
    match entry.edesc with
      Dlevels [] -> rules, to_treat, []
    | Dlevels elev -> treat_level rules to_treat entry levn elev
    | Dparser p -> rules, to_treat, []
  in
  let rec loop rules treated =
    function
      (entry, levn) :: to_treat ->
        if List.mem (entry.ename, levn) treated then
          loop rules treated to_treat
        else
          let treated = (entry.ename, levn) :: treated in
          let (rules, to_treat, anon_rules) =
            treat_entry rules to_treat entry levn
          in
          let rules =
            let rec loop rules =
              function
                [] -> rules
              | anon_rules ->
                  let (rules, more_anon_rules) =
                    List.fold_left
                      (fun (rules, more_anon_rules) (ename, sy) ->
                         let (new_rules, more_anon_rules) =
                           new_anon_rules cnt more_anon_rules ename sy
                         in
                         let rules =
                           List.fold_left (fun f r -> Fifo.add r f) rules
                             new_rules
                         in
                         rules, more_anon_rules)
                      (rules, []) (List.rev anon_rules)
                  in
                  loop rules more_anon_rules
            in
            loop rules anon_rules
          in
          loop rules treated to_treat
    | [] -> Fifo.to_list rules
  in
  loop (Fifo.empty ()) [] [entry, levn]
;;

let sprint_symb =
  function
    GS_term s -> s
  | GS_nterm s -> s
;;

let eprint_rule (n, sl) =
  Printf.eprintf "%s ->" n;
  if sl = [] then Printf.eprintf " ε"
  else List.iter (fun s -> Printf.eprintf " %s" (sprint_symb s)) sl;
  Printf.eprintf "\n"
;;

let check_closed rl =
  let ht = Hashtbl.create 1 in
  List.iter (fun (e, rh) -> Hashtbl.replace ht e e) rl;
  List.iter
    (fun (e, rh) ->
       List.iter
         (function
            GS_term _ -> ()
          | GS_nterm s ->
              if Hashtbl.mem ht s then ()
              else Printf.eprintf "Missing non-terminal \"%s\"\n" s)
         rh)
    rl;
  flush stderr
;;

let lr0 entry lev =
  Printf.eprintf "LR(0) %s %d\n" entry.ename lev;
  flush stderr;
  let rl = flatten_gram entry lev in
  Printf.eprintf "%d rules\n\n" (List.length rl);
  flush stderr;
  check_closed rl;
  List.iter eprint_rule rl;
  Printf.eprintf "\n";
  flush stderr
;;

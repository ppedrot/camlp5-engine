(* camlp5r pa_macro.cmo *)
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

type action =
    ActShift of int
  | ActReduce of int
  | ActAcc
  | ActErr
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

let make_anon_rules anon_rules pref cnt s =
  let rec loop =
    function
      (n, s1) :: rest -> if Gramext.eq_symbol s s1 then n else loop rest
    | [] ->
        incr cnt;
        let n = "x-" ^ pref ^ "-" ^ string_of_int !cnt in
        anon_rules := (n, s) :: !anon_rules; n
  in
  loop !anon_rules
;;

let gram_symb_list cnt to_treat anon_rules self_middle self_end =
  let rec loop =
    function
      [Sself] -> [self_end ()]
    | s :: sl ->
        let s =
          match s with
            Sfacto s -> s
          | Svala (ls, s) -> s
          | s -> s
        in
        let gs =
          match s with
            Snterm e ->
              to_treat := (e, 0) :: !to_treat; GS_nterm (name_of_entry e 0)
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
              GS_nterm (name_of_entry e levn)
          | Slist0 _ ->
              let n = make_anon_rules anon_rules "list0" cnt s in GS_nterm n
          | Slist0sep (_, _) ->
              let n = make_anon_rules anon_rules "list0sep" cnt s in
              GS_nterm n
          | Slist1 _ ->
              let n = make_anon_rules anon_rules "list1" cnt s in GS_nterm n
          | Slist1sep (_, _) ->
              let n = make_anon_rules anon_rules "list1sep" cnt s in
              GS_nterm n
          | Sopt _ ->
              let n = make_anon_rules anon_rules "opt" cnt s in GS_nterm n
          | Sflag _ ->
              let n = make_anon_rules anon_rules "flag" cnt s in GS_nterm n
          | Stoken p ->
              let n =
                match p with
                  "", prm -> "\"" ^ prm ^ "\""
                | con, "" -> con
                | con, prm -> "(" ^ con ^ " \"" ^ prm ^ "\")"
              in
              GS_term n
          | Sself -> self_middle ()
          | Stree _ ->
              incr cnt;
              let n = "x-rules-" ^ string_of_int !cnt in
              anon_rules := (n, s) :: !anon_rules; GS_nterm n
          | Svala (ls, s) ->
              incr cnt; let n = "x-v-" ^ string_of_int !cnt in GS_nterm n
          | s -> GS_term (not_impl "gram_symb" s)
        in
        gs :: loop sl
    | [] -> []
  in
  loop
;;

let new_anon_rules cnt to_treat mar ename sy =
  let self () = GS_nterm ename in
  match sy with
    Slist0 s ->
      let sl1 = gram_symb_list cnt to_treat mar self self [s; Sself] in
      let sl2 = [] in [ename, sl1; ename, sl2]
  | Slist0sep (s, sy) ->
      let ename2 = ename ^ "-0" in
      let sl1 = [GS_nterm ename2] in
      let sl2 = [] in
      let self () = GS_nterm ename2 in
      let sl3 = gram_symb_list cnt to_treat mar self self [s; sy; Sself] in
      let sl4 = gram_symb_list cnt to_treat mar self self [s] in
      [ename, sl1; ename, sl2; ename2, sl3; ename2, sl4]
  | Slist1 s ->
      let sl1 = gram_symb_list cnt to_treat mar self self [s; Sself] in
      let sl2 = gram_symb_list cnt to_treat mar self self [s] in
      [ename, sl1; ename, sl2]
  | Slist1sep (s, sy) ->
      let sl1 = gram_symb_list cnt to_treat mar self self [s; sy; Sself] in
      let sl2 = gram_symb_list cnt to_treat mar self self [s] in
      [ename, sl1; ename, sl2]
  | Sopt sy ->
      let sl = gram_symb_list cnt to_treat mar self self [sy] in
      [ename, sl; ename, []]
  | Sflag sy ->
      let sl = gram_symb_list cnt to_treat mar self self [sy] in
      [ename, sl; ename, []]
  | Stree t ->
      let f r rl =
        let sl = gram_symb_list cnt to_treat mar self self r in
        (ename, sl) :: rl
      in
      fold_rules_of_tree f [] t
  | _ -> []
;;

let flatten_gram entry levn =
  let cnt = ref 0 in
  let anon_rules_r = ref [] in
  let treat_level2 rules to_treat entry levn elev lev =
    let to_treat_r = ref to_treat in
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
      let sl =
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
            let sl =
              gram_symb_list cnt to_treat_r anon_rules_r self_middle self_end
                r
            in
            s :: sl
        | r ->
            gram_symb_list cnt to_treat_r anon_rules_r self_middle self_end r
      in
      Fifo.add (name, sl) accu
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
    rules, !to_treat_r
  in
  let treat_level rules to_treat entry levn elev =
    match try Some (List.nth elev levn) with Failure _ -> None with
      Some lev -> treat_level2 rules to_treat entry levn elev lev
    | None ->
        let rules =
          if levn > 0 then
            (* in initial grammar (grammar.ml), the level after the
               last level is not an error but the last level itself *)
            let ename = name_of_entry entry levn in
            let r = ename, [GS_nterm (name_of_entry entry (levn - 1))] in
            Fifo.add r rules
          else rules
        in
        rules, to_treat
  in
  let treat_entry rules to_treat entry levn =
    match entry.edesc with
      Dlevels [] -> rules, to_treat
    | Dlevels elev -> treat_level rules to_treat entry levn elev
    | Dparser p -> rules, to_treat
  in
  let rec loop rules treated =
    function
      (entry, levn) :: to_treat ->
        if List.mem (entry.ename, levn) treated then
          loop rules treated to_treat
        else
          let treated = (entry.ename, levn) :: treated in
          anon_rules_r := [];
          let (rules, to_treat) = treat_entry rules to_treat entry levn in
          let to_treat_r = ref to_treat in
          let rules =
            let rec loop rules =
              function
                [] -> rules
              | anon_rules ->
                  let more_anon_rules = ref [] in
                  let rules =
                    List.fold_left
                      (fun rules (ename, sy) ->
                         let new_rules =
                           new_anon_rules cnt to_treat_r more_anon_rules ename
                             sy
                         in
                         List.fold_left (fun f r -> Fifo.add r f) rules
                           new_rules)
                      rules (List.rev anon_rules)
                  in
                  loop rules !more_anon_rules
            in
            loop rules !anon_rules_r
          in
          loop rules treated !to_treat_r
    | [] -> Fifo.to_list rules
  in
  loop (Fifo.empty ()) [] [entry, levn]
;;

let sprint_symb =
  function
    GS_term s -> s
  | GS_nterm s -> s
;;

let eprint_rule (i, n, sl) =
  Printf.eprintf "%d : %s ->" i n;
  if sl = [] then Printf.eprintf " ε"
  else List.iter (fun s -> Printf.eprintf " %s" (sprint_symb s)) sl;
  Printf.eprintf "\n"
;;

let check_closed rl =
  let ht = Hashtbl.create 1 in
  List.iter (fun (_, e, rh) -> Hashtbl.replace ht e e) rl;
  List.iter
    (fun (i, e, rh) ->
       List.iter
         (function
            GS_term _ -> ()
          | GS_nterm s ->
              if Hashtbl.mem ht s then ()
              else
                Printf.eprintf "Rule %d: missing non-terminal \"%s\"\n" i s)
         rh)
    rl;
  flush stderr
;;

let get_symbol_after_dot =
  let rec loop dot rh =
    match dot, rh with
      0, s :: _ -> Some s
    | _, [] -> None
    | n, _ :: sl -> loop (n - 1) sl
  in
  loop
;;

let close_item_set rl items =
  let processed = ref [] in
  let rclos =
    List.fold_left
      (fun clos (m, added, lh, dot, rh as item) ->
         match get_symbol_after_dot dot rh with
           Some (GS_nterm n) ->
             processed := lh :: !processed;
             let rec loop clos to_process =
               match Fifo.get to_process with
                 Some (n, to_process) ->
                   if List.mem n !processed then loop clos to_process
                   else
                     begin
                       processed := n :: !processed;
                       let rl = List.filter (fun (_, lh, rh) -> n = lh) rl in
                       let clos =
                         List.fold_left
                           (fun clos (m, lh, rh) ->
                              (m, true, lh, 0, rh) :: clos)
                           clos rl
                       in
                       let to_process =
                         List.fold_left
                           (fun to_process (_, lh, rh) ->
                              match rh with
                                [] -> to_process
                              | s :: sl ->
                                  match s with
                                    GS_nterm n -> Fifo.add n to_process
                                  | GS_term _ -> to_process)
                           to_process rl
                       in
                       loop clos to_process
                     end
               | None -> clos
             in
             loop (item :: clos) (Fifo.single n)
         | Some (GS_term _) | None -> item :: clos)
      [] items
  in
  List.rev rclos
;;

let eprint_item (m, added, lh, dot, rh) =
  if added then Printf.eprintf "+ " else Printf.eprintf "  ";
  Printf.eprintf "%s ->" lh;
  begin let rec loop dot rh =
    if dot = 0 then
      begin
        Printf.eprintf " •";
        List.iter (fun s -> Printf.eprintf " %s" (sprint_symb s)) rh
      end
    else
      match rh with
        s :: rh -> Printf.eprintf " %s" (sprint_symb s); loop (dot - 1) rh
      | [] -> Printf.eprintf "... algorithm error ..."
  in
    loop dot rh
  end;
  Printf.eprintf "\n"
;;

let make_item_sets rl item_set_ht =
  let rec loop ini_item_set_cnt item_set_cnt shift_assoc item_set_ini =
    let item_set =
      List.map (fun (m, _, lh, dot, rh) -> m, false, lh, dot, rh) item_set_ini
    in
    let sl =
      let (rtl, rntl) =
        (* terminals and non-terminals just after the dot *)
        List.fold_left
          (fun (rtl, rntl) (m, added, lh, dot, rh) ->
             match get_symbol_after_dot dot rh with
               Some s ->
                 begin match s with
                   GS_term _ ->
                     (if List.mem s rtl then rtl else s :: rtl), rntl
                 | GS_nterm _ ->
                     rtl, (if List.mem s rntl then rntl else s :: rntl)
                 end
             | None -> rtl, rntl)
          ([], []) item_set
      in
      List.rev_append rtl (List.rev rntl)
    in
    if sl <> [] then
      begin
        Printf.eprintf "\nfrom item_set %d, symbols after dot:"
          ini_item_set_cnt;
        List.iter (fun s -> Printf.eprintf " %s" (sprint_symb s)) sl;
        Printf.eprintf "\n";
        flush stderr
      end;
    let (item_set_cnt, symb_cnt_assoc, shift_assoc) =
      List.fold_left
        (fun (item_set_cnt, symb_cnt_assoc, shift_assoc) s ->
           let item_set =
             List.find_all
               (fun (m, added, lh, dot, rh) ->
                  match get_symbol_after_dot dot rh with
                    Some s1 -> s = s1
                  | None -> false)
               item_set
           in
           (* move the dot after s *)
           let item_set =
             List.map
               (fun (m, added, lh, dot, rh) -> m, added, lh, dot + 1, rh)
               item_set
           in
           (* complete by closure *)
           let item_set = close_item_set rl item_set in
           Printf.eprintf "\n";
           match
             try Some (Hashtbl.find item_set_ht item_set) with
               Not_found -> None
           with
             Some n ->
               Printf.eprintf "Item set (after %d and %s) = Item set %d\n"
                 ini_item_set_cnt (sprint_symb s) n;
               flush stderr;
               let symb_cnt_assoc = (s, n) :: symb_cnt_assoc in
               item_set_cnt, symb_cnt_assoc, shift_assoc
           | None ->
               Printf.eprintf "Item set %d (after %d and %s)\n\n"
                 (item_set_cnt + 1) ini_item_set_cnt (sprint_symb s);
               List.iter eprint_item item_set;
               flush stderr;
               let item_set_cnt = item_set_cnt + 1 in
               Hashtbl.add item_set_ht item_set item_set_cnt;
               let symb_cnt_assoc = (s, item_set_cnt) :: symb_cnt_assoc in
               let (item_set_cnt, shift_assoc) =
                 loop item_set_cnt item_set_cnt shift_assoc item_set
               in
               item_set_cnt, symb_cnt_assoc, shift_assoc)
        (item_set_cnt, [], shift_assoc) sl
    in
    let shift_assoc = (ini_item_set_cnt, symb_cnt_assoc) :: shift_assoc in
    item_set_cnt, shift_assoc
  in
  loop 0 0 []
;;

let compute_nb_symbols item_set_ht term_table nterm_table =
  Hashtbl.fold
    (fun item_set _ cnts ->
       List.fold_left
         (fun (terms_cnt, nterms_cnt) (_, _, lh, _, rh) ->
            let nterms_cnt =
              if Hashtbl.mem nterm_table lh then nterms_cnt
              else
                begin
                  Hashtbl.add nterm_table lh nterms_cnt;
                  nterms_cnt + 1
                end
            in
            List.fold_left
              (fun (terms_cnt, nterms_cnt) ->
                 function
                   GS_term s ->
                     let terms_cnt =
                       if Hashtbl.mem term_table s then terms_cnt
                       else
                         begin
                           Hashtbl.add term_table s terms_cnt;
                           terms_cnt + 1
                         end
                     in
                     terms_cnt, nterms_cnt
                 | GS_nterm s ->
                     let nterms_cnt =
                       if Hashtbl.mem nterm_table s then nterms_cnt
                       else
                         begin
                           Hashtbl.add nterm_table s nterms_cnt;
                           nterms_cnt + 1
                         end
                     in
                     terms_cnt, nterms_cnt)
              (terms_cnt, nterms_cnt) rh)
         cnts item_set)
    item_set_ht (0, 0)
;;

(*DEFINE TEST;*)

let lr0 entry lev =
  Printf.eprintf "LR(0) %s %d\n" entry.ename lev;
  flush stderr;
  let (rl, item_set_0) =
    let rl = flatten_gram entry lev in
    let rl =
      let (rrl, _) =
        List.fold_left (fun (rrl, i) (lh, rh) -> (i, lh, rh) :: rrl, i + 1)
          ([], 1) rl
      in
      List.rev rrl
    in
    let item_set_0 =
      let item = 0, false, "S", 0, [GS_nterm (name_of_entry entry lev)] in
      close_item_set rl [item]
    in
    rl, item_set_0
  in
  Printf.eprintf "%d rules\n\n" (List.length rl);
  flush stderr;
  check_closed rl;
  List.iter eprint_rule rl;
  Printf.eprintf "\n";
  flush stderr;
  Printf.eprintf "\n";
  Printf.eprintf "Item set 0\n\n";
  List.iter eprint_item item_set_0;
  flush stderr;
  let item_set_ht = Hashtbl.create 1 in
  let (item_set_cnt, shift_assoc) =
    make_item_sets rl item_set_ht item_set_0
  in
  Printf.eprintf "\ntotal number of item sets %d\n" (item_set_cnt + 1);
  flush stderr;
  Printf.eprintf "\nshift:\n";
  List.iter
    (fun (i, symb_cnt_assoc) ->
       Printf.eprintf "state %d:" i;
       List.iter (fun (s, i) -> Printf.eprintf " %s->%d" (sprint_symb s) i)
         (List.rev symb_cnt_assoc);
       Printf.eprintf "\n")
    (List.sort compare shift_assoc);
  flush stderr;
  let term_table = Hashtbl.create 1 in
  let nterm_table = Hashtbl.create 1 in
  let (nb_terms, nb_nterms) =
    compute_nb_symbols item_set_ht term_table nterm_table
  in
  Printf.eprintf "nb of terms %d\n" nb_terms;
  Printf.eprintf "nb of non-terms %d\n" nb_nterms;
  flush stderr;
  (* make goto table *)
  let goto_table =
    Array.init (item_set_cnt + 1) (fun _ -> Array.create nb_nterms (-1))
  in
  List.iter
    (fun (item_set_cnt, symb_cnt_assoc) ->
       let line = goto_table.(item_set_cnt) in
       List.iter
         (fun (s, n) ->
            match s with
              GS_term s -> ()
            | GS_nterm s ->
                let i = Hashtbl.find nterm_table s in line.(i) <- n)
         symb_cnt_assoc)
    shift_assoc;
  Printf.eprintf "\n\ngoto table\n\n";
  for i = 0 to Array.length goto_table - 1 do
    Printf.eprintf "state %d :" i;
    let line = goto_table.(i) in
    for j = 0 to Array.length line - 1 do
      if line.(j) = -1 then Printf.eprintf " -"
      else Printf.eprintf " %d" line.(j)
    done;
    Printf.eprintf "\n"
  done;
  flush stderr;
  (* make action table *)
  (* size = number of terminals plus one for the 'end of input' *)
  let action_table =
    Array.init (item_set_cnt + 1)
      (fun _ -> Array.create (nb_terms + 1) ActErr)
  in
  (* the columns for the terminals are copied to the action table as shift
     actions *)
  List.iter
    (fun (item_set_cnt, symb_cnt_assoc) ->
       let line = action_table.(item_set_cnt) in
       List.iter
         (fun (s, n) ->
            match s with
              GS_term s ->
                let i = Hashtbl.find term_table s in line.(i) <- ActShift n
            | GS_nterm s -> ())
         symb_cnt_assoc)
    shift_assoc;
  (* an extra column for '$' (end of input) is added to the action table
     that contains acc for every item set that contains S → w • *)
  Hashtbl.iter
    (fun item_set n ->
       List.iter
         (fun (_, _, lh, dot, rh) ->
            if lh = "S" && dot = List.length rh then
              action_table.(n).(nb_terms) <- ActAcc)
         item_set)
    item_set_ht;
  (* if an item set i contains an item of the form A → w • and A → w is
     rule m with m > 0 then the row for state i in the action table is
     completely filled with the reduce action rm. *)
  Hashtbl.iter
    (fun item_set i ->
       List.iter
         (fun (m, _, _, dot, rh) ->
            if m > 0 then
              if dot = List.length rh then
                let line = action_table.(i) in
                match line.(0) with
                  ActReduce m1 ->
                    Printf.eprintf
                      "State %d: conflict reduce/reduce rules %d and %d\n" i
                      m1 m;
                    flush stderr
                | _ ->
                    for j = 0 to Array.length line - 1 do
                      match line.(j) with
                        ActShift n ->
                          Printf.eprintf "State %d: conflict shift/reduce" i;
                          Printf.eprintf " shift %d rule %d\n" n m;
                          flush stderr
                      | _ -> line.(j) <- ActReduce m
                    done)
         item_set)
    item_set_ht;
  Printf.eprintf "\n\naction table\n\n";
  for i = 0 to Array.length action_table - 1 do
    Printf.eprintf "state %d :" i;
    let line = action_table.(i) in
    for j = 0 to Array.length line - 1 do
      match line.(j) with
        ActShift n -> Printf.eprintf " %4s" (Printf.sprintf "s%d" n)
      | ActReduce n -> Printf.eprintf " %4s" (Printf.sprintf "r%d" n)
      | ActAcc -> Printf.eprintf "   acc"
      | ActErr -> Printf.eprintf "    -"
    done;
    Printf.eprintf "\n"
  done;
  flush stderr
;;

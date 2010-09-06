(* camlp5r pa_macro.cmo *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007-2010 *)

open Parsetree;;
open Longident;;
open Asttypes;;

type ('a, 'b) choice =
    Left of 'a
  | Right of 'b
;;

let sys_ocaml_version = "1.06";;

let ocaml_location (fname, lnum, bolp, bp, ep) =
  {Location.loc_start = bp; Location.loc_end = ep}
;;

let ocaml_type_declaration params cl tk pf tm loc variance =
  try
    let cl =
      List.map
        (fun (t1, t2, loc) ->
           match t1.ptyp_desc with
             Ptyp_var s -> s, t2, loc
           | _ -> raise Exit)
        cl
    in
    Some
      {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
       ptype_manifest = tm; ptype_loc = loc}
  with Exit -> None
;;

let ocaml_class_type = None;;

let ocaml_class_expr = None;;

let ocaml_pmty_typeof = None;;

let ocaml_ptype_abstract = Ptype_abstract;;

let ocaml_ptype_record ltl priv =
  let ltl = List.map (fun (n, m, t, _) -> n, m, t) ltl in Ptype_record ltl
;;

let ocaml_ptype_variant ctl priv =
  let ctl = List.map (fun (c, tl, _) -> c, tl) ctl in Ptype_variant ctl
;;

let ocaml_ptyp_arrow lab t1 t2 = Ptyp_arrow (t1, t2);;

let ocaml_ptyp_class li tl ll = Ptyp_class (li, tl);;

let ocaml_ptyp_poly = None;;

let ocaml_ptyp_variant catl clos sl_opt = None;;

let ocaml_const_int32 = None;;

let ocaml_const_int64 = None;;

let ocaml_const_nativeint = None;;

let ocaml_pexp_apply f lel = Pexp_apply (f, List.map snd lel);;

let ocaml_pexp_assertfalse fname loc =
  let ghexp d = {pexp_desc = d; pexp_loc = loc} in
  let triple =
    ghexp
      (Pexp_tuple
         [ghexp (Pexp_constant (Const_string fname));
          ghexp (Pexp_constant (Const_int loc.Location.loc_start));
          ghexp (Pexp_constant (Const_int loc.Location.loc_end))])
  in
  let excep = Ldot (Lident "Pervasives", "Assert_failure") in
  let bucket = ghexp (Pexp_construct (excep, Some triple, false)) in
  let raise_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives", "raise"))) in
  ocaml_pexp_apply raise_ ["", bucket]
;;

let ocaml_pexp_assert fname loc e =
  let ghexp d = {pexp_desc = d; pexp_loc = loc} in
  let ghpat d = {ppat_desc = d; ppat_loc = loc} in
  let triple =
    ghexp
      (Pexp_tuple
         [ghexp (Pexp_constant (Const_string fname));
          ghexp (Pexp_constant (Const_int loc.Location.loc_start));
          ghexp (Pexp_constant (Const_int loc.Location.loc_end))])
  in
  let excep = Ldot (Lident "Pervasives", "Assert_failure") in
  let bucket = ghexp (Pexp_construct (excep, Some triple, false)) in
  let raise_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives", "raise"))) in
  let raise_af = ghexp (ocaml_pexp_apply raise_ ["", bucket]) in
  let under = ghpat Ppat_any in
  let false_ = ghexp (Pexp_construct (Lident "false", None, false)) in
  let try_e = ghexp (Pexp_try (e, [under, false_])) in
  let not_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives", "not"))) in
  let not_try_e = ghexp (ocaml_pexp_apply not_ ["", try_e]) in
  Pexp_ifthenelse (not_try_e, raise_af, None)
;;

let ocaml_pexp_function lab eo pel = Pexp_function pel;;

let ocaml_pexp_lazy = None;;

let ocaml_pexp_letmodule = None;;

let ocaml_pexp_object = None;;

let ocaml_pexp_pack = None;;

let ocaml_pexp_poly = None;;

let ocaml_pexp_record lel =
  function
    Some _ -> invalid_arg "ocaml_pexp_record"
  | None -> Pexp_record lel
;;

let ocaml_pexp_variant = None;;

let ocaml_ppat_array = None;;

let ocaml_ppat_lazy = None;;

let ocaml_ppat_record lpl = Ppat_record lpl;;

let ocaml_ppat_type = None;;

let ocaml_ppat_variant = None;;

let ocaml_psig_class_type = None;;

let ocaml_psig_recmodule = None;;

let ocaml_pstr_class_type = None;;

let ocaml_pstr_exn_rebind = None;;

let ocaml_pstr_include = None;;

let ocaml_pstr_recmodule = None;;

let ocaml_class_infos = None;;

let ocaml_pmod_unpack = None;;

let ocaml_pcf_cstr = None;;

let ocaml_pcf_inher (id, cl, el, loc) pb = Pcf_inher (id, cl, el, pb, loc);;

let ocaml_pcf_init = None;;

let ocaml_pcf_meth (s, pf, ovf, e, loc) = Pcf_meth (s, pf, e, loc);;

let ocaml_pcf_val (s, mf, e, loc) = Pcf_val (s, Public, mf, Some e, loc);;

let ocaml_pcl_apply = None;;

let ocaml_pcl_constr = None;;

let ocaml_pcl_constraint = None;;

let ocaml_pcl_fun = None;;

let ocaml_pcl_let = None;;

let ocaml_pcl_structure = None;;

let ocaml_pctf_cstr = None;;

let ocaml_pctf_val (s, mf, t, loc) = Pctf_val (s, Public, mf, Some t, loc);;

let ocaml_pcty_constr = None;;

let ocaml_pcty_fun = None;;

let ocaml_pcty_signature = None;;

let ocaml_pdir_bool = None;;

let module_prefix_can_be_in_first_record_label_only = false;;

let split_or_patterns_with_bindings = true;;

let has_records_with_with = false;;

let arg_rest _ = None;;

let arg_set_string _ = None;;

let arg_set_int _ = None;;

let arg_set_float _ = None;;

let arg_symbol _ = None;;

let arg_tuple _ = None;;

let arg_bool _ = None;;

let char_escaped =
  function
    '\r' -> "\\r"
  | c -> Char.escaped c
;;

let hashtbl_mem ht a =
  try let _ = Hashtbl.find ht a in true with Not_found -> false
;;

let rec list_rev_append l1 l2 =
  match l1 with
    x :: l -> list_rev_append l (x :: l2)
  | [] -> l2
;;

let list_rev_map f =
  let rec loop r =
    function
      x :: l -> loop (f x :: r) l
    | [] -> r
  in
  loop []
;;

let list_sort f l = Sort.list (fun x y -> f x y <= 0) l;;

let pervasives_set_binary_mode_out _ _ = ();;

let scan_format fmt i kont =
  match fmt.[i+1] with
    'c' -> Obj.magic (fun (c : char) -> kont (String.make 1 c) (i + 2))
  | 'd' -> Obj.magic (fun (d : int) -> kont (string_of_int d) (i + 2))
  | 's' -> Obj.magic (fun (s : string) -> kont s (i + 2))
  | c ->
      failwith (Printf.sprintf "Pretty.sprintf \"%s\" '%%%c' not impl" fmt c)
;;
let printf_ksprintf kont fmt =
  let fmt : string = Obj.magic fmt in
  let len = String.length fmt in
  let rec doprn rev_sl i =
    if i >= len then
      let s = String.concat "" (List.rev rev_sl) in Obj.magic (kont s)
    else
      match fmt.[i] with
        '%' -> scan_format fmt i (fun s -> doprn (s :: rev_sl))
      | c -> doprn (String.make 1 c :: rev_sl) (i + 1)
  in
  doprn [] 0
;;

let string_contains s c =
  let rec loop i =
    if i = String.length s then false
    else if s.[i] = c then true
    else loop (i + 1)
  in
  loop 0
;;

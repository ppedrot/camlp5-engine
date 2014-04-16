(* camlp5r pa_macro.cmo *)
(* File generated by program: edit only if it does not compile. *)
(* Copyright (c) INRIA 2007-2012 *)

open Parsetree;;
open Longident;;
open Asttypes;;

type ('a, 'b) choice =
    Left of 'a
  | Right of 'b
;;

let sys_ocaml_version = Sys.ocaml_version;;

let ocaml_location (fname, lnum, bolp, lnuml, bolpl, bp, ep) =
  let loc_at n lnum bolp =
    {Lexing.pos_fname = if lnum = -1 then "" else fname;
     Lexing.pos_lnum = lnum; Lexing.pos_bol = bolp; Lexing.pos_cnum = n}
  in
  {Location.loc_start = loc_at bp lnum bolp;
   Location.loc_end = loc_at ep lnuml bolpl;
   Location.loc_ghost = bp = 0 && ep = 0}
;;

(* *)

let mkloc loc txt = txt;;
let mknoloc txt = txt;;

let ocaml_id_or_li_of_string_list loc sl =
  match List.rev sl with
    [s] -> Some s
  | _ -> None
;;

let list_map_check f l =
  let rec loop rev_l =
    function
      x :: l ->
        begin match f x with
          Some s -> loop (s :: rev_l) l
        | None -> None
        end
    | [] -> Some (List.rev rev_l)
  in
  loop [] l
;;

let ocaml_value_description vn t p = {pval_type = t; pval_prim = p};;

let ocaml_class_type_field loc ctfd = ctfd;;

let ocaml_class_field loc cfd = cfd;;

(* *)

let ocaml_type_declaration tn params cl tk pf tm loc variance =
  match list_map_check (fun s_opt -> s_opt) params with
    Some params ->
      Right
        {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
         ptype_private = pf; ptype_manifest = tm; ptype_loc = loc;
         ptype_variance = variance}
  | None -> Left "no '_' type param in this ocaml version"
;;

let ocaml_class_type = Some (fun d loc -> {pcty_desc = d; pcty_loc = loc});;

let ocaml_class_expr = Some (fun d loc -> {pcl_desc = d; pcl_loc = loc});;

let ocaml_class_structure p cil = p, cil;;

let ocaml_pmty_ident loc li = Pmty_ident (mkloc loc li);;

let ocaml_pmty_functor sloc s mt1 mt2 =
  Pmty_functor (mkloc sloc s, mt1, mt2)
;;

let ocaml_pmty_typeof = Some (fun me -> Pmty_typeof me);;

let ocaml_pmty_with mt lcl =
  let lcl = List.map (fun (s, c) -> mknoloc s, c) lcl in Pmty_with (mt, lcl)
;;

let ocaml_ptype_abstract = Ptype_abstract;;

let ocaml_ptype_record ltl priv = Ptype_record ltl;;

let ocaml_ptype_variant ctl priv =
  try
    let ctl =
      List.map
        (fun (c, tl, rto, loc) ->
           if rto <> None then raise Exit else c, tl, loc)
        ctl
    in
    Some (Ptype_variant ctl)
  with Exit -> None
;;

let ocaml_ptyp_arrow lab t1 t2 = Ptyp_arrow (lab, t1, t2);;

let ocaml_ptyp_class li tl ll = Ptyp_class (mknoloc li, tl, ll);;

let ocaml_ptyp_constr loc li tl = Ptyp_constr (mkloc loc li, tl);;

let ocaml_ptyp_object ml = Ptyp_object ml;;

let ocaml_ptyp_package = Some (fun pt -> Ptyp_package pt);;

let ocaml_ptyp_poly = Some (fun cl t -> Ptyp_poly (cl, t));;

let ocaml_ptyp_variant catl clos sl_opt =
  let catl =
    List.map
      (function
         Left (c, a, tl) -> Rtag (c, a, tl)
       | Right t -> Rinherit t)
      catl
  in
  Some (Ptyp_variant (catl, clos, sl_opt))
;;

let ocaml_package_type li ltl =
  mknoloc li, List.map (fun (li, t) -> mkloc t.ptyp_loc li, t) ltl
;;

let ocaml_const_string s = Const_string s;;

let ocaml_const_int32 = Some (fun s -> Const_int32 (Int32.of_string s));;

let ocaml_const_int64 = Some (fun s -> Const_int64 (Int64.of_string s));;

let ocaml_const_nativeint =
  Some (fun s -> Const_nativeint (Nativeint.of_string s))
;;

let ocaml_mktyp loc x = {ptyp_desc = x; ptyp_loc = loc};;
let ocaml_mkpat loc x = {ppat_desc = x; ppat_loc = loc};;
let ocaml_mkexp loc x = {pexp_desc = x; pexp_loc = loc};;
let ocaml_mkmty loc x = {pmty_desc = x; pmty_loc = loc};;
let ocaml_mkmod loc x = {pmod_desc = x; pmod_loc = loc};;
let ocaml_mkfield loc (lab, x) fl =
  {pfield_desc = Pfield (lab, x); pfield_loc = loc} :: fl
;;
let ocaml_mkfield_var loc = [{pfield_desc = Pfield_var; pfield_loc = loc}];;

let ocaml_pexp_apply f lel = Pexp_apply (f, lel);;

let ocaml_pexp_assertfalse fname loc = Pexp_assertfalse;;

let ocaml_pexp_assert fname loc e = Pexp_assert e;;

let ocaml_pexp_constraint e ot1 ot2 = Pexp_constraint (e, ot1, ot2);;

let ocaml_pexp_construct loc li po chk_arity =
  Pexp_construct (mkloc loc li, po, chk_arity)
;;

let ocaml_pexp_construct_args =
  function
    Pexp_construct (li, po, chk_arity) -> Some (li.txt, li.loc, po, chk_arity)
  | _ -> None
;;

let mkexp_ocaml_pexp_construct_arity loc li_loc li al =
  let a = ocaml_mkexp loc (Pexp_tuple al) in
  ocaml_mkexp loc (ocaml_pexp_construct li_loc li (Some a) true)
;;

let ocaml_pexp_field loc e li = Pexp_field (e, mkloc loc li);;

let ocaml_pexp_for i e1 e2 df e = Pexp_for (mknoloc i, e1, e2, df, e);;

let ocaml_case (p, wo, loc, e) =
  match wo with
    Some w -> p, ocaml_mkexp loc (Pexp_when (w, e))
  | None -> p, e
;;

let ocaml_pexp_function lab eo pel = Pexp_function (lab, eo, pel);;

let ocaml_pexp_lazy = Some (fun e -> Pexp_lazy e);;

let ocaml_pexp_ident li = Pexp_ident (mknoloc li);;

let ocaml_pexp_letmodule =
  Some (fun i me e -> Pexp_letmodule (mknoloc i, me, e))
;;

let ocaml_pexp_new loc li = Pexp_new (mkloc loc li);;

let ocaml_pexp_newtype = Some (fun s e -> Pexp_newtype (s, e));;

let ocaml_pexp_object = Some (fun cs -> Pexp_object cs);;

let ocaml_pexp_open = Some (fun li e -> Pexp_open (mknoloc li, e));;

let ocaml_pexp_override sel =
  let sel = List.map (fun (s, e) -> mknoloc s, e) sel in Pexp_override sel
;;

let ocaml_pexp_pack : ('a -> 'b -> 'c, 'd) choice option =
  Some (Right ((fun me -> Pexp_pack me), (fun pt -> Ptyp_package pt)))
;;

let ocaml_pexp_poly = Some (fun e t -> Pexp_poly (e, t));;

let ocaml_pexp_record lel eo =
  let lel = List.map (fun (li, loc, e) -> mkloc loc li, e) lel in
  Pexp_record (lel, eo)
;;

let ocaml_pexp_setinstvar s e = Pexp_setinstvar (mknoloc s, e);;

let ocaml_pexp_variant =
  let pexp_variant_pat =
    function
      Pexp_variant (lab, eo) -> Some (lab, eo)
    | _ -> None
  in
  let pexp_variant (lab, eo) = Pexp_variant (lab, eo) in
  Some (pexp_variant_pat, pexp_variant)
;;

let ocaml_value_binding p e = p, e;;

let ocaml_ppat_alias p i iloc = Ppat_alias (p, mkloc iloc i);;

let ocaml_ppat_array = Some (fun pl -> Ppat_array pl);;

let ocaml_ppat_construct loc li po chk_arity =
  Ppat_construct (li, po, chk_arity)
;;

let ocaml_ppat_construct_args =
  function
    Ppat_construct (li, po, chk_arity) -> Some (li, 0, po, chk_arity)
  | _ -> None
;;

let mkpat_ocaml_ppat_construct_arity loc li_loc li al =
  let a = ocaml_mkpat loc (Ppat_tuple al) in
  ocaml_mkpat loc (ocaml_ppat_construct li_loc li (Some a) true)
;;

let ocaml_ppat_lazy = Some (fun p -> Ppat_lazy p);;

let ocaml_ppat_record lpl is_closed =
  let lpl = List.map (fun (li, loc, p) -> mkloc loc li, p) lpl in
  Ppat_record (lpl, (if is_closed then Closed else Open))
;;

let ocaml_ppat_type = Some (fun loc li -> Ppat_type (mkloc loc li));;

let ocaml_ppat_unpack = None;;

let ocaml_ppat_var loc s = Ppat_var (mkloc loc s);;

let ocaml_ppat_variant =
  let ppat_variant_pat =
    function
      Ppat_variant (lab, po) -> Some (lab, po)
    | _ -> None
  in
  let ppat_variant (lab, po) = Ppat_variant (lab, po) in
  Some (ppat_variant_pat, ppat_variant)
;;

let ocaml_psig_class_type = Some (fun ctl -> Psig_class_type ctl);;

let ocaml_psig_exception loc s ed = Psig_exception (mkloc loc s, ed);;

let ocaml_psig_include mt = Psig_include mt;;

let ocaml_psig_module s mt = Psig_module (mknoloc s, mt);;

let ocaml_psig_modtype loc s mto =
  let mtd =
    match mto with
      None -> Pmodtype_abstract
    | Some t -> Pmodtype_manifest t
  in
  Psig_modtype (mknoloc s, mtd)
;;

let ocaml_psig_open li = Psig_open (mknoloc li);;

let ocaml_psig_recmodule =
  let f ntl =
    let ntl = List.map (fun (s, mt) -> mknoloc s, mt) ntl in
    Psig_recmodule ntl
  in
  Some f
;;

let ocaml_psig_type stl =
  let stl = List.map (fun (s, t) -> mknoloc s, t) stl in Psig_type stl
;;

let ocaml_psig_value s vd = Psig_value (mknoloc s, vd);;

let ocaml_pstr_class_type = Some (fun ctl -> Pstr_class_type ctl);;

let ocaml_pstr_eval e = Pstr_eval e;;

let ocaml_pstr_exception s ed = Pstr_exception (mknoloc s, ed);;

let ocaml_pstr_exn_rebind =
  Some (fun s li -> Pstr_exn_rebind (mknoloc s, mknoloc li))
;;

let ocaml_pstr_include = Some (fun me -> Pstr_include me);;

let ocaml_pstr_modtype loc s mt = Pstr_modtype (mkloc loc s, mt);;

let ocaml_pstr_module loc s me = Pstr_module (mkloc loc s, me);;

let ocaml_pstr_open li = Pstr_open (mknoloc li);;

let ocaml_pstr_primitive s vd = Pstr_primitive (mknoloc s, vd);;

let ocaml_pstr_recmodule = Some (fun nel -> Pstr_recmodule nel);;

let ocaml_pstr_type stl = Pstr_type stl;;

let ocaml_class_infos =
  Some
    (fun virt (sl, sloc) name expr loc variance ->
       let params = List.map (fun s -> mkloc loc s) sl, sloc in
       {pci_virt = virt; pci_params = params; pci_name = mkloc loc name;
        pci_expr = expr; pci_loc = loc; pci_variance = variance})
;;

let ocaml_pmod_ident li = Pmod_ident (mknoloc li);;

let ocaml_pmod_functor s mt me = Pmod_functor (mknoloc s, mt, me);;

let ocaml_pmod_unpack : ('a -> 'b -> 'c, 'd) choice option =
  Some (Right ((fun e -> Pmod_unpack e), (fun pt -> Ptyp_package pt)))
;;

let ocaml_pcf_cstr = Some (fun (t1, t2, loc) -> Pcf_cstr (t1, t2, loc));;

let ocaml_pcf_inher ce pb = Pcf_inher (Fresh, ce, pb);;

let ocaml_pcf_init = Some (fun e -> Pcf_init e);;

let ocaml_pcf_meth (s, pf, ovf, e, loc) =
  let pf = if pf then Private else Public in
  let ovf = if ovf then Override else Fresh in Pcf_meth (s, pf, ovf, e, loc)
;;

let ocaml_pcf_val (s, mf, ovf, e, loc) =
  let mf = if mf then Mutable else Immutable in
  let ovf = if ovf then Override else Fresh in Pcf_val (s, mf, ovf, e, loc)
;;

let ocaml_pcf_valvirt =
  let ocaml_pcf (s, mf, t, loc) =
    let mf = if mf then Mutable else Immutable in Pcf_valvirt (s, mf, t, loc)
  in
  Some ocaml_pcf
;;

let ocaml_pcf_virt (s, pf, t, loc) = Pcf_virt (s, pf, t, loc);;

let ocaml_pcl_apply = Some (fun ce lel -> Pcl_apply (ce, lel));;

let ocaml_pcl_constr = Some (fun li ctl -> Pcl_constr (mknoloc li, ctl));;

let ocaml_pcl_constraint = Some (fun ce ct -> Pcl_constraint (ce, ct));;

let ocaml_pcl_fun = Some (fun lab ceo p ce -> Pcl_fun (lab, ceo, p, ce));;

let ocaml_pcl_let = Some (fun rf pel ce -> Pcl_let (rf, pel, ce));;

let ocaml_pcl_structure = Some (fun cs -> Pcl_structure cs);;

let ocaml_pctf_cstr = Some (fun (t1, t2, loc) -> Pctf_cstr (t1, t2, loc));;

let ocaml_pctf_inher ct = Pctf_inher ct;;

let ocaml_pctf_meth (s, pf, t, loc) = Pctf_meth (s, pf, t, loc);;

let ocaml_pctf_val (s, mf, t, loc) = Pctf_val (s, mf, Concrete, t, loc);;

let ocaml_pctf_virt (s, pf, t, loc) = Pctf_virt (s, pf, t, loc);;

let ocaml_pcty_constr = Some (fun li ltl -> Pcty_constr (mknoloc li, ltl));;

let ocaml_pcty_fun = Some (fun lab t ct -> Pcty_fun (lab, t, ct));;

let ocaml_pcty_signature = Some (fun (t, cil) -> Pcty_signature (t, cil));;

let ocaml_pdir_bool = Some (fun b -> Pdir_bool b);;

let ocaml_pwith_modsubst =
  Some (fun loc me -> Pwith_modsubst (mkloc loc me))
;;

let ocaml_pwith_type loc (i, td) = Pwith_type td;;

let ocaml_pwith_module loc me = Pwith_module (mkloc loc me);;

let ocaml_pwith_typesubst = Some (fun td -> Pwith_typesubst td);;

let module_prefix_can_be_in_first_record_label_only = true;;

let split_or_patterns_with_bindings = false;;

let has_records_with_with = true;;

let joinclause (loc, jc) =
  let jc =
    List.map
      (fun (loc, (jpl, e)) ->
         let jpl =
           List.map
             (fun (locp, (loci, s), p) ->
                let ji = {pjident_desc = s; pjident_loc = loci} in
                {pjpat_desc = ji, p; pjpat_loc = locp})
             jpl
         in
         {pjclause_desc = jpl, e; pjclause_loc = loc})
      jc
  in
  {pjauto_desc = jc; pjauto_loc = loc}
;;

let jocaml_pstr_def = Some (fun jcl -> Pstr_def (List.map joinclause jcl));;

let jocaml_pexp_def =
  Some (fun jcl e -> Pexp_def (List.map joinclause jcl, e))
;;

let jocaml_pexp_par = Some (fun e1 e2 -> Pexp_par (e1, e2));;

let jocaml_pexp_reply =
  let pexp_reply loc e (sloc, s) =
    let ji = {pjident_desc = s; pjident_loc = sloc} in Pexp_reply (e, ji)
  in
  Some pexp_reply
;;

let jocaml_pexp_spawn = Some (fun e -> Pexp_spawn e);;

let arg_rest =
  function
    Arg.Rest r -> Some r
  | _ -> None
;;

let arg_set_string =
  function
    Arg.Set_string r -> Some r
  | _ -> None
;;

let arg_set_int =
  function
    Arg.Set_int r -> Some r
  | _ -> None
;;

let arg_set_float =
  function
    Arg.Set_float r -> Some r
  | _ -> None
;;

let arg_symbol =
  function
    Arg.Symbol (s, f) -> Some (s, f)
  | _ -> None
;;

let arg_tuple =
  function
    Arg.Tuple t -> Some t
  | _ -> None
;;

let arg_bool =
  function
    Arg.Bool f -> Some f
  | _ -> None
;;

let char_escaped = Char.escaped;;

let hashtbl_mem = Hashtbl.mem;;

let list_rev_append = List.rev_append;;

let list_rev_map = List.rev_map;;

let list_sort = List.sort;;

let pervasives_set_binary_mode_out = Pervasives.set_binary_mode_out;;

let printf_ksprintf = Printf.ksprintf;;

let string_contains = String.contains;;

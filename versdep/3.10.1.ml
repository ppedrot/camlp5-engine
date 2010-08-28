(* camlp5r pa_macro.cmo *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007-2010 *)

open Parsetree;;
open Longident;;
open Asttypes;;

(* *)

(* *)

(* *)

(* *)

(* *)

let sys_ocaml_version = Sys.ocaml_version;;

let ocaml_location (fname, lnum, bolp, bp, ep) =
  let loc_at n =
    {Lexing.pos_fname = if lnum = -1 then "" else fname;
     Lexing.pos_lnum = lnum; Lexing.pos_bol = bolp; Lexing.pos_cnum = n}
  in
  {Location.loc_start = loc_at bp; Location.loc_end = loc_at ep;
   Location.loc_ghost = bp = 0 && ep = 0}
;;

let ocaml_ptyp_poly = Some (fun cl t -> Ptyp_poly (cl, t));;

let ocaml_type_declaration params cl tk pf tm loc variance =
  {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
   ptype_manifest = tm; ptype_loc = loc; ptype_variance = variance}
;;

let ocaml_ptype_record ltl priv = Ptype_record (ltl, priv);;

let ocaml_ptype_variant ctl priv = Ptype_variant (ctl, priv);;

let ocaml_ptype_private = Ptype_private;;

let ocaml_pwith_type params tk pf ct variance loc =
  Pwith_type
    {ptype_params = params; ptype_cstrs = []; ptype_kind = tk;
     ptype_manifest = ct; ptype_variance = variance; ptype_loc = loc}
;;

let ocaml_pexp_lazy = Some (fun e -> Pexp_lazy e);;

let ocaml_const_int32 = Some (fun s -> Const_int32 (Int32.of_string s));;

let ocaml_const_int64 = Some (fun s -> Const_int64 (Int64.of_string s));;

let ocaml_const_nativeint =
  Some (fun s -> Const_nativeint (Nativeint.of_string s))
;;

let ocaml_pexp_object = Some (fun cs -> Pexp_object cs);;

let module_prefix_can_be_in_first_record_label_only = true;;

let ocaml_ppat_lazy = None;;

let ocaml_ppat_record lpl = Ppat_record lpl;;

let ocaml_psig_recmodule = Some (fun ntl -> Psig_recmodule ntl);;

let ocaml_pstr_recmodule = Some (fun nel -> Pstr_recmodule nel);;

let ocaml_pctf_val (s, b, t, loc) = Pctf_val (s, b, Concrete, t, loc);;

let ocaml_pcf_inher ce pb = Pcf_inher (ce, pb);;

let ocaml_pcf_meth (s, b, e, loc) = Pcf_meth (s, b, e, loc);;

let ocaml_pcf_val (s, b, e, loc) = Pcf_val (s, b, e, loc);;

let ocaml_pexp_poly = Some (fun e t -> Pexp_poly (e, t));;

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

(* camlp5r *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007-2010 *)

type location = Ploc.t;;

exception Exc_located = Ploc.Exc;;
let raise_with_loc = Ploc.raise;;

let make_lined_loc = Ploc.make;;
let make_loc = Ploc.make_unlined;;
let dummy_loc = Ploc.dummy;;

let first_pos = Ploc.first_pos;;
let last_pos = Ploc.last_pos;;
let line_nb = Ploc.line_nb;;
let bol_pos = Ploc.bol_pos;;

let encl_loc = Ploc.encl;;
let shift_loc = Ploc.shift;;
let sub_loc = Ploc.sub;;
let after_loc = Ploc.after;;

let line_of_loc = Ploc.from_file;;
let loc_name = Ploc.name;;

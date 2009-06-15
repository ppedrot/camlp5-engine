(* camlp5r *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007-2008 *)

(** Locations and some pervasive type and value. *)

type t;;

(* located exceptions *)

exception Exc of t * exn;;
   (** [Ploc.Exc loc e] is an encapsulation of the exception [e] with
       the input location [loc]. To be used to specify a location
       for an error. This exception must not be raised by [raise] but
       rather by [Ploc.raise] (see below), to prevent the risk of several
       encapsulations of [Ploc.Exc]. *)
val raise : t -> exn -> 'a;;
   (** [Ploc.raise loc e], if [e] is already the exception [Ploc.Exc],
       re-raise it (ignoring the new location [loc]), else raise the
       exception [Ploc.Exc loc e]. *)

(* making locations *)

val make : int -> int -> int * int -> t;;
   (** [Ploc.make line_nb bol_pos (bp, ep)] creates a location starting
       at line number [line_nb], where the position of the beginning of the
       line is [bol_pos] and between the positions [bp] (included) and [ep]
       excluded. The positions are in number of characters since the begin
       of the stream. *)
val make_unlined : int * int -> t;;
   (** [Ploc.make_unlined] is like [Ploc.make] except that the line number
       is not provided (to be used e.g. when the line number is unknown. *)

val dummy : t;;
   (** [Ploc.dummy] is a dummy location, used in situations when location
       has no meaning. *)

(* getting location info *)

val first_pos : t -> int;;
   (** [Ploc.first_pos loc] returns the position of the begin of the location
       in number of characters since the beginning of the stream. *)
val last_pos : t -> int;;
   (** [Ploc.last_pos loc] returns the position of the first character not
       of the location in number of characters since the beginning of the
       stream. *)
val line_nb : t -> int;;
   (** [Ploc.line_nb loc] returns the line number of the location or [-1] if
       the location does not contain a line number (i.e. built with
       [Ploc.make_unlined]. *)
val bol_pos : t -> int;;
   (** [Ploc.bol_pos loc] returns the position of the beginning of the line
       of the location in number of characters since the beginning of
       the stream, or [0] if the location does not contain a line number
       (i.e. built with [Ploc.make_unlined]. *)

(* combining locations *)

val encl : t -> t -> t;;
   (** [Ploc.encl loc1 loc2] returns the location starting at the
       smallest start of [loc1] and [loc2] and ending at the greatest end
       of them. In other words, it is the location enclosing [loc1] and
       [loc2]. *)
val shift : int -> t -> t;;
   (** [Ploc.shift sh loc] returns the location [loc] shifted with [sh]
       characters. The line number is not recomputed. *)
val sub : t -> int -> int -> t;;
   (** [Ploc.sub loc sh len] is the location [loc] shifted with [sh]
       characters and with length [len]. The previous ending position
       of the location is lost. *)
val after : t -> int -> int -> t;;
   (** [Ploc.after loc sh len] is the location just after loc (starting at
       the end position of [loc]) shifted with [sh] characters and of length
       [len]. *)

(* miscellaneous *)

val name : string ref;;
   (** [Ploc.name.val] is the name of the location variable used in grammars
       and in the predefined quotations for OCaml syntax trees. Default:
       ["loc"] *)

val from_file : string -> t -> string * int * int * int;;
   (** [Ploc.from_file fname loc] reads the file [fname] up to the
       location [loc] and returns the real input file, the line number
       and the characters location in the line; the real input file
       can be different from [fname] because of possibility of line
       directives typically generated by /lib/cpp. *)

(* pervasives *)

type 'a vala =
    VaAnt of string
  | VaVal of 'a
;;
   (** Encloser of many abstract syntax tree nodes types, in "strict" mode.
       Thhis allow the system of antiquotations of abstract syntax tree
       quotations to work when using the quotation kit [q_ast.cmo]. *)

val call_with : 'a ref -> 'a -> ('b -> 'c) -> 'b -> 'c;;
   (** [Ploc.call_with r v f a] sets the reference [r] to the value [v],
       then call [f a], and resets [r] to its initial value. If [f a] raises
       an exception, its initial value is also reset and the exception is
       re-raised. The result is the result of [f a]. *)

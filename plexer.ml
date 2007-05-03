(* camlp4r pa_lex.cmo *)
(***********************************************************************)
(*                                                                     *)
(*                             Camlp4                                  *)
(*                                                                     *)
(*                Daniel de Rauglaudre, INRIA Rocquencourt             *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  Automatique.  Distributed only by permission.                      *)
(*                                                                     *)
(***********************************************************************)

(* This file has been generated by program: do not edit! *)

open Token;;

let no_quotations = ref false;;
let error_on_unknown_keywords = ref false;;

let dollar_for_antiquotation = ref true;;
let specific_space_dot = ref false;;

(* The string buffering machinery *)

let rev_implode l =
  let s = String.create (List.length l) in
  let rec loop i =
    function
      c :: l -> String.unsafe_set s i c; loop (i - 1) l
    | [] -> s
  in
  loop (String.length s - 1) l
;;

module B :
  sig
    type t;;
    val empty : t;;
    val add : char -> t -> t;;
    val get : t -> string;;
  end =
  struct
    type t = char list;;
    let empty = [];;
    let add c l = c :: l;;
    let get = rev_implode;;
  end
;;

(* The lexer *)

type context =
  { mutable after_space : bool;
    dollar_for_antiquotation : bool;
    specific_space_dot : bool;
    find_kwd : string -> string;
    line_cnt : int -> char -> unit;
    set_line_nb : unit -> unit;
    make_lined_loc : int * int -> string -> Stdpp.location }
;;

let err ctx loc msg =
  Stdpp.raise_with_loc (ctx.make_lined_loc loc "") (Token.Error msg)
;;

let keyword_or_error ctx loc s =
  try "", ctx.find_kwd s with
    Not_found ->
      if !error_on_unknown_keywords then err ctx loc ("illegal token: " ^ s)
      else "", s
;;

let stream_peek_nth n strm =
  let rec loop n =
    function
      [] -> None
    | [x] -> if n == 1 then Some x else None
    | _ :: l -> loop (n - 1) l
  in
  loop n (Stream.npeek n strm)
;;

let rec ident buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some
      ('A'..'Z' | 'a'..'z' | '0'..'9' | '_' | '\'' | '\128'..'\255' as c) ->
      Stream.junk strm__; ident (B.add c buf) strm__
  | _ -> buf
;;
let rec ident2 buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some
      ('!' | '?' | '~' | '=' | '@' | '^' | '&' | '+' | '-' | '*' | '/' | '%' |
       '.' | ':' | '<' | '>' | '|' | '$' as c) ->
      Stream.junk strm__; ident2 (B.add c buf) strm__
  | _ -> buf
;;

let rec ident3 buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some
      ('0'..'9' | 'A'..'Z' | 'a'..'z' | '_' | '!' | '%' | '&' | '*' | '+' |
       '-' | '.' | '/' | ':' | '<' | '=' | '>' | '?' | '@' | '^' | '|' | '~' |
       '\'' | '$' | '\128'..'\255' as c) ->
      Stream.junk strm__; ident3 (B.add c buf) strm__
  | _ -> buf
;;

let binary buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('0' | '1' as c) -> Stream.junk strm__; B.add c buf
  | _ -> raise Stream.Failure
;;
let octal buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('0'..'7' as c) -> Stream.junk strm__; B.add c buf
  | _ -> raise Stream.Failure
;;
let decimal buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('0'..'9' as c) -> Stream.junk strm__; B.add c buf
  | _ -> raise Stream.Failure
;;
let hexa buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('0'..'9' | 'a'..'f' | 'A'..'F' as c) ->
      Stream.junk strm__; B.add c buf
  | _ -> raise Stream.Failure
;;

let end_integer buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some 'l' -> Stream.junk strm__; "INT_l", B.get buf
  | Some 'L' -> Stream.junk strm__; "INT_L", B.get buf
  | Some 'n' -> Stream.junk strm__; "INT_n", B.get buf
  | _ -> "INT", B.get buf
;;

let rec digits_under kind buf (strm__ : _ Stream.t) =
  match
    try Some (kind buf strm__) with
      Stream.Failure -> None
  with
    Some buf -> digits_under kind buf strm__
  | _ ->
      match Stream.peek strm__ with
        Some '_' ->
          Stream.junk strm__; digits_under kind (B.add '_' buf) strm__
      | _ -> end_integer buf strm__
;;

let digits kind buf (strm__ : _ Stream.t) =
  let buf =
    try kind buf strm__ with
      Stream.Failure -> raise (Stream.Error "ill-formed integer constant")
  in
  digits_under kind buf strm__
;;

let rec decimal_digits_under buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('0'..'9' | '_' as c) ->
      Stream.junk strm__; decimal_digits_under (B.add c buf) strm__
  | _ -> buf
;;

let exponent_part buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('e' | 'E' as c) ->
      Stream.junk strm__;
      let buf = B.add c buf in
      let buf =
        match Stream.peek strm__ with
          Some ('+' | '-' as c) -> Stream.junk strm__; B.add c buf
        | _ -> buf
      in
      begin match Stream.peek strm__ with
        Some ('0'..'9' as c) ->
          Stream.junk strm__; decimal_digits_under (B.add c buf) strm__
      | _ -> raise (Stream.Error "ill-formed floating-point constant")
      end
  | _ -> raise Stream.Failure
;;

let number buf (strm__ : _ Stream.t) =
  let buf = decimal_digits_under buf strm__ in
  match Stream.peek strm__ with
    Some '.' ->
      Stream.junk strm__;
      let buf = decimal_digits_under (B.add '.' buf) strm__ in
      let buf =
        try exponent_part buf strm__ with
          Stream.Failure -> buf
      in
      "FLOAT", B.get buf
  | _ ->
      match
        try Some (exponent_part buf strm__) with
          Stream.Failure -> None
      with
        Some buf -> "FLOAT", B.get buf
      | _ -> end_integer buf strm__
;;

let rec char_aux ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some '\'' -> Stream.junk strm__; buf
  | Some '\\' ->
      Stream.junk strm__;
      begin match Stream.peek strm__ with
        Some c ->
          Stream.junk strm__;
          char_aux ctx bp (B.add c (B.add '\\' buf)) strm__
      | _ -> raise (Stream.Error "")
      end
  | Some c -> Stream.junk strm__; char_aux ctx bp (B.add c buf) strm__
  | _ -> err ctx (bp, Stream.count strm__) "char not terminated"
;;

let char ctx bp buf (strm__ : _ Stream.t) =
  match Stream.npeek 2 strm__ with
    [_; '\''] | ['\\'; _] ->
      begin match Stream.peek strm__ with
        Some '\'' ->
          Stream.junk strm__; char_aux ctx bp (B.add '\'' buf) strm__
      | _ -> char_aux ctx bp buf strm__
      end
  | _ -> raise Stream.Failure
;;

let any ctx buf (strm__ : _ Stream.t) =
  let bp = Stream.count strm__ in
  match Stream.peek strm__ with
    Some c -> Stream.junk strm__; begin ctx.line_cnt bp c; B.add c buf end
  | _ -> raise Stream.Failure
;;

let rec string ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some '\"' -> Stream.junk strm__; buf
  | Some '\\' ->
      Stream.junk strm__;
      let buf =
        try any ctx (B.add '\\' buf) strm__ with
          Stream.Failure -> raise (Stream.Error "")
      in
      string ctx bp buf strm__
  | _ ->
      match
        try Some (any ctx buf strm__) with
          Stream.Failure -> None
      with
        Some buf -> string ctx bp buf strm__
      | _ -> err ctx (bp, Stream.count strm__) "string not terminated"
;;

let comment ctx bp =
  let rec comment buf (strm__ : _ Stream.t) =
    match Stream.peek strm__ with
      Some '*' ->
        Stream.junk strm__;
        let buf = B.add '*' buf in
        begin match Stream.peek strm__ with
          Some ')' -> Stream.junk strm__; B.add ')' buf
        | _ -> comment buf strm__
        end
    | Some '(' ->
        Stream.junk strm__;
        let buf = B.add '(' buf in
        let buf =
          match Stream.peek strm__ with
            Some '*' -> Stream.junk strm__; comment (B.add '*' buf) strm__
          | _ -> buf
        in
        comment buf strm__
    | Some '\"' ->
        Stream.junk strm__;
        let buf = string ctx bp (B.add '\"' buf) strm__ in
        let buf = B.add '\"' buf in comment buf strm__
    | Some '\'' ->
        Stream.junk strm__;
        let buf = B.add '\'' buf in
        let buf =
          try char ctx bp buf strm__ with
            Stream.Failure -> buf
        in
        comment buf strm__
    | _ ->
        match
          try Some (any ctx buf strm__) with
            Stream.Failure -> None
        with
          Some buf -> comment buf strm__
        | _ -> err ctx (bp, Stream.count strm__) "comment not terminated"
  in
  comment
;;

let rec quotation ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some '>' ->
      Stream.junk strm__;
      begin match Stream.peek strm__ with
        Some '>' -> Stream.junk strm__; buf
      | _ -> let buf = B.add '>' buf in quotation ctx bp buf strm__
      end
  | Some '<' ->
      Stream.junk strm__;
      let buf = B.add '<' buf in
      let buf =
        match Stream.peek strm__ with
          Some '<' ->
            Stream.junk strm__;
            let buf = quotation ctx bp (B.add '<' buf) strm__ in
            B.add '>' (B.add '>' buf)
        | Some ':' ->
            Stream.junk strm__;
            let buf = ident (B.add ':' buf) strm__ in
            begin match Stream.peek strm__ with
              Some '<' ->
                Stream.junk strm__;
                let buf = quotation ctx bp (B.add '<' buf) strm__ in
                B.add '>' (B.add '>' buf)
            | _ -> buf
            end
        | _ -> buf
      in
      quotation ctx bp buf strm__
  | Some '\\' ->
      Stream.junk strm__;
      let buf =
        match Stream.peek strm__ with
          Some ('>' | '<' | '\\' as c) -> Stream.junk strm__; B.add c buf
        | _ -> B.add '\\' buf
      in
      quotation ctx bp buf strm__
  | _ ->
      match
        try Some (any ctx buf strm__) with
          Stream.Failure -> None
      with
        Some buf -> quotation ctx bp buf strm__
      | _ -> err ctx (bp, Stream.count strm__) "quotation not terminated"
;;

let less ctx bp buf strm =
  if !no_quotations then
    let (strm__ : _ Stream.t) = strm in
    let buf = B.add '<' buf in
    let buf = ident2 buf strm__ in
    keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  else
    let (strm__ : _ Stream.t) = strm in
    match Stream.peek strm__ with
      Some '<' ->
        Stream.junk strm__;
        let buf =
          try quotation ctx bp buf strm__ with
            Stream.Failure -> raise (Stream.Error "")
        in
        "QUOTATION", ":" ^ B.get buf
    | Some ':' ->
        Stream.junk strm__;
        let buf = ident buf strm__ in
        let buf = B.add ':' buf in
        begin match Stream.peek strm__ with
          Some '<' ->
            Stream.junk strm__;
            let buf =
              try quotation ctx bp buf strm__ with
                Stream.Failure -> raise (Stream.Error "")
            in
            "QUOTATION", B.get buf
        | _ -> raise (Stream.Error "character '<' expected")
        end
    | _ ->
        let buf = B.add '<' buf in
        let buf = ident2 buf strm__ in
        keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
;;

let rec antiquot ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some '$' -> Stream.junk strm__; "ANTIQUOT", ":" ^ B.get buf
  | Some ('a'..'z' | 'A'..'Z' | '0'..'9' as c) ->
      Stream.junk strm__; antiquot ctx bp (B.add c buf) strm__
  | Some ':' ->
      Stream.junk strm__;
      let buf = antiquot_rest ctx bp (B.add ':' buf) strm__ in
      "ANTIQUOT", B.get buf
  | Some '\\' ->
      Stream.junk strm__;
      let buf =
        try any ctx buf strm__ with
          Stream.Failure -> raise (Stream.Error "")
      in
      let buf = antiquot_rest ctx bp buf strm__ in "ANTIQUOT", ":" ^ B.get buf
  | _ ->
      match
        try Some (any ctx buf strm__) with
          Stream.Failure -> None
      with
        Some buf ->
          let buf = antiquot_rest ctx bp buf strm__ in
          "ANTIQUOT", ":" ^ B.get buf
      | _ -> err ctx (bp, Stream.count strm__) "antiquotation not terminated"
and antiquot_rest ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some '$' -> Stream.junk strm__; buf
  | Some '\\' ->
      Stream.junk strm__;
      let buf =
        try any ctx buf strm__ with
          Stream.Failure -> raise (Stream.Error "")
      in
      antiquot_rest ctx bp buf strm__
  | _ ->
      match
        try Some (any ctx buf strm__) with
          Stream.Failure -> None
      with
        Some buf -> antiquot_rest ctx bp buf strm__
      | _ -> err ctx (bp, Stream.count strm__) "antiquotation not terminated"
;;

let dollar ctx bp buf strm =
  if ctx.dollar_for_antiquotation then antiquot ctx bp buf strm
  else
    let (strm__ : _ Stream.t) = strm in
    let buf = B.add '$' buf in let buf = ident2 buf strm__ in "", B.get buf
;;

let rec linedir n s =
  match stream_peek_nth n s with
    Some (' ' | '\t') -> linedir (n + 1) s
  | Some ('0'..'9') -> linedir_digits (n + 1) s
  | _ -> false
and linedir_digits n s =
  match stream_peek_nth n s with
    Some ('0'..'9') -> linedir_digits (n + 1) s
  | _ -> linedir_quote n s
and linedir_quote n s =
  match stream_peek_nth n s with
    Some (' ' | '\t') -> linedir_quote (n + 1) s
  | Some '\"' -> true
  | _ -> false
;;

let rec any_to_nl buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('\r' | '\n' as c) -> Stream.junk strm__; B.add c buf
  | Some c -> Stream.junk strm__; any_to_nl (B.add c buf) strm__
  | _ -> buf
;;

let next_token_after_spaces ctx bp buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('A'..'Z' as c) ->
      Stream.junk strm__;
      let buf = ident (B.add c buf) strm__ in
      let id = B.get buf in
      begin try "", ctx.find_kwd id with
        Not_found -> "UIDENT", id
      end
  | Some ('a'..'z' | '_' | '\128'..'\255' as c) ->
      Stream.junk strm__;
      let buf = ident (B.add c buf) strm__ in
      let id = B.get buf in
      begin try "", ctx.find_kwd id with
        Not_found -> "LIDENT", id
      end
  | Some ('1'..'9' as c) -> Stream.junk strm__; number (B.add c buf) strm__
  | Some '0' ->
      Stream.junk strm__;
      let buf = B.add '0' buf in
      begin match Stream.peek strm__ with
        Some ('o' | 'O' as c) ->
          Stream.junk strm__; digits octal (B.add c buf) strm__
      | Some ('x' | 'X' as c) ->
          Stream.junk strm__; digits hexa (B.add c buf) strm__
      | Some ('b' | 'B' as c) ->
          Stream.junk strm__; digits binary (B.add c buf) strm__
      | _ -> number buf strm__
      end
  | Some '\'' ->
      Stream.junk strm__;
      begin match
        try Some (char ctx bp buf strm__) with
          Stream.Failure -> None
      with
        Some buf -> "CHAR", B.get buf
      | _ -> keyword_or_error ctx (bp, Stream.count strm__) "'"
      end
  | Some '\"' ->
      Stream.junk strm__;
      let buf = string ctx bp buf strm__ in "STRING", B.get buf
  | Some '$' -> Stream.junk strm__; dollar ctx bp buf strm__
  | Some ('!' | '=' | '@' | '^' | '&' | '+' | '-' | '*' | '/' | '%' as c) ->
      Stream.junk strm__;
      let buf = ident2 (B.add c buf) strm__ in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  | Some '~' ->
      Stream.junk strm__;
      begin match Stream.peek strm__ with
        Some ('a'..'z' as c) ->
          Stream.junk strm__;
          let buf = ident (B.add c buf) strm__ in "TILDEIDENT", B.get buf
      | _ ->
          let buf = B.add '~' buf in
          let buf = ident2 buf strm__ in
          keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
      end
  | Some '?' ->
      Stream.junk strm__;
      begin match Stream.peek strm__ with
        Some ('a'..'z' as c) ->
          Stream.junk strm__;
          let buf = ident (B.add c buf) strm__ in "QUESTIONIDENT", B.get buf
      | _ ->
          let buf = B.add '?' buf in
          let buf = ident2 buf strm__ in
          keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
      end
  | Some '<' -> Stream.junk strm__; less ctx bp buf strm__
  | Some ':' ->
      Stream.junk strm__;
      let buf = B.add ':' buf in
      let buf =
        match Stream.peek strm__ with
          Some (']' | ':' | '=' | '>' as c) -> Stream.junk strm__; B.add c buf
        | _ -> buf
      in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  | Some ('>' | '|' as c) ->
      Stream.junk strm__;
      let buf = B.add c buf in
      let buf =
        match Stream.peek strm__ with
          Some (']' | '}' as c) -> Stream.junk strm__; B.add c buf
        | _ -> ident2 buf strm__
      in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  | Some ('[' | '{' as c) ->
      Stream.junk strm__;
      let buf = B.add c buf in
      let buf =
        match Stream.npeek 2 strm__ with
          ['<'; '<'] | ['<'; ':'] -> buf
        | _ ->
            match Stream.peek strm__ with
              Some ('|' | '<' | ':' as c) -> Stream.junk strm__; B.add c buf
            | _ -> buf
      in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  | Some '.' ->
      Stream.junk strm__;
      let buf = B.add '.' buf in
      let buf =
        match Stream.peek strm__ with
          Some '.' -> Stream.junk strm__; B.add '.' buf
        | _ -> buf
      in
      let id =
        if B.get buf = ".." then ".."
        else if ctx.specific_space_dot && ctx.after_space then " ."
        else "."
      in
      keyword_or_error ctx (bp, Stream.count strm__) id
  | Some ';' ->
      Stream.junk strm__;
      let buf = B.add ';' buf in
      let buf =
        match Stream.peek strm__ with
          Some ';' -> Stream.junk strm__; B.add ';' buf
        | _ -> buf
      in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
  | Some '\\' ->
      Stream.junk strm__; let buf = ident3 buf strm__ in "LIDENT", B.get buf
  | _ ->
      let buf = any ctx buf strm__ in
      keyword_or_error ctx (bp, Stream.count strm__) (B.get buf)
;;

let rec next_token ctx buf (strm__ : _ Stream.t) =
  let bp = Stream.count strm__ in
  match Stream.peek strm__ with
    Some ('\n' | '\r' as c) ->
      Stream.junk strm__;
      let s = strm__ in
      let ep = Stream.count strm__ in
      incr !(Token.line_nb);
      !(Token.bol_pos) := ep;
      ctx.set_line_nb ();
      ctx.after_space <- true;
      next_token ctx (B.add c buf) s
  | Some (' ' | '\t' | '\026' | '\012' as c) ->
      Stream.junk strm__;
      let s = strm__ in
      ctx.after_space <- true; next_token ctx (B.add c buf) s
  | Some '#' when bp = !(!(Token.bol_pos)) ->
      Stream.junk strm__;
      let s = strm__ in
      if linedir 1 s then
        let buf = any_to_nl (B.add '#' buf) s in
        incr !(Token.line_nb);
        !(Token.bol_pos) := Stream.count s;
        ctx.set_line_nb ();
        ctx.after_space <- true;
        next_token ctx buf s
      else
        let loc = ctx.make_lined_loc (bp, bp + 1) (B.get buf) in
        keyword_or_error ctx (bp, bp + 1) "#", loc
  | Some '(' ->
      Stream.junk strm__;
      begin match Stream.peek strm__ with
        Some '*' ->
          Stream.junk strm__;
          let buf = comment ctx bp (B.add '*' (B.add '(' buf)) strm__ in
          let s = strm__ in
          ctx.set_line_nb (); ctx.after_space <- true; next_token ctx buf s
      | _ ->
          let ep = Stream.count strm__ in
          let loc = ctx.make_lined_loc (bp, ep) (B.get buf) in
          keyword_or_error ctx (bp, ep) "(", loc
      end
  | _ ->
      match
        try Some (next_token_after_spaces ctx bp B.empty strm__) with
          Stream.Failure -> None
      with
        Some tok ->
          let ep = Stream.count strm__ in
          let loc = ctx.make_lined_loc (bp, max (bp + 1) ep) (B.get buf) in
          tok, loc
      | _ ->
          let _ = Stream.empty strm__ in
          let loc = ctx.make_lined_loc (bp, bp + 1) (B.get buf) in
          ("EOI", ""), loc
;;

let next_token_fun ctx glexr (cstrm, s_line_nb, s_bol_pos) =
  try
    begin match !(Token.restore_lexing_info) with
      Some (line_nb, bol_pos) ->
        s_line_nb := line_nb;
        s_bol_pos := bol_pos;
        Token.restore_lexing_info := None
    | None -> ()
    end;
    Token.line_nb := s_line_nb;
    Token.bol_pos := s_bol_pos;
    let comm_bp = Stream.count cstrm in
    ctx.set_line_nb ();
    ctx.after_space <- false;
    let (r, loc) = next_token ctx B.empty cstrm in
    begin match !glexr.tok_comm with
      Some list ->
        if Stdpp.first_pos loc > comm_bp then
          let comm_loc = Stdpp.make_loc (comm_bp, Stdpp.last_pos loc) in
          !glexr.tok_comm <- Some (comm_loc :: list)
    | None -> ()
    end;
    r, loc
  with
    Stream.Error str ->
      err ctx (Stream.count cstrm, Stream.count cstrm + 1) str
;;

let func kwd_table glexr =
  let ctx =
    let line_nb = ref 0 in
    let bol_pos = ref 0 in
    {after_space = false;
     dollar_for_antiquotation = !dollar_for_antiquotation;
     specific_space_dot = !specific_space_dot;
     find_kwd = Hashtbl.find kwd_table;
     line_cnt =
       (fun bp1 c ->
          match c with
            '\n' | '\r' -> incr !(Token.line_nb); !(Token.bol_pos) := bp1 + 1
          | c -> ());
     set_line_nb =
       (fun () ->
          line_nb := !(!(Token.line_nb)); bol_pos := !(!(Token.bol_pos)));
     make_lined_loc =
       fun loc comm ->
         let loc = Stdpp.make_lined_loc !line_nb !bol_pos loc in
         Stdpp.set_comment loc comm; loc}
  in
  Token.lexer_func_of_parser (next_token_fun ctx glexr)
;;

let rec check_keyword_stream (strm__ : _ Stream.t) =
  let _ = check B.empty strm__ in
  let _ =
    try Stream.empty strm__ with
      Stream.Failure -> raise (Stream.Error "")
  in
  true
and check buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some ('A'..'Z' | 'a'..'z' | '\128'..'\255' as c) ->
      Stream.junk strm__; check_ident (B.add c buf) strm__
  | Some
      ('!' | '?' | '~' | '=' | '@' | '^' | '&' | '+' | '-' | '*' | '/' | '%' |
       '.' as c) ->
      Stream.junk strm__; check_ident2 (B.add c buf) strm__
  | Some '<' ->
      Stream.junk strm__;
      let buf = B.add '<' buf in
      begin match Stream.npeek 1 strm__ with
        [':'] | ['<'] -> buf
      | _ -> check_ident2 buf strm__
      end
  | Some ':' ->
      Stream.junk strm__;
      let buf = B.add ':' buf in
      begin match Stream.peek strm__ with
        Some (']' | ':' | '=' | '>' as c) -> Stream.junk strm__; B.add c buf
      | _ -> buf
      end
  | Some ('>' | '|' as c) ->
      Stream.junk strm__;
      let buf = B.add c buf in
      begin match Stream.peek strm__ with
        Some (']' | '}' as c) -> Stream.junk strm__; B.add c buf
      | _ -> check_ident2 buf strm__
      end
  | Some ('[' | '{' as c) ->
      Stream.junk strm__;
      let buf = B.add c buf in
      begin match Stream.npeek 2 strm__ with
        ['<'; '<'] | ['<'; ':'] -> buf
      | _ ->
          match Stream.peek strm__ with
            Some ('|' | '<' | ':' as c) -> Stream.junk strm__; B.add c buf
          | _ -> buf
      end
  | Some ';' ->
      Stream.junk strm__;
      let buf = B.add ';' buf in
      begin match Stream.peek strm__ with
        Some ';' -> Stream.junk strm__; B.add ';' buf
      | _ -> buf
      end
  | Some c -> Stream.junk strm__; B.add c buf
  | _ -> raise Stream.Failure
and check_ident buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some
      ('A'..'Z' | 'a'..'z' | '0'..'9' | '_' | '\'' | '\128'..'\255' as c) ->
      Stream.junk strm__; check_ident (B.add c buf) strm__
  | _ -> buf
and check_ident2 buf (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some
      ('!' | '?' | '~' | '=' | '@' | '^' | '&' | '+' | '-' | '*' | '/' | '%' |
       '.' | ':' | '<' | '>' | '|' as c) ->
      Stream.junk strm__; check_ident2 (B.add c buf) strm__
  | _ -> buf
;;

let check_keyword s =
  try check_keyword_stream (Stream.of_string s) with
    _ -> false
;;

let error_no_respect_rules p_con p_prm =
  raise
    (Token.Error
       ("the token " ^
          (if p_con = "" then "\"" ^ p_prm ^ "\""
           else if p_prm = "" then p_con
           else p_con ^ " \"" ^ p_prm ^ "\"") ^
          " does not respect Plexer rules"))
;;

let error_ident_and_keyword p_con p_prm =
  raise
    (Token.Error
       ("the token \"" ^ p_prm ^ "\" is used as " ^ p_con ^
          " and as keyword"))
;;

let using_token kwd_table ident_table (p_con, p_prm) =
  match p_con with
    "" ->
      if not (Hashtbl.mem kwd_table p_prm) then
        if check_keyword p_prm then
          if Hashtbl.mem ident_table p_prm then
            error_ident_and_keyword (Hashtbl.find ident_table p_prm) p_prm
          else Hashtbl.add kwd_table p_prm p_prm
        else error_no_respect_rules p_con p_prm
  | "LIDENT" ->
      if p_prm = "" then ()
      else
        begin match p_prm.[0] with
          'A'..'Z' -> error_no_respect_rules p_con p_prm
        | _ ->
            if Hashtbl.mem kwd_table p_prm then
              error_ident_and_keyword p_con p_prm
            else Hashtbl.add ident_table p_prm p_con
        end
  | "UIDENT" ->
      if p_prm = "" then ()
      else
        begin match p_prm.[0] with
          'a'..'z' -> error_no_respect_rules p_con p_prm
        | _ ->
            if Hashtbl.mem kwd_table p_prm then
              error_ident_and_keyword p_con p_prm
            else Hashtbl.add ident_table p_prm p_con
        end
  | "TILDEIDENT" | "QUESTIONIDENT" | "INT" | "INT_l" | "INT_L" | "INT_n" |
    "FLOAT" | "CHAR" | "STRING" | "QUOTATION" | "ANTIQUOT" | "EOI" ->
      ()
  | _ ->
      raise
        (Token.Error
           ("the constructor \"" ^ p_con ^ "\" is not recognized by Plexer"))
;;

let removing_token kwd_table ident_table (p_con, p_prm) =
  match p_con with
    "" -> Hashtbl.remove kwd_table p_prm
  | "LIDENT" | "UIDENT" ->
      if p_prm <> "" then Hashtbl.remove ident_table p_prm
  | _ -> ()
;;

let text =
  function
    "", t -> "'" ^ t ^ "'"
  | "LIDENT", "" -> "lowercase identifier"
  | "LIDENT", t -> "'" ^ t ^ "'"
  | "UIDENT", "" -> "uppercase identifier"
  | "UIDENT", t -> "'" ^ t ^ "'"
  | "INT", "" -> "integer"
  | "INT", s -> "'" ^ s ^ "'"
  | "FLOAT", "" -> "float"
  | "STRING", "" -> "string"
  | "CHAR", "" -> "char"
  | "QUOTATION", "" -> "quotation"
  | "ANTIQUOT", k -> "antiquot \"" ^ k ^ "\""
  | "EOI", "" -> "end of input"
  | con, "" -> con
  | con, prm -> con ^ " \"" ^ prm ^ "\""
;;

let eq_before_colon p e =
  let rec loop i =
    if i == String.length e then
      failwith "Internal error in Plexer: incorrect ANTIQUOT"
    else if i == String.length p then e.[i] == ':'
    else if p.[i] == e.[i] then loop (i + 1)
    else false
  in
  loop 0
;;

let after_colon e =
  try
    let i = String.index e ':' in
    String.sub e (i + 1) (String.length e - i - 1)
  with
    Not_found -> ""
;;

let tok_match =
  function
    "ANTIQUOT", p_prm ->
      begin function
        "ANTIQUOT", prm when eq_before_colon p_prm prm -> after_colon prm
      | _ -> raise Stream.Failure
      end
  | tok -> Token.default_match tok
;;

let gmake () =
  let kwd_table = Hashtbl.create 301 in
  let id_table = Hashtbl.create 301 in
  let glexr =
    ref
      {tok_func = (fun _ -> raise (Match_failure ("plexer.ml", 518, 17)));
       tok_using = (fun _ -> raise (Match_failure ("plexer.ml", 518, 37)));
       tok_removing = (fun _ -> raise (Match_failure ("plexer.ml", 518, 60)));
       tok_match = (fun _ -> raise (Match_failure ("plexer.ml", 519, 18)));
       tok_text = (fun _ -> raise (Match_failure ("plexer.ml", 519, 37)));
       tok_comm = None}
  in
  let glex =
    {tok_func = func kwd_table glexr;
     tok_using = using_token kwd_table id_table;
     tok_removing = removing_token kwd_table id_table; tok_match = tok_match;
     tok_text = text; tok_comm = None}
  in
  glexr := glex; glex
;;

(* FrontC Main Function *)
(* Kelun Chai, Djbaer Solimani *)
open Format
open Lexing
open Parsing

let () = Printexc.record_backtrace true
let ifile = ref ""
let set_file f s = f :=s 
let options = []

(* if input type is wrong, assert usage *)
let usage = "usage: frontc [option] file.c";;

(* localisation des erreur *)
let localisation pos = 
  let l = pos.pos_lnum in
  let c = pos.pos_cnum - pos.pos_bol + 1 in
  eprintf "File \"%s\", line %d, characters %d-%d:\n" !ifile l (c-1) c

let () = 
  Arg.parse options (set_file ifile) usage;
  if !ifile="" then (eprintf "Aucun fichier a compiler\n@?"; exit 1);
  if not (Filename.check_suffix !ifile ".c") then begin
    eprintf "Le fichier d'entree doit avoir l'extension .c\n@?";
    Arg.usage options usage;
    exit 1
  end;
  let f = open_in !ifile in 
  let buf = Lexing.from_channel f in
  try
    let _ = Parser.fichier Lexer.token buf in
    close_in f;
    exit 0
  with 
    | Lexer.Lexical_error c ->
        localisation (Lexing.lexeme_start_p buf);
        eprintf "lexical error: %s@." c;
        exit 1
    | Parsing.Parse_error ->
	      localisation (Lexing.lexeme_start_p buf);
	      eprintf "syntax error@.";
	      exit 1
    | e ->
        let bt = Printexc.get_backtrace () in
        eprintf "exception error: %s\n@." (Printexc.to_string e);
        eprintf "%s@." bt;
	      exit 2
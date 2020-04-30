(* FrontC analyse lexicale *)
(* Kelun Chai, Djbaer Solimani *)
{
  open Parser
  open Lexing

  exception EOF
  exception Lexical_error of string

  let char_error s = raise (Lexical_error ("Chaîne de caractère illégal: " ^ s))
  
  let kwd_tbl = [
      ("float",FLOAT); 
      ("int",INT);  
      ("struct",STRUCT);  
      ("void",VOID); 
      ("else",ELSE);
      ("for",FOR);
      ("if",IF);
      ("null",NULL);
      ("return",RETURN);
      ("while",WHILE);
      ]

  (* la fonction is_keyword détermine si un identificateur est un mot clé *)
  let is_keyword s = try List.assoc s kwd_tbl with _ -> IDENT(s)
}

let chiffre = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let commentaire = "//" [^ '\n']*
let ident = (alpha|'_') (alpha|'_'|chiffre)*
let entier = ['0'-'9']+
let space = [' ' '\t']
let newline = ('\n'|'\r'|"\r\n")
let exposant = ('e'|'E')('-'|'+')?chiffre+
let reel = chiffre+'.'chiffre* exposant?|chiffre*'.'chiffre+ exposant? |chiffre+ exposant

rule token = parse
    space+ { token lexbuf }
  | newline { Lexing.new_line lexbuf; token lexbuf }
  | "/*" { comment lexbuf }
  | commentaire { Lexing.new_line lexbuf; token lexbuf }
  | ident as s { is_keyword s }
  | entier as s{ ENTIER(int_of_string s) }
  | reel as s { REEL(float_of_string s)}
  | ';' {PV}
  | '='  {EGALE}
  | ',' {VIR}
  | '.' {POINT}
  | "{" {LACO}
  | "}" {RACO}
  | "[" {LCRO}
  | "]" {RCRO}
  | "(" {LPAR}
  | ")" {RPAR}
  | "->" {FLECHE}
  | '+' {PLUS}
  | '-' {MINU}
  | '*' {MULT}
  | '/' {DIV}
  | '%' {MOD}
  | "==" {EEGALE}
  | "!=" {NEGALE}
  | '<' {INF}
  | "<=" {INFEGL}
  | '>' {SUP}
  | ">=" {SUPEGL}
  | '&' {ADR}
  | "&&" {ET}
  | "||" {OU}
  | "++" {PPLUS}
  | "--" {MMINU}
  | _ {raise (Lexical_error ("Caractère illégal:[" ^ lexeme lexbuf ^ "]"))}
  | eof { EOF } 

and comment = parse
  | "*/" { token lexbuf }
  | _    { comment lexbuf }
  | eof  { raise (Lexical_error "Commentaire non terminé.") }
/* FrontC Parser */
/* Kelun Chai, Djbaer Solimani */

%token EOF
%token <string> IDENT
%token <int> ENTIER
%token <float> REEL
%token EGALE VIR PV LACO RACO LCRO RCRO LPAR RPAR
%token ELSE FLOAT FOR IF INT NULL RETURN STRUCT VOID WHILE
%token EEGALE NEGALE INF INFEGL SUP SUPEGL PLUS MINU MULT DIV MOD ET OU
%token NOT UNITPLUS UNITMINU PTR ADR PPLUS MMINU
%token POINT FLECHE

/* Operator precedence */
%nonassoc IF ELSE
%nonassoc TOP

/* Left and right prio */
%right EGALE
%left OU
%left ET
%left EEGALE NEGALE
%left INF INFEGL SUP SUPEGL
%left PLUS MINU
%left MULT DIV MOD
%right NOT PPLUS MMINU ADR PTR UNITPLUS UNITMINU
%left LPAR RPAR LCRO RCRO FLECHE POINT

%start fichier
/* type <Ast.fichier> fichier */
%type <unit> fichier

%%

fichier:
  | decl_option EOF {}
;

decl_option:
  | /* empty */ {  }
  | decl decl_option { }
;

decl:
  | decl_vars_init {  } 
  | decl_struct {  }
  | decl_fct {  }
;

decl_vars:
  | dtype vars PV {  }
  ;

decl_vars_init:
  | dtype vars_init PV { }
;

decl_struct:
  | STRUCT IDENT LACO decl_vars_option RACO PV { }
  ;
  decl_vars_option:
    | /* empty */ { }
    | decl_vars decl_vars_option { }
    ;

decl_fct:
  | dtype IDENT LPAR arg_option RPAR bloc { } /* int main () {} */
  | dtype IDENT PTR IDENT LPAR arg_option RPAR bloc { } /* struct xxx * xxx */
  ;
  /* On n'est plus besoin ptr_option */
  /* ptr_option:
    | { }
    | PTR ptr_option { }
    ; */
  arg_option:
    | /* empty */ {  }
    | arguments { }
    ;

dtype:
  | VOID { }
  | INT {  }
  | FLOAT {  }
  | STRUCT IDENT { }
;

arguments:
  | dtype var { }
  | dtype var VIR arguments { }
  ;

vars_init:
  | var init_option {  }
  | var init_option VIR vars_init {  }
;
  init_option:
    | /* empty */ { }
    | EGALE init { }
  ;

init:
  | expr { }
  | LACO RACO { }
  | LACO inits RACO { }
;

inits:
  | init { }
  | init VIR inits {  }
  ;

expr:
  | ENTIER {  }
  | REEL {  }
  | NULL {  }
  | IDENT { }
  | PTR expr {  }
  | expr LCRO expr RCRO { }
  | expr POINT IDENT { }
  | expr FLECHE IDENT {  }
  | expr EGALE expr { } 
  | IDENT LPAR l_expr_option RPAR {  }
  | PPLUS expr {  }
  | MMINU expr {  }
  | expr PPLUS {  }
  | expr MMINU {  }
  | ADR expr {  }
  | NOT expr {  }
  | MINU expr {  }
  | PLUS expr {  }
  | expr operateur expr {  } %prec TOP
  | LPAR expr RPAR {  }
;
  l_expr_option:
    | /* empty */ {  }
    | l_expr {  }
    ;

operateur:
  | EEGALE {  }
  | NEGALE { }
  | INF {  }
  | INFEGL {  }
  | SUP {  }
  | SUPEGL {  }
  | PLUS {  }
  | MINU {  }
  | MULT {  }
  | DIV {  }
  | MOD {  }
  | ET {  }
  | OU {  }
  ;

l_expr:
  | expr { }
  | expr VIR l_expr { }
  ;

var:
  | IDENT { }
  | PTR var { }
  | var LCRO ENTIER RCRO { }
;

vars:
  | var { }
  | var VIR vars { }
  ;

instruction:
  | PV {  }
  | expr PV {  }
  | IF LPAR expr RPAR instruction { }
  | IF LPAR expr RPAR instruction ELSE instruction {  }
  | WHILE LPAR expr RPAR instruction {  }
  | FOR LPAR l_expr_option PV expr_option PV l_expr_option RPAR instruction { }
  | bloc {  }
  | RETURN expr_option PV { }
  ;
  expr_option:
    | /* empty */ {  }
    | expr {  }
    ;

bloc:
  | LACO decl_vars_init_option inst_option RACO {  }
  ;
  inst_option:
    | /* empty */ { }
    | instruction inst_option { }
  ;
  decl_vars_init_option:
    | /* empty */ { }
    | decl_vars_init decl_vars_init_option {  }
    ;
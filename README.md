## FrontC in OCaml

Kelun Chai

#### Installation

make

#### Test
`./frontc [testfile]`

#### Implemented functions

- Lexical Analyze (lexer.mll) ✓
- Syntax analysis (parser.mly) ✓
- Error localization (main.ml) ✓

#### Result

| Test_correc                         | Resulta  |
| ----------------------------------- | -------- |
| testfile-binop14                    | ✓        |
| testfile-binop17                    | ✓        |
| testfile-binop18                    | ✓        |
| testfile-commentaire1               | ✓        |
| testfile-constantes2                | ✓        |
| testfile-constantes6                | ✓        |
| testfile-constantes11               | ✓        |
| testfile-identificateurs3           | ✓        |
| testfile-identificateurs8           | ✓        |
| `int main() { return 0; }` (test.c) | ✓        |

| Test_bad                | Result   | Message                                                      |
| ----------------------- | -------- | ------------------------------------------------------------ |
| testfile-char7          | ✓        | `File "tests-lex-yacc/mauvais/testfile-char7.c", line 2, characters 0-1:<br/>lexical error: Caractère illégal:[']`<br />`'` ' (0-1) |
| testfile-char8          | ✓        | `File "tests-lex-yacc/mauvais/testfile-char8.c", line 2, characters 0-1:<br/>lexical error: Caractère illégal:["]`<br />`"` " (0-1) |
| testfile-commentaires3  | ✓        | `File "tests-lex-yacc/mauvais/testfile-commentaires3.c", line 4, characters 0-1:<br/>syntax error`<br /><br />`// /*`<br />`toto;`<br />`*`/ (0-1) |
| testfile-commentaires4  | ✓        | `File "tests-lex-yacc/mauvais/testfile-commentaires4.c", line 3, characters 17-18:<br/>lexical error: Commentaire non terminé.`<br /><br />/* non terminé` ` (17-18) |
| testfile-decl_vars5     | ✓        | `File "tests-lex-yacc/mauvais/testfile-decl_vars5.c", line 2, characters 4-5:<br/>syntax error`<br /><br />int ` `; (4-5) |
| testfile-decl_vars6     | ✓        | `File "tests-lex-yacc/mauvais/testfile-decl_vars6.c", line 2, characters 8-9:<br/>syntax error`<br /><br />int a ; `b` ; (8-9) |
| testfile-decl_vars8     | ✓        | `File "tests-lex-yacc/mauvais/testfile-decl_vars8.c", line 2, characters 12-13:<br/>syntax error`<br /><br />int a = 1 , `1` ; (12-13) |
| testfile-decl_vars9     | ✓        | `File "tests-lex-yacc/mauvais/testfile-decl_vars9.c", line 2, characters 12-13:<br/>syntax error`<br /><br />int a = 1 , `i`nt b = 2 ; (12-13) |
| testfile-expressions1   | ✓        | `File "tests-lex-yacc/mauvais/testfile-expressions1.c", line 1, characters 9-10:<br/>syntax error`<br /><br />int a=1+`+`1; (9-10) |
| testfile-expressions4   | ✓        | `File "tests-lex-yacc/mauvais/testfile-expressions4.c", line 2, characters 6-7:<br/>syntax error`<br /><br />int a=`.`e1 (6-7) |
| testfile-expressions7   | ✓        | `File "tests-lex-yacc/mauvais/testfile-expressions7.c", line 2, characters 6-7:<br/>syntax error`<br /><br />int a=`i`nt; (6-7) |
| testfile-functions1     | ✓        | `File "tests-lex-yacc/mauvais/testfile-functions1.c", line 1, characters 10-11:<br/>syntax error`<br /><br />void f(){}`;` (10-11) |
| testfile-functions3     | ✓        | `File "tests-lex-yacc/mauvais/testfile-functions3.c", line 2, characters 7-8:<br/>syntax error`<br /><br />void f `{`} (7-8) |
| testfile-instructions2  | ✓        | `File "tests-lex-yacc/mauvais/testfile-instructions2.c", line 3, characters 5-6:<br/>syntax error`<br /><br /> __if` ` 1 ; (5-6) |
| testfile-instructions8  | ✓        | `File "tests-lex-yacc/mauvais/testfile-instructions8.c", line 4, characters 0-1:<br/>syntax error`<br /><br />`}` (0-1) |
| testfile-instructions10 | ✓        | `File "tests-lex-yacc/mauvais/testfile-instructions10.c", line 3, characters 9-10:<br/>syntax error`<br /><br />__while (`)` ; (9-10) |
| testfile-structures1    | ✓        | `File "tests-lex-yacc/mauvais/testfile-structures1.c", line 2, characters 0-1:<br/>syntax error`<br /><br />` ` (0-1, expected a  `;`) |
| testfile-structures2    | ✓        | `File "tests-lex-yacc/mauvais/testfile-structures2.c", line 2, characters 36-37:<br/>syntax error` |

#### Problems and solutions

1. Parser ✓ 

   At the beginning, we encountered 20 shift/reduce conflicts. I found that the problem is on the `expr` rule. Using `% prec`, then I solved 19 conflicts.
   There is a conflict on the `if (expr) inst else inst` rule.
   I set the priority of `IF ELSE` as `% non-assoc` and we solved the problem.

2. Lexer ✓ 

   I wrote a `newline' function that locates the line number, but it's not very correct. 

   ```ocaml
   let newline lexbuf =
   	let pos = lexbuf.lex_curr_p in
   	lexbuf.lex_curr_p <-
   		{ pos with pos_lnum = pos.pos_lnum + 1; 
             pos_bol = pos.pos_cnum;
             pos_cnum=0 }
   ```

   Finally, I used the built-in function `Lexing.new_line lexbuf;` 

3. Error localization ✓

   In order to be able to locate errors, I define the ident data structure as: `{id: string; id_loc: loc}`,où`type loc = {fr_start:Lexing.position; fr_end:Lexing.position}` and I get the position of the character with both functions:

   ```ocaml
   (* Gets the file range corresponding to the current parser "symbol". *)
   let symbol_range () = {
   	fr_start = Parsing.symbol_start_pos ();
       fr_end   = Parsing.symbol_end_pos ();
   }
    (* Gets the file range corresponding to the specified matching symbol on the right-hand side of the current rule (indexed from 1). *)
   let rhs_range n = {
   	fr_start = Parsing.rhs_start_pos n;
       fr_end   = Parsing.rhs_end_pos n;
   }
   ```

   But then, using the built-in `Parsing.Parse_error` function, I don't need those functions anymore.

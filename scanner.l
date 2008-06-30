%{

/* scanner.l
 * 
 * Lexical Analyser for the JavaScript Language
 *
 * Part III Project at University of Southampton, UK
 * Alex Walker - javascript@soton.net
 *
 * Created 971120
 */

#include "header.h"
#include "y.tab.h"
#include <stdio.h>

/* SW is a macro to save the current token to a buffer
 * We may use it later for error reporting.
 */

#define SW save_word(yytext)

void add_var(void);
void reserved_word(void);
void report_symbol_table(void);
void save_word(char *);

int comment = FALSE;

%}

cpp_style_comment	"//".*
delimiter       	[ \t\f\r]
whitespace      	{delimiter}+
letter          	[a-z]|[A-Z]
line_terminator		[\n]

digit			[0-9]
hex_digit		[a-f]|[A-F]|{digit}
octal_digit		[0-7]
decimal_number		(({digit}+)|({digit}*\.{digit}+)([eE][-+]?{digit}+)?)
hex_number		("0x"|"0X"){hex_digit}+
octal_number		"0"{octal_digit}+
number			{decimal_number}|{hex_number}|{octal_number}

single_escape_char	['"\\bfnrt]
escape_character	[xu]|{single_escape_character}|{octal_digit}
non_escape_char		[^\n\rxu'"\\bfnrt0-7]
character_es		\\({single_escape_char}|{non_escape_char})
escape_sequence		{character_es}
ds_chars		[^\\"\n\r]
ss_chars		[^\\'\n\r]
double_string		\"({ds_chars}|{escape_sequence})*\"
single_string		\'({ss_chars}|{escape_sequence})*\'
string			{double_string}|{single_string}

variable_symbol		[_$]
variable        	({letter}|{variable_symbol})({letter}|{variable_symbol}|{digit})*

%%

%{
/* Handle C Style comments */
%}

"/*"		{ comment = TRUE ; }
"*/"		{ comment = FALSE ; }

%{
/* Punctuators */
%}

"?"		{ SW; if (comment == FALSE) return QUERY ; }
":"		{ SW; if (comment == FALSE) return COLON ; }
"!="		{ SW; if (comment == FALSE) return NOT_EQUAL ; }
">="		{ SW; if (comment == FALSE) return GT_EQUAL ; }
"<="		{ SW; if (comment == FALSE) return LS_EQUAL ; }
"=="		{ SW; if (comment == FALSE) return EQUALS ; }
">"		{ SW; if (comment == FALSE) return GREATER_THAN ; }
"<"		{ SW; if (comment == FALSE) return LESS_THAN ; }
"="             { SW; if (comment == FALSE) return ASSIGN_SYMBOL ; }
"&&"		{ SW; if (comment == FALSE) return LOGICAL_AND ; }
"||"		{ SW; if (comment == FALSE) return LOGICAL_OR ; }
"!"		{ SW; if (comment == FALSE) return LOGICAL_NOT ; }
"&"		{ SW; if (comment == FALSE) return BITWISE_AND ; }
"|"		{ SW; if (comment == FALSE) return BITWISE_OR ; }
"<<"		{ SW; if (comment == FALSE) return BITWISE_SHIFT_LEFT ; }
">>"		{ SW; if (comment == FALSE) return BITWISE_SHIFT_RIGHT ; }
">>>"		{ SW; if (comment == FALSE) return BITWISE_SHIFT_RIGHT_ZERO_FILL ; }
"~"		{ SW; if (comment == FALSE) return ONES_COMPLIMENT ; }
"--"		{ SW; if (comment == FALSE) return DECREMENT ; }
"++"		{ SW; if (comment == FALSE) return INCREMENT ; }
"+="		{ SW; if (comment == FALSE) return PLUS_EQUALS ; }
"-="		{ SW; if (comment == FALSE) return MINUS_EQUALS ; }
"*="		{ SW; if (comment == FALSE) return MULTIPLY_EQUALS ; }
"/="		{ SW; if (comment == FALSE) return DIV_EQUALS ; }
"%="		{ SW; if (comment == FALSE) return MOD_EQUALS ; }
"&="		{ SW; if (comment == FALSE) return BITWISE_AND_EQUALS ; }
"|="		{ SW; if (comment == FALSE) return BITWISE_OR_EQUALS ; }
"^"		{ SW; if (comment == FALSE) return BITWISE_EXCLUSIVE_OR ; }
"^="		{ SW; if (comment == FALSE) return BITWISE_EXCLUSIVE_OR_EQUALS ; }
"<<="		{ SW; if (comment == FALSE) return BITWISE_SHIFT_LEFT_EQUALS ; }
">>="		{ SW; if (comment == FALSE) return BITWISE_SHIFT_RIGHT_EQUALS ; }
">>>="		{ SW; if (comment == FALSE) return BITWISE_SHIFT_RIGHT_ZERO_FILL_EQUALS ; }
";"		{ SW; if (comment == FALSE) return SEMICOLON ; }
"."		{ SW; if (comment == FALSE) return DOT ; }
","		{ SW; if (comment == FALSE) return COMMA ; }
"{"		{ SW; if (comment == FALSE) return START_BLOCK ; }
"}"		{ SW; if (comment == FALSE) return END_BLOCK ; }
"("		{ SW; if (comment == FALSE) return OPEN_PARENTHESIS ; }
")"		{ SW; if (comment == FALSE) return CLOSE_PARENTHESIS ; }
"["		{ SW; if (comment == FALSE) return OPEN_SQ_BRACKETS ; }
"]"		{ SW; if (comment == FALSE) return CLOSE_SQ_BRACKETS ; }
"+"		{ SW; if (comment == FALSE) return PLUS ; }
"-"		{ SW; if (comment == FALSE) return MINUS ; }
"/"		{ SW; if (comment == FALSE) return DIV ; }
"%"		{ SW; if (comment == FALSE) return MOD ; }
"*"		{ SW; if (comment == FALSE) return MULTIPLY ; }

%{
/* Keywords of the JavaScript Language */
%}

false		{ SW; if (comment == FALSE) return FALSE ; }
true		{ SW; if (comment == FALSE) return TRUE ; }
null		{ SW; if (comment == FALSE) return NULL_TOKEN ; }
undefined	{ SW; if (comment == FALSE) return UNDEFINED_TOKEN ; }
Infinity	{ SW; if (comment == FALSE) return INFINITY ; }

break		{ SW; if (comment == FALSE) return BREAK ; }
continue	{ SW; if (comment == FALSE) return CONTINUE ; }
delete		{ SW; if (comment == FALSE) return DELETE ; }
else		{ SW; if (comment == FALSE) return ELSE ; }
for		{ SW; if (comment == FALSE) return FOR ; }
function	{ SW; if (comment == FALSE) return FUNCTION ; }
if		{ SW; if (comment == FALSE) return IF ; }
in		{ SW; if (comment == FALSE) return IN ; }
new		{ SW; if (comment == FALSE) return NEW ; }
return		{ SW; if (comment == FALSE) return RETURN ; }
this		{ SW; if (comment == FALSE) return THIS ; }
typeof		{ SW; if (comment == FALSE) return TYPEOF ; }
var		{ SW; if (comment == FALSE) return VAR ; }
void		{ SW; if (comment == FALSE) return VOID_SYMBOL ; }
while		{ SW; if (comment == FALSE) return WHILE ; }
with		{ SW; if (comment == FALSE) return WITH ; }

%{
/* Officially defined reserved words for future use in JavaScript Language */
%}

case		{ SW; reserved_word(); }
catch		{ SW; reserved_word(); }
class		{ SW; reserved_word(); }
const		{ SW; reserved_word(); }
debugger	{ SW; reserved_word(); }
do		{ SW; reserved_word(); }
enum		{ SW; reserved_word(); }
export		{ SW; reserved_word(); }
extends		{ SW; reserved_word(); }
finally		{ SW; reserved_word(); }
import		{ SW; reserved_word(); }
super		{ SW; reserved_word(); }
switch		{ SW; reserved_word(); }
throw		{ SW; reserved_word(); }
try		{ SW; reserved_word(); }

%{
/* Other rules */
%}

REPORT			{	/* REPORT Command - Used for testing */
	
				report_symbol_table();
			}

{line_terminator}	{
				report_errors();
				current_line++;
				lineptr = linebuf;
/*				if (comment == FALSE) return LINE_TERMINATOR; */
			}

{variable}     		{	if (comment == FALSE) {
					SW;
					add_var();
					return VARIABLE ;
				}
			}

{cpp_style_comment}	{	/* Ignore comments */
			}

{whitespace}    	{
				SW;
			}

{number}        	{	/* Not interested in the value, just return the token */
				SW; if (comment == FALSE) return NUMBER ;
			}

{string}          	{	/* Not interested in the value, just return the token */
				SW; if (comment == FALSE) return STRING ;
			}

.               	{	/* Ought to deal with unrecognised single characters here */
				SW; if (comment == FALSE) return yytext[0] ;
			}

%%

void add_var() {

	/* Looks to see if a variable is in the symbol table, 
	   and adds a new entry if required */

	/* Declare temporary variables */
	SYMB *t;
	char *s;

	/* If variable is already in symbol table, return pointer to it */
	if ((t = lookup(yytext)) != NULL) {
		yylval.symb = t;
		return;
	}

	/* If not, make a new entry */

	/* Copy the name of the variable */
	s = (char *)safe_malloc(yyleng +1);
	strncpy(s, yytext, yyleng);
	s[yyleng] = 0;

	/* Make a new entry, and initialise it */
	t = get_symb();

	t->type = T_UNDECLARED;
	t->name = s;
	t->predefined = NO;

	/* Insert it into the symbol table */
	insert(t);

	/* Place this value in yylval where parser can find it */
	yylval.symb = t;	
}

void reserved_word() {

	/* Displays a warning message when a reserved word is used */

	printf("Line %d:\nError: \"%s\" is a future reserved word, and should not be used\n", current_line, yytext);
	exit(1);
}

void save_word(char *s) {

	strcpy(lineptr,s);
	lineptr += strlen(s);
}

void report_symbol_table() {

	/* Displays textually the Symbol Table */

	SYMB *temp = symboltable;

	printf("Symbol Table is: \n");

	if (temp == NULL) printf("\tEMPTY\n");

	while (temp != NULL) {

		if (temp->predefined == YES) {
			temp = temp->link;
			continue;
		}

		printf("\tName: %s\n", temp->name);
		switch(temp->type) {
			case T_UNDECLARED:
				printf("\tType: UNDECLARED\n");
				break;

			case T_UNDEFINED:
				printf("\tType: UNDEFINED\n");
				break;
			case T_NULL:
				printf("\tType: NULL\n");
				break;
			case T_OBJECT:
				printf("\tType: OBJECT\n");
				break;
			case T_STRING:
				printf("\tType: STRING\n");
				break;
			case T_NUMBER:
				printf("\tType: NUMBER\n");
				break;
			case T_BOOLEAN:
				printf("\tType: BOOLEAN\n");
				break;
			case T_FUNCTION:
				printf("\tType: FUNCTION\n");
				break;
			default:
				printf("\tType: Unknown type!\n");
		}
		printf("\n");
		temp = temp->link;
	}
}

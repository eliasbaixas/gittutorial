%{

/* Parser.y
 * 
 * Grammer for the JavaScript Language
 *
 * Part III Project at University of Southampton, UK
 * Alex Walker - javascript@soton.net
 *
 * Created 980129
 */

#include "header.h"
#include <stdio.h>

void error(int, char *msg);
void report_errors();

%}

%{

/* Now follows all JavaScript keywords, reserved words, etc.
 * These are all to be defined as tokens.
 * If yacc is called with the -d flag, y.tab.h is generated
 * to include these tokens. This file is then #include'd
 * by the lexer.
 */

%}

%union
{
	SYMB *symb;
}

%token ASSIGN_SYMBOL 
%token BITWISE_AND 
%token BITWISE_AND_EQUALS 
%token BITWISE_EXCLUSIVE_OR 
%token BITWISE_EXCLUSIVE_OR_EQUALS 
%token BITWISE_OR 
%token BITWISE_OR_EQUALS 
%token BITWISE_SHIFT_LEFT 
%token BITWISE_SHIFT_LEFT_EQUALS 
%token BITWISE_SHIFT_RIGHT 
%token BITWISE_SHIFT_RIGHT_EQUALS 
%token BITWISE_SHIFT_RIGHT_ZERO_FILL 
%token BITWISE_SHIFT_RIGHT_ZERO_FILL_EQUALS 
%token BREAK 
%token CLOSE_PARENTHESIS 
%token CLOSE_SQ_BRACKETS 
%token COLON 
%token COMMA  
%token CONTINUE 
%token DECREMENT 
%token DELETE 
%token DIV 
%token DIV_EQUALS 
%token DOT 
%token ELSE 
%token END_BLOCK 
%token EQUALS 
%token FALSE 
%token FOR 
%token FUNCTION  
%token GREATER_THAN 
%token GT_EQUAL 
%token IF 
%token INCREMENT 
%token INFINITY
%token IN 
%token LESS_THAN 
%token LINE_TERMINATOR
%token LOGICAL_AND 
%token LOGICAL_OR 
%token LOGICAL_NOT 
%token LS_EQUAL 
%token MINUS 
%token MINUS_EQUALS 
%token MOD 
%token MOD_EQUALS 
%token MULTIPLY 
%token MULTIPLY_EQUALS 
%token NEW 
%token NOT_EQUAL 
%token NULL_TOKEN
%token NUMBER
%token ONES_COMPLIMENT 
%token OPEN_PARENTHESIS 
%token OPEN_SQ_BRACKETS 
%token PLUS 
%token PLUS_EQUALS 
%token QUERY 
%token RETURN 
%token SEMICOLON 
%token START_BLOCK 
%token STRING
%token THIS 
%token TRUE 
%token TYPEOF 
%token UNDEFINED_TOKEN
%token VAR 
%token <symb> VARIABLE
%token VOID_SYMBOL
%token WHILE 
%token WITH 

%left PLUS MINUS
%left MULTIPLY DIV MOD

%nonassoc FALSE
%nonassoc HIGHER_THAN_FALSE
%nonassoc ELSE

%nonassoc LOWER_THAN_CLOSE_PARENTHESIS
%nonassoc CLOSE_PARENTHESIS

%%

Program				:	SourceElements
				;

SourceElements			:	SourceElement
				|	SourceElements SourceElement
				;

SourceElement			:	Statement
				|	FunctionDeclaration
				;

Statement			:	Block
				|	VariableStatement
				|	EmptyStatement
				|	ExpressionStatement
				|	IfStatement
				|	IterationExpression
				|	ContinueStatement
				|	BreakStatement
				|	ReturnStatement
				|	WithStatement
				;

FunctionDeclaration		:	FUNCTION VARIABLE OPEN_PARENTHESIS FormalParameterList CLOSE_PARENTHESIS Block
				{
					if ($2->type == T_FUNCTION) {
						error(ERROR, "Function with this name is already declared.");
					} else if ($2->type != T_UNDECLARED) {
						error(ERROR, "Function name is already in use as a variable.");
					} else {
						$2->type = T_FUNCTION;
					}
				}
				|	FUNCTION VARIABLE OPEN_PARENTHESIS CLOSE_PARENTHESIS Block
				{
					if ($2->type == T_FUNCTION) {
						error(ERROR, "Function with this name is already declared.");
					} else if ($2->type != T_UNDECLARED) {
						error(ERROR, "Function name is already in use as a variable.");
					} else{
						$2->type = T_FUNCTION;
					}
				}
				;

FormalParameterList		:	VARIABLE
				|	FormalParameterList COMMA VARIABLE
				;

StatementList			:	Statement
				|	StatementList Statement
				;

Block				:	START_BLOCK StatementList END_BLOCK;
				|	START_BLOCK END_BLOCK
				;

VariableStatement		:	VAR VariableDeclarationList SEMICOLON
				;

EmptyStatement			:	SEMICOLON
				;

ExpressionStatement		:	Expression SEMICOLON
				;

IfStatement			:	IF OPEN_PARENTHESIS Expression CLOSE_PARENTHESIS Statement	%prec HIGHER_THAN_FALSE
				|	IF OPEN_PARENTHESIS Expression CLOSE_PARENTHESIS Statement ELSE Statement
				|	IF OPEN_PARENTHESIS FALSE CLOSE_PARENTHESIS Statement
				{
					error(ERROR, "Unreachable code portion");
				}
				|	IF OPEN_PARENTHESIS LeftHandSideExpression AssignmentOperator AssignmentExpression CLOSE_PARENTHESIS Statement
				{
					error(WARNING, "Possible error in IF Expression (e.g. a=b instead of a==b)");
				}
				;

IterationExpression		:	WHILE OPEN_PARENTHESIS Expression CLOSE_PARENTHESIS Statement %prec HIGHER_THAN_FALSE
				|	WHILE OPEN_PARENTHESIS FALSE CLOSE_PARENTHESIS Statement
				{
					error(ERROR, "Unreachable code portion");
				}
				|	WHILE OPEN_PARENTHESIS LeftHandSideExpression AssignmentOperator AssignmentExpression CLOSE_PARENTHESIS Statement
				{
					error(WARNING, "Possible error in WHILE Expression (e.g. a=b instead of a==b)");
				}
				|	FOR OPEN_PARENTHESIS OptionalExpression SEMICOLON OptionalExpression SEMICOLON OptionalExpression CLOSE_PARENTHESIS Statement
				|	FOR OPEN_PARENTHESIS VAR VariableDeclarationList SEMICOLON OptionalExpression SEMICOLON OptionalExpression CLOSE_PARENTHESIS Statement
				|	FOR OPEN_PARENTHESIS LeftHandSideExpression IN Expression CLOSE_PARENTHESIS Statement
				|	FOR OPEN_PARENTHESIS VAR VARIABLE OptionalInitializer IN Expression CLOSE_PARENTHESIS Statement
				;

ContinueStatement		:	CONTINUE SEMICOLON
				;

BreakStatement			:	BREAK SEMICOLON
				;

ReturnStatement			:	RETURN Expression SEMICOLON
				|	RETURN SEMICOLON
				;

WithStatement			:	WITH OPEN_PARENTHESIS Expression CLOSE_PARENTHESIS Statement
				;

VariableDeclarationList		:	VariableDeclaration
				|	VariableDeclarationList COMMA VariableDeclaration
				;

VariableDeclaration		:	VARIABLE
				{
					if ($1->type == T_FUNCTION) {
						error(ERROR, "Variable given same name as an existing function.");
					} else $1->type = T_UNDEFINED;
				}
				|	VARIABLE Initializer
				{
					if ($1->type == T_FUNCTION) {
						error(ERROR, "Variable given same name as an existing function.");
					} else $1->type = T_UNDEFINED;
				}
				;

Initializer			:	ASSIGN_SYMBOL AssignmentExpression
				;

OptionalInitializer		:	Initializer
				|
				;

PrimaryExpression		:	THIS
				|	VARIABLE
				{
					if (($1->type == T_UNDECLARED) && (undeclared_flag == 1)) {
						error(WARNING, "Possible use of undeclared variable");
					}
				}
				|	NUMBER
				|	STRING
				|	NULL_TOKEN
				|	TRUE
				|	FALSE
				|	OPEN_PARENTHESIS Expression CLOSE_PARENTHESIS
				;

MemberExpression		:	PrimaryExpression	
				|	MemberExpression OPEN_SQ_BRACKETS Expression CLOSE_SQ_BRACKETS
				|	MemberExpression DOT VARIABLE
				|	NEW MemberExpression Arguments
				;

NewExpression			:	MemberExpression
				|	NEW NewExpression
				;

CallExpression			:	MemberExpression Arguments
				|	CallExpression Arguments
				|	CallExpression OPEN_SQ_BRACKETS Expression CLOSE_SQ_BRACKETS
				|	CallExpression DOT VARIABLE
				;

Arguments			:	OPEN_PARENTHESIS CLOSE_PARENTHESIS
				|	OPEN_PARENTHESIS ArgumentList CLOSE_PARENTHESIS
				;

ArgumentList			:	AssignmentExpression
				|	ArgumentList COMMA AssignmentExpression
				;

LeftHandSideExpression		:	NewExpression
				|	CallExpression
				;

PostfixExpression		:	LeftHandSideExpression
				|	LeftHandSideExpression INCREMENT
				|	LeftHandSideExpression DECREMENT
				;

UnaryExpression			:	PostfixExpression
				|	DELETE UnaryExpression
				|	VOID_SYMBOL UnaryExpression
				|	TYPEOF UnaryExpression
				|	INCREMENT UnaryExpression
				|	DECREMENT UnaryExpression
				|	PLUS UnaryExpression
				|	MINUS UnaryExpression
				|	ONES_COMPLIMENT UnaryExpression
				|	LOGICAL_NOT UnaryExpression
				;

MultiplicativeExpression	:	UnaryExpression
				|	MultiplicativeExpression MULTIPLY UnaryExpression
				|	MultiplicativeExpression DIV UnaryExpression
				|	MultiplicativeExpression MOD UnaryExpression
				;

AdditiveExpression		:	MultiplicativeExpression
				|	AdditiveExpression PLUS MultiplicativeExpression
				|	AdditiveExpression MINUS MultiplicativeExpression
				;

ShiftExpression			:	AdditiveExpression
				|	ShiftExpression BITWISE_SHIFT_LEFT AdditiveExpression
				|	ShiftExpression BITWISE_SHIFT_RIGHT AdditiveExpression
				|	ShiftExpression BITWISE_SHIFT_RIGHT_ZERO_FILL AdditiveExpression
				;

RelationalExpression		:	ShiftExpression
				|	RelationalExpression LESS_THAN ShiftExpression
				|	RelationalExpression GREATER_THAN ShiftExpression
				|	RelationalExpression LS_EQUAL ShiftExpression
				|	RelationalExpression GT_EQUAL ShiftExpression
				;

EqualityExpression		:	RelationalExpression
				|	EqualityExpression EQUALS RelationalExpression
				|	EqualityExpression NOT_EQUAL RelationalExpression
				;

BitwiseANDExpression		:	EqualityExpression
				|	BitwiseANDExpression BITWISE_AND EqualityExpression
				;

BitwiseXORExpression		:	BitwiseANDExpression
				|	BitwiseXORExpression BITWISE_EXCLUSIVE_OR BitwiseANDExpression
				;

BitwiseORExpression		:	BitwiseXORExpression
				|	BitwiseORExpression BITWISE_OR BitwiseXORExpression
				;

LogicalANDExpression		:	BitwiseORExpression
				|	LogicalANDExpression LOGICAL_AND BitwiseORExpression
				;

LogicalORExpression		:	LogicalANDExpression
				|	LogicalORExpression LOGICAL_OR LogicalANDExpression
				;

ConditionalExpression		:	LogicalORExpression
				|	LogicalORExpression QUERY AssignmentExpression COLON AssignmentExpression
				;

AssignmentExpression		:	ConditionalExpression
				|	LeftHandSideExpression AssignmentOperator AssignmentExpression %prec LOWER_THAN_CLOSE_PARENTHESIS
				;

AssignmentOperator		:	ASSIGN_SYMBOL
				|	MULTIPLY_EQUALS
				|	DIV_EQUALS
				|	MOD_EQUALS
				|	PLUS_EQUALS
				|	MINUS_EQUALS
				|	BITWISE_SHIFT_LEFT_EQUALS
				|	BITWISE_SHIFT_RIGHT_EQUALS
				|	BITWISE_SHIFT_RIGHT_ZERO_FILL_EQUALS
				|	BITWISE_AND_EQUALS
				|	BITWISE_EXCLUSIVE_OR_EQUALS
				|	BITWISE_OR_EQUALS
				;

Expression			:	AssignmentExpression
				|	Expression COMMA AssignmentExpression
				;

OptionalExpression		:	Expression
				|
				;

%%

yyerror(s) char *s; {

	error(ERROR, s);
}

void report_errors() {

	ERRMSG *temp = errorlist;
	ERRMSG *prev;
	int i = 0;

	while (temp != NULL) {

		/* Increment counters */

		if (temp->type == ERROR) {
			numerrors++;
                        if (!errors_flag) {
				prev = temp;
				temp = temp->link;
				free(prev);
				continue;
			}
		}
		if (temp->type == WARNING) {
			numwarnings++;
			if (!warnings_flag || !errors_flag) {
				prev = temp;
				temp = temp->link;
				free(prev);
				continue;
			}
		}

		/* Print line number */
		fprintf(stdout, "\nLine %d:\n", temp->lineno);

		/* Print original code */
		fprintf(stdout, "%s\n", linebuf);

		/* Print arrow to point to offending token */
		for (i=0;i<temp->offset-1;i++) {
			if (linebuf[i] == '\t') {
				fprintf(stdout,"\t");
			}
			else {
				fprintf(stdout," ");
			}
		}
		fprintf(stdout,"^----- ");

		/* Print the type of error message */
		if (temp->type == ERROR) {
			fprintf(stdout, "Error: ");
		} else if (temp->type == WARNING) {
			fprintf(stdout, "Warning: ");
		}

		/* Print the error message */
		if (strcmp(temp->message,"syntax error")) {
			fprintf(stdout, "%s", temp->message);
		}
		else {
			fprintf(stdout, "Syntax Error");
		}
		fprintf(stdout, "\n\n");

		prev = temp;
		temp = temp->link;

		/* We're done with the old entry now, so free it up */
		free(prev);
	}

	/* Set error list to NULL */
	errorlist = NULL;
}


void error(int type, char *msg) {

        /* Adds an entry to the list of errors for this line of code */

        ERRMSG *e = (ERRMSG *)safe_malloc(sizeof(ERRMSG));
	ERRMSG *temp;

        /* Copy over the error message */
        e->message = (char *)safe_malloc(strlen(msg)+1);
        strcpy(e->message, msg);

	/* Record the line number */
        e->lineno = current_line;

	/* Record the position in the line of the error */
        e->offset = strlen(linebuf);
                         
	/* Record the error type */
	e->type = type;

	/* Set the link pointer to be NULL */
	e->link = NULL;

        /* Insert completed error structure into the error list */

	/* Handles when list is empty */
	if (errorlist == NULL) {
		errorlist = e;
		return;
	}

	/* Handles when list has one or more elements in it */
	temp = errorlist;
	while (1) {
		if (temp->link == NULL) {
			temp->link = e;
			return;
		}
		else temp = temp->link;
	}
}

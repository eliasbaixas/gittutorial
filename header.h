/*
 * header.h
 *
 * Header file
 *
 * Part III Project at University of Southampton, UK
 * Alex Walker - javascript@soton.net
 *
 * Created 980129
 *
 */

#include <stdio.h>

/*
 *  All predefined types in the JavaScript language
 */

#define T_UNDECLARED	0

#define T_UNDEFINED	1
#define T_NULL		2
#define T_OBJECT	3
#define T_STRING	4
#define T_NUMBER	5
#define T_BOOLEAN	6
#define T_FUNCTION	7

/*
 *  Maximum line length (for reporting errors)
 */

#define MAX_LINE_LENGTH 500

/*
 * Define error types
 */

#define WARNING 0
#define ERROR	1

/*
 * Other definitions
 */

#define YES	1
#define NO	0

/*
 *  The data structure for the symbol table
 */

typedef struct symb {

	int type;
	int predefined;
	char *name;
	struct symb *link;

} SYMB;

/*
 * Data structure for the error message list
 */

typedef struct errmsg {

	int lineno;
	int offset;
	int type;
	char * message;
	struct errmsg *link;

} ERRMSG;

extern ERRMSG *errorlist;
extern SYMB *symboltable;
extern int current_line;
extern char linebuf[];
extern char * lineptr;
extern int numerrors;
extern int numwarnings;

extern int errors_flag;
extern int warnings_flag;
extern int undeclared_flag;
extern int portability_flag;

extern void  insert(SYMB *s);
extern SYMB *lookup(char *s);
extern SYMB *get_symb();

extern void * safe_malloc(size_t n);
extern char * LAST_COMPILED_DATE;

extern FILE *yyin;

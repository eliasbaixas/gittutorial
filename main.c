/* main.c
 * 
 * Main C Code
 *
 * Part III Project at University of Southampton, UK
 * Alex Walker - javascript@soton.net
 *
 * Created 980129
 */

#include "header.h"
#include "y.tab.h"
#include <stdio.h>


/* Prototypes of functions defined in this file */

void  insert(SYMB *);
SYMB *lookup(char *);
void *safe_malloc(size_t );
void do_start();
void do_commandline(int, char **);
void do_predefined();
void add_predefined(char *, int p_type);
void show_usage();

/* Some declarations */

FILE 	*file, *yyin;
SYMB 	*symboltable;
ERRMSG 	*errorlist;
int 	current_line;
int 	numerrors	= 0;
int 	numwarnings	= 0;
char 	linebuf[MAX_LINE_LENGTH];
char 	*lineptr;
char	*filename;

/* Flags */

int warnings_flag	= 1;
int errors_flag		= 1;
int undeclared_flag	= 0;
int portability_flag	= 0;

void main(int argc, char *argv[]) {

	/* Initialise some variables */
	symboltable = NULL;
	current_line = 1;
	lineptr = linebuf;

	/* Process any command line arguments */
	do_commandline(argc, argv);

	/* Display the welcome screen */
	do_start();

	/* Open any requested file */
	if (filename != NULL) {
		file = fopen(filename, "r");
		if (!file) {
			fprintf(stderr,"jsparse: Could not open file requested file \"%s\"\n", filename);
			exit(1);
		}
		/* yyin is the file handle for yacc */
		yyin = file;
	}

	/* Build in predefined symbols */
	do_predefined();

	/* Start parsing */
	do {
		yyparse();
	}
	while (!feof(yyin));

	current_line--;

	/* Report any unreported errors if we received at least one line of code */
	if (current_line > 0) {
		report_errors();
	}

	/* Display summary statistics */

	printf("\n%d line", current_line);
	if (current_line != 1) printf("s");
	printf(" processed. %d Error", numerrors);
	if (numerrors != 1) printf("s");
	printf(", ");

/*	if (warnings_flag || !(warnings_flag || errors_flag)) {*/
	if (warnings_flag) {
		printf("%d Warning", numwarnings);
		if (numwarnings != 1) printf("s");
		printf(".\n\n");
	} else {
		printf("Warnings disabled.\n\n");
	}
}

void * safe_malloc(size_t n) {

	void *t = (void *) malloc(n);

	if (t == NULL) {
		printf("\n\nmalloc() failed!\n\n");
		exit(0);
	}
	return t;
}

SYMB *get_symb() {

	return (SYMB *)safe_malloc(sizeof(SYMB));
}

void insert(SYMB *s) {

	/* Inserts an entry into the symbol table */

	if (symboltable != NULL) {
		s->link = symboltable;
	}
	symboltable = s;
}

SYMB *lookup(char *s) {

	/* Looks for an entry of name s in the symbol table.
           If it exists, it returns a pointer to it */

	SYMB *temp = symboltable;

	while (temp != NULL) {
		if (strcmp(s,temp->name) == 0) return temp;
		temp = temp->link;
	}

	return NULL;
}

void do_predefined() {

	/* Adds navigator predefined objects functions and variables into the symbol table */

	/* Navigator (non-ECMAScript) entries */

	add_predefined("navigator",	T_OBJECT);
	add_predefined("document",	T_OBJECT);
	add_predefined("self",		T_OBJECT);
	add_predefined("parent",	T_OBJECT);
	add_predefined("window",	T_OBJECT);

	add_predefined("alert",		T_FUNCTION);
	add_predefined("prompt",	T_FUNCTION);
	add_predefined("confirm",	T_FUNCTION);
	add_predefined("write",		T_FUNCTION);
	add_predefined("writeln",	T_FUNCTION);
	add_predefined("setTimeout",	T_FUNCTION);
	add_predefined("clearTimeout",	T_FUNCTION);

	/* ECMAScript functions and constructors */

	add_predefined("eval",		T_FUNCTION);
	add_predefined("parseInt",	T_FUNCTION);
	add_predefined("parseFloat",	T_FUNCTION);
	add_predefined("escape",	T_FUNCTION);
	add_predefined("unescape",	T_FUNCTION);
	add_predefined("isNaN",		T_FUNCTION);
	add_predefined("isFinite",	T_FUNCTION);
	add_predefined("Object",	T_FUNCTION);
	add_predefined("Function",	T_FUNCTION);
	add_predefined("Array",		T_FUNCTION);
	add_predefined("String",	T_FUNCTION);
	add_predefined("Boolean",	T_FUNCTION);
	add_predefined("Number",	T_FUNCTION);
	add_predefined("Date",		T_FUNCTION);

	/* ECMAScript objects */

	add_predefined("Math",		T_OBJECT);
}

void add_predefined(char *name, int p_type) {

	/* Declare temporary variables */
	SYMB *t;
	char *s;

	/* Copy the name of the variable */
	s = (char *)safe_malloc(strlen(name)+1);
	strcpy(s, name);
	s[strlen(name)] = 0;

	/* Make a new entry, and initialise it */
	t = get_symb();

	t->type = p_type;
	t->name = s;
	t->predefined = YES;

	/* Insert it into the symbol table */
	insert(t);
}

void do_commandline(int argc, char *argv[]) {

	/* Processes command line arguments */

	int currentarg = 1;
	filename = NULL;

	while (currentarg < argc) {
		if (argv[currentarg][0] != '-') {
			if (filename == NULL) {
				filename = (char *)malloc(strlen(argv[currentarg])+1);
				strcpy(filename, argv[currentarg]);
			}
			else {
				printf("Error: Cannot specify more than one file at a time\n");
				exit(1);
			}
		}
		else {
			if ((strcmp(argv[currentarg],"-nowarn")== 0) || (strcmp(argv[currentarg],"-n")==0)) {
				warnings_flag = 0;
			} else if ((strcmp(argv[currentarg],"-statsonly")==0) || (strcmp(argv[currentarg],"-s")==0)) {
				errors_flag = 0;
			} else if (strcmp(argv[currentarg],"--help")==0) {
				show_usage();
				exit(0);
			} else if ((strcmp(argv[currentarg], "-undeclared") == 0) || (strcmp(argv[currentarg],"-u") == 0)) {
				undeclared_flag = 1;
			} else if ((strcmp(argv[currentarg], "-portability") == 0) || (strcmp(argv[currentarg],"-p") == 0))  {
				portability_flag = 1;
			} else {
				printf("Unknown option: %s\n\n", argv[currentarg]);
				show_usage();
				exit(1);
			}
			
		}

		currentarg++;
	}
}

void do_start() {

	/* Displays the welcome screen */

	printf("\nLast Compiled: %s\n\n", LAST_COMPILED_DATE);
	printf("********************************************************\n");
	printf("*                                                      *\n");
	printf("* JavaScript Syntax Checker                            *\n");
	printf("*                                                      *\n");
	printf("* Part III Computer Science Project                    *\n");
	printf("* Department of Electronics & Computer Science         *\n");
	printf("*                                                      *\n");
	printf("* By Alex Walker                                       *\n");
	printf("*                                                      *\n");
	printf("* Email: javascript@soton.net                         *\n");
	printf("* WWW:   http://www.soton.net/jssyntaxchecker *\n");
	printf("*                                                      *\n");
	printf("********************************************************\n\n");

	if (filename != NULL) {
		printf("Processing file \"%s\"\n\n", filename);
	}
}

void show_usage() {

	/* Shows usage information - called by do_commandline() */

	printf("JavaScript (ECMAScript) Syntax Checker\n\n");
	printf("Usage:  jsparse [options] [filename] [options]\n\n");
	printf("  -n, -nowarn\t\tDisable warning messages\n");
	printf("  -s, -statsonly\tOnly show file statistics\n");
	printf("  -u, -undefined\tShow warnings of possible undefined variables\n");
	printf("  -p, -portability\tShow portability warnings of different browsers\n\n");
	printf("If no filename is specified, input is taken from standard input.\n\n");
	printf("Report bugs to javascript@soton.net\n");
}

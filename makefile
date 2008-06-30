#
# Makefile for "jsparse" JavaScript Syntax Checker
#
# Part III Project at University of Southampton, UK
# Alex Walker - javascript@soton.net
#
# Follow progress at:
#
# http://www.soton.net/jssyntaxchecker
#
# Created 980225
#

LEX		= lex
LEX_FLAGS	=

YACC		= yacc
YACC_FLAGS	= -d -v
# -d flag creater header file of tokens for us
# -v flag creates y.output file for error analysis

CC		= gcc
CC_FLAGS	= -g -ansi -pedantic
CC_LINK_FLAGS	= -lfl -o

jsparse: main.o y.tab.o lex.yy.o compile_date.o
	$(CC) $(CC_FLAGS) compile_date.c main.o y.tab.o lex.yy.o $(CC_LINK_FLAGS) jsparse
	rm -f compile_date.*

clean:
	rm -f core
	rm -f y.tab.*
	rm -f y.output
	rm -f lex.yy.*
	rm -f *.o
	rm -f compile_date.*

backup:
	make clean
	rm -f project.tar*
	tar cf project.tar *
	gzip project.tar
	mv project.tar.gz ..

pastversion:
	make backup
	rm -rf .past_versions/`date '+%y%m%d'`
	mkdir .past_versions/`date '+%y%m%d'`
	cp * .past_versions/`date '+%y%m%d'`

compile_date.o:
	echo "char * LAST_COMPILED_DATE = \"`date`\";" >> compile_date.c
	$(CC) $(CC_FLAGS) -c compile_date.c

y.tab.c: parser.y
	$(YACC) $(YACC_FLAGS) parser.y

y.tab.h: parser.y
	$(YACC) $(YACC_FLAGS) parser.y

lex.yy.c: scanner.l
	$(LEX) $(LEX_FLAGS) scanner.l

y.tab.o: y.tab.c
	$(CC) $(CC_FLAGS) -c y.tab.c

lex.yy.o: lex.yy.c
	$(CC) $(CC_FLAGS) -c lex.yy.c

main.o:	main.c y.tab.h header.h
	$(CC) $(CC_FLAGS) -c main.c

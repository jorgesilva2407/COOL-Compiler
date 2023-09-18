/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */
/*
   The two statements below are here just so this program will compile.
   You may need to change or remove them on your final code.
*/
#define yywrap() 1
#define YY_SKIP_YYWRAP

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/*
 * Define names for regular expressions here.
 */

DARROW           =>
LE               <=
ASSIGN           <-

LOWERCASE_LETTER [a-z]
UPPERCASE_LETTER [A-Z]
LETTER		 ({LOWERCASE_LETTER}|{UPPERCASE_LETTER})
DIGIT            [0-9]
BLANK            " "
NEWLINE          \n
UNDERSCORE       "_"
BINOP 		 ("+"|"-"|"*"|\/|"="|"<")	 
SPECIAL_SYMBOLS  ("~"|";"|":"|"."|","|"@")

OPEN_PARENTHESES  "("
CLOSE_PARENTHESES ")" 
OPEN_BRACES       "{"
CLOSE_BRACES      "}"
OPEN_BRACKETS     "["
CLOSE_BRACKETS    "]"

INTEGER 	 {DIGIT}+ 
TYPEID		 ("SELF_TYPE"|{UPPERCASE_LETTER}({LETTER}|{DIGIT}|{UNDERSCORE})*)	 
ID               ("self"|{LOWERCASE_LETTER}({LETTER}|{DIGIT}|{UNDERSCORE})*)
STRING_DELIMITER \"

SINGLE_LINE_COMMENT_DELIMITER     ("--") 
MULTILINE_COMMENT_START 	  ("\(\*")
MULTILINE_COMMENT_END   	  ("\*\)")

CLASS		 (?i:class)
ELSE		 (?i:else)
FI		 (?i:fi)	
IF		 (?i:if)	
IN		 (?i:in)
INHERITS	 (?i:inherits)	
ISVOID		 (?i:isvoid)
LET		 (?i:let)
LOOP		 (?i:loop)
POOL		 (?i:pool)
THEN		 (?i:then)
WHILE		 (?i:while)	
CASE  		 (?i:case)
ESAC		 (?i:esac)
NEW		 (?i:new)	
OF		 (?i:of)
NOT  		 (?i:not)
FALSE  		 (f)(?i:alse)
TRUE		 (t)(?i:rue)	

WS		 {BLANK|NEWLINE|\f|\r|\t|\v}

%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */

{DARROW}	{return (DARROW);}
{LE}            {return (LE);}
{ASSIGN} 	{return (ASSIGN);}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

{CLASS}     {return (CLASS);}
{ELSE}      {return (ELSE);}
{FI}        {return (FI);}
{IF}        {return (IF);}
{IN}        {return (IN);}
{INHERITS}  {return (INHERITS);}
{ISVOID}    {return (ISVOID);}
{LET}       {return (LET);}
{LOOP}      {return (LOOP);}
{POOL}      {return (POOL);}
{THEN}      {return (THEN);}
{WHILE}     {return (WHILE);}
{CASE}      {return (CASE);}
{ESAC}      {return (ESAC);}
{NEW}       {return (NEW);}
{OF}        {return (OF);}
{NOT}       {return (NOT);}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%

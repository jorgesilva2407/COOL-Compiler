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

char string_const[MAX_STR_CONST];
int string_const_len;
bool str_contain_null_char;

%}

/*
 * Define names for regular expressions here.
 */

%option noyywrap
%x LINE_COMMENT BLOCK_COMMENT STRING

DARROW           =>
LE               <=
ASSIGN           <-

LOWERCASE_LETTER [a-z]
UPPERCASE_LETTER [A-Z]
LETTER		 ({LOWERCASE_LETTER}|{UPPERCASE_LETTER})
DIGIT            [0-9]
NEWLINE          \n
UNDERSCORE       "_"	 

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

WS		 [ |\f|\r|\t|\v]

%%

{NEWLINE}	{curr_lineno++;}
{WS}+		{}

 /*
  *  Nested comments
  */

{SINGLE_LINE_COMMENT_DELIMITER}		{BEGIN LINE_COMMENT;}
{MULTILINE_COMMENT_START} 		{BEGIN BLOCK_COMMENT;}
{MULTILINE_COMMENT_END} 		{strcpy(cool_yylval.error_msg, "Unmatched *)");
				 	 return (ERROR);}

<LINE_COMMENT>{NEWLINE}			{BEGIN 0;
				 	 curr_lineno++;}
<LINE_COMMENT><<EOF>>			{BEGIN 0;
				 	 curr_lineno++;}

<BLOCK_COMMENT>{NEWLINE}		{curr_lineno++;}
<BLOCK_COMMENT>{MULTILINE_COMMENT_END}	{BEGIN 0;}
<BLOCK_COMMENT><<EOF>>			{strcpy(cool_yylval.error_msg, "EOF in comment");
					 BEGIN 0;	
				 	 return (ERROR);}
<LINE_COMMENT>.				{}
<BLOCK_COMMENT>.			{}

 /*
  *  The multiple-character operators.
  */

{DARROW}	{return (DARROW);}
{LE}            {return (LE);}
{ASSIGN} 	{return (ASSIGN);}

 /*
  *  The single-character operators.
  */
	 
 /*
  * Operators
  */
"+" 		{return '+';}
"-" 		{return '-';}
"*" 		{return '*';}
"/" 		{return '/';}
"=" 		{return '=';}
"<" 		{return '<';}
"~" 		{return '~';}
"@" 		{return '@';}

 /*
  * Ponctuations
  */
";" 		{return ';';}
":" 		{return ':';}
"." 		{return '.';}
"," 		{return ',';}

 /*
  * Brackets
  */
"(" 		{return '(';}
")" 		{return ')';} 
"{" 		{return '{';}
"}" 		{return '}';} 
"[" 		{return '[';}
"]" 		{return ']';}

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

{TRUE}      {cool_yylval.boolean = 1;
	     return BOOL_CONST;}
{FALSE}	    {cool_yylval.boolean = 0;
	     return BOOL_CONST;}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

{STRING_DELIMITER}	{memset(string_const, 0, sizeof string_const);
			 string_const_len = 0;
			 str_contain_null_char = false;
			 BEGIN STRING;}
<STRING><<EOF>>		{strcpy(cool_yylval.error_msg, "EOF in string constant");
			 BEGIN 0;
			 return (ERROR);}
<STRING>\\.		{if (string_const_len >= MAX_STR_CONST) {
			 	strcpy(cool_yylval.error_msg, "String constant too long");
			 	BEGIN 0;
			 	return (ERROR);
			} 
			switch(yytext[1]) {
				case '\"': string_const[string_const_len++] = '\"'; break;
				case '\\': string_const[string_const_len++] = '\\'; break;
				case 'b' : string_const[string_const_len++] = '\b'; break;
				case 'f' : string_const[string_const_len++] = '\f'; break;
				case 'n' : string_const[string_const_len++] = '\n'; break;
				case 't' : string_const[string_const_len++] = '\t'; break;
				case '0' : string_const[string_const_len++] = 0; 
			   	str_contain_null_char = true; break;
				default  : string_const[string_const_len++] = yytext[1];
			}}
<STRING>\\{NEWLINE}	{curr_lineno++;}
<STRING>{NEWLINE}	{curr_lineno++;
			 strcpy(cool_yylval.error_msg, "Unterminated string constant");
			 BEGIN 0;
			 return (ERROR);}
<STRING>{STRING_DELIMITER} {if (string_const_len > 1 && str_contain_null_char) {
			    	strcpy(cool_yylval.error_msg, "String contains null character");
				BEGIN 0;
			   	return (ERROR);
			   }
			   cool_yylval.symbol = stringtable.add_string(string_const);
			   BEGIN 0;
			   return (STR_CONST);}
<STRING>.		   {if (string_const_len >= MAX_STR_CONST) {
				strcpy(cool_yylval.error_msg, "String constant too long");
				BEGIN 0;
				return (ERROR);} 
			   string_const[string_const_len++] = yytext[0];}

 /*
  *  Integers and ID`s.
  */

{INTEGER}  		{cool_yylval.symbol = inttable.add_string(yytext); 
			 return (INT_CONST);}
{TYPEID}		{cool_yylval.symbol = idtable.add_string(yytext);
			 return (TYPEID);}
{ID}			{cool_yylval.symbol = idtable.add_string(yytext);
			 return (OBJECTID);}

 /*
  *  Default rule.
  */

.			{strcpy(cool_yylval.error_msg, yytext); 
			 return (ERROR);}

%%

%{
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"
    int countn=0;
    extern void add(char c);
    extern void insert_type();
%}
%option yylineno

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return PRINTFF; }
"scanf"                     { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return SCANFF; }
"int"                       { strcpy(yylval.nd_obj.name,(yytext)); insert_type(); add('K'); return INT; }
"float"                     { strcpy(yylval.nd_obj.name,(yytext)); insert_type(); add('K'); return FLOAT; }
"char"                      { strcpy(yylval.nd_obj.name,(yytext)); insert_type(); add('K'); return CHAR; }
"void"                      { strcpy(yylval.nd_obj.name,(yytext)); insert_type(); add('K'); return VOID; }
"return"                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return RETURN; }
"for"	                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return FOR; }
"while"                     { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return WHILE; }
"switch"                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return SWITCH; }
"case"                      { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return CASE; }
"default"                   { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return DEFAULT; }
"break"                     { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return BREAK; }
"if"	                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return IF; }
"else"	                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return ELSE; }
^"#include"[ ]*<.+\.h>      { strcpy(yylval.nd_obj.name,(yytext)); add('H'); return INCLUDE; }
"true"                      { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return TRUE; }
"false"                     { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return FALSE; }
[-]?{digit}+                { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return FLOAT_NUM; }
{alpha}({alpha}|{digit})*   { strcpy(yylval.nd_obj.name,(yytext)); add('V'); return ID; }
{unary}                     { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return UNARY; }
"<="                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return LE; }
">="                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return GE; }
"=="                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return EQ; }
"!="                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return NE; }
">"	                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return GT; }
"<"	                        { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return LT; }
"&&"	                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return AND; }
"||"	                    { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return OR; }
"+"                         { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return ADD; }
"-"                         { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return SUBTRACT; }
"/"                         { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return DIVIDE; }
"*"                         { strcpy(yylval.nd_obj.name,(yytext)); add('K'); return MULTIPLY; }
":"                         { return ':'; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }
["].*["]                    { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return STR; }
['].[']                     { strcpy(yylval.nd_obj.name,(yytext)); add('C'); return CHARACTER; }

%%

int yywrap() {
    return 1;
}
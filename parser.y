%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include "compiler.h"
    
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    extern char* yytext;
    extern int countn;
    extern int yylineno;
    
    void yyerror(const char *s);

    #define OP_ASSIGN "="
    #define OP_PLUS "+"
    #define OP_MINUS "-"
    #define OP_MULTIPLY "*"
    #define OP_DIVIDE "/"
    #define OP_AND "&&"
    #define OP_OR "||"
    #define OP_LESS "<"
    #define OP_GREATER ">"
    #define OP_LESS_EQUAL "<="
    #define OP_GREATER_EQUAL ">="
    #define OP_EQUAL "=="
    #define OP_NOT_EQUAL "!="
    #define OP_GOTO "goto"
    #define OP_IF "if"
    #define OP_LABEL "label"
    #define OP_RETURN "return"
    #define OP_PARAM "param"
    #define OP_CALL "call"

    struct dataType symbol_table[40];
    struct quad quad_table[100];
    int count = 0;
    int q;
    char type[10];
    struct node *head;
    int sem_errors = 0;
    int label = 0;
    char buff[100];
    char errors[10][100];
    char reserved[10][10] = {"int", "float", "char", "void", "if", "else", "for", "main", "return", "include"};
    int quad_idx = 0;
    char icg[50][100];
    int ic_idx = 0;
    int is_for = 0;
    int temp_var = 0;
    int in_switch = 0;
    int in_while = 0;
    char while_end_label[10];
    char while_start_label[10];
%}

%union { 
    struct var_name { 
        char name[100]; 
        struct node* nd;
        char if_body[5];
        char else_body[5];
    } nd_obj;

    struct var_name2 { 
        char name[100]; 
        struct node* nd;
        char type[5];
    } nd_obj2; 
} 

%token VOID 
%token <nd_obj> CHARACTER PRINTFF SCANFF INT FLOAT CHAR FOR IF ELSE TRUE FALSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT AND OR STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN WHILE SWITCH CASE DEFAULT BREAK

%type <nd_obj> headers main body return datatype statement arithmetic relop program else condition case_list case_item
%type <nd_obj2> init value expression printf_args

%left ADD SUBTRACT
%left MULTIPLY DIVIDE
%nonassoc UNARY
%nonassoc IF
%nonassoc ELSE

%%

program: headers main '(' ')' '{' body return '}' { $2.nd = mknode($6.nd, $7.nd, "main"); $$.nd = mknode($1.nd, $2.nd, "program"); 
    head = $$.nd;
} 
;

headers: headers headers { $$.nd = mknode($1.nd, $2.nd, "headers"); }
| INCLUDE { add('H'); } { $$.nd = mknode(NULL, NULL, $1.name); }
;

main: datatype ID { add('F'); }
;

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| VOID { insert_type(); }
;

body: FOR { add('K'); } '(' statement ';' condition ';' statement ')' '{' body '}' { 
    struct node *temp = mknode($6.nd, $8.nd, "CONDITION"); 
    struct node *temp2 = mknode($4.nd, temp, "CONDITION"); 
    $$.nd = mknode(temp2, $11.nd, $1.name); 
}
| WHILE { 
    add('K');
    strcpy(while_start_label, new_label());
    emit("label", "", "", while_start_label);
    in_while = 1;
    strcpy(while_end_label, new_label());
} '(' condition ')' '{' body '}' {
    $$.nd = mknode($4.nd, $7.nd, "WHILE");
    emit("goto", "", "", while_start_label);
    emit("label", "", "", while_end_label);
    in_while = 0;
}
| SWITCH { add('K'); } '(' expression ')' {
    in_switch = 1;
    char* end_switch = new_label();
    emit("label", "", "", "start_switch");
} '{' case_list '}' {
    $$.nd = mknode($4.nd, $8.nd, "SWITCH");
    emit("label", "", "", "end_switch");
    in_switch = 0;
}
| IF { add('K'); } '(' condition ')' '{' body '}' else { 
    struct node *iff = mknode($4.nd, $7.nd, $1.name); 
    $$.nd = mknode(iff, $9.nd, "if-else"); 
}
| statement ';' { $$.nd = $1.nd; }
| body body { $$.nd = mknode($1.nd, $2.nd, "statements"); }
| PRINTFF { add('K'); } '(' STR printf_args ')' ';' { 
    struct node *str = mknode(NULL, NULL, $4.name);
    $$.nd = mknode(str, $5.nd, "printf"); 
}
| SCANFF { add('K'); } '(' STR ',' '&' ID ')' ';' { $$.nd = mknode(NULL, NULL, "scanf"); }
| BREAK ';' { 
    $$.nd = mknode(NULL, NULL, "BREAK");
    if(in_switch) {
        emit("goto", "", "", "end_switch");
    } else if(in_while) {
        emit("goto", "", "", while_end_label);
    }
}
;

printf_args: ',' expression { 
    $$.nd = mknode(NULL, $2.nd, "printf_arg");
    emit("param", $2.name, "", "");
}
| printf_args ',' expression {
    $$.nd = mknode($1.nd, $3.nd, "printf_args");
    emit("param", $3.name, "", "");
}
| { $$.nd = NULL; }
;

else: ELSE { add('K'); } '{' body '}' { $$.nd = mknode(NULL, $4.nd, $1.name); }
| { $$.nd = NULL; }
;

condition: value relop value { 
    $$.nd = mknode($1.nd, $3.nd, $2.name); 
    char* temp = new_temp();
    emit($2.name, $1.name, $3.name, temp);
    
    if(is_for) {
        sprintf($$.if_body, "%s", new_label());
        sprintf($$.else_body, "%s", new_label());
        emit(OP_IF, temp, "", $$.if_body);
        emit(OP_GOTO, "", "", $$.else_body);
    } else if(in_while) {
        emit(OP_IF, temp, "", while_end_label);
    }
}
| TRUE { 
    $$.nd = mknode(NULL, NULL, "true");
    if(in_while) {
        emit(OP_GOTO, "", "", "start_while");
    }
}
| FALSE {
    $$.nd = mknode(NULL, NULL, "false");
    if(in_while) {
        emit(OP_GOTO, "", "", while_end_label);
    }
}
| { $$.nd = NULL; }
;

statement: datatype ID { add('V'); } init { 
    $2.nd = mknode(NULL, NULL, $2.name); 
    if($4.nd) {
        emit("=", $4.name, "", $2.name);
    }
    $$.nd = mknode($2.nd, $4.nd, "declaration"); 
}
| ID { check_declaration($1.name); } '=' expression {
    emit("=", $4.name, "", $1.name);
    $1.nd = mknode(NULL, NULL, $1.name);
    $$.nd = mknode($1.nd, $4.nd, "=");
}
| ID { check_declaration($1.name); } UNARY {
    char* temp = new_temp();
    if(!strcmp($3.name, "++")) {
        emit("+", $1.name, "1", temp);
    } else {
        emit("-", $1.name, "1", temp);
    }
    emit("=", temp, "", $1.name);
    $1.nd = mknode(NULL, NULL, $1.name);
    $$.nd = mknode($1.nd, NULL, $3.name);
}
| UNARY ID { 
    check_declaration($2.name); 
    char* temp = new_temp();
    if(!strcmp($1.name, "++")) {
        emit("+", $2.name, "1", temp);
    } else {
        emit("-", $2.name, "1", temp);
    }
    emit("=", temp, "", $2.name);
    $1.nd = mknode(NULL, NULL, $1.name); 
    $2.nd = mknode(NULL, NULL, $2.name); 
    $$.nd = mknode($1.nd, $2.nd, "ITERATOR"); 
}
;

init: '=' value { $$.nd = $2.nd; sprintf($$.type, $2.type); strcpy($$.name, $2.name); }
| { sprintf($$.type, "null"); $$.nd = mknode(NULL, NULL, "NULL"); strcpy($$.name, "NULL"); }
;

expression: expression arithmetic expression { 
    char* temp = new_temp();
    emit($2.name, $1.name, $3.name, temp);
    strcpy($$.name, temp);
    sprintf($$.type, "int");  // Default to int for arithmetic
    if(!strcmp($1.type, "float") || !strcmp($3.type, "float")) {
        sprintf($$.type, "float");  // Promote to float if any operand is float
    }
    $$.nd = mknode($1.nd, $3.nd, $2.name);
}
| value { 
    strcpy($$.name, $1.name); 
    sprintf($$.type, $1.type); 
    $$.nd = $1.nd; 
}
;

arithmetic: ADD { strcpy($$.name, "+"); }
| SUBTRACT { strcpy($$.name, "-"); }
| MULTIPLY { strcpy($$.name, "*"); }
| DIVIDE { strcpy($$.name, "/"); }
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

value: NUMBER { strcpy($$.name, $1.name); sprintf($$.type, "int"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| FLOAT_NUM { strcpy($$.name, $1.name); sprintf($$.type, "float"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| CHARACTER { strcpy($$.name, $1.name); sprintf($$.type, "char"); add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
| ID { strcpy($$.name, $1.name); char *id_type = get_type($1.name); sprintf($$.type, id_type); check_declaration($1.name); $$.nd = mknode(NULL, NULL, $1.name); }
;

return: RETURN { add('K'); } value ';' { check_return_type($3.name); $1.nd = mknode(NULL, NULL, "return"); $$.nd = mknode($1.nd, $3.nd, "RETURN"); }
| { $$.nd = NULL; }
;

case_list: case_item { $$.nd = $1.nd; }
| case_list case_item { $$.nd = mknode($1.nd, $2.nd, "case_list"); }
;

case_item: CASE NUMBER ':' body { 
    struct node *num = mknode(NULL, NULL, $2.name);
    $$.nd = mknode(num, $4.nd, "case");
    char* next_case = new_label();
    emit("if", "!=", $2.name, next_case);
    emit("label", "", "", next_case);
}
| DEFAULT ':' body {
    $$.nd = mknode(NULL, $3.nd, "default");
}
;

%%

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}

int main() {
    yyparse();
    printf("\n\n");
    printf("\t\t\t\t\t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
    printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
    printf("_______________________________________\n\n");
    int i=0;
    for(i=0; i<count; i++) {
        printf("%s\t%s\t%s\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no);
    }
    for(i=0;i<count;i++) {
        free(symbol_table[i].id_name);
        free(symbol_table[i].type);
    }
    printf("\n\n");
    printf("\t\t\t\t\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
    print_tree(head); 
    printf("\n\n\n\n");
    printf("\t\t\t\t\t\t\t\t PHASE 3: SEMANTIC ANALYSIS \n\n");
    if(sem_errors>0) {
        printf("Semantic analysis completed with %d errors\n", sem_errors);
        for(int i=0; i<sem_errors; i++){
            printf("\t - %s", errors[i]);
        }
    } else {
        printf("Semantic analysis completed with no errors");
    }
    printf("\n\n");
    printf("\t\t\t\t\t\t\t\t PHASE 4: INTERMEDIATE CODE GENERATION \n\n");
    print_three_address_code();
    return 0;
} 
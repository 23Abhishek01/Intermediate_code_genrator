#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"
#include "y.tab.h"

extern struct dataType symbol_table[40];
extern struct quad quad_table[100];
extern int count;
extern int quad_idx;
extern char errors[10][100];
extern int sem_errors;
extern char type[10];
extern int yylineno;
extern char* yytext;

struct node* mknode(struct node *left, struct node *right, char *token) {
    struct node *newnode = (struct node *)malloc(sizeof(struct node));
    char *newstr = (char *)malloc(strlen(token)+1);
    strcpy(newstr, token);
    newnode->left = left;
    newnode->right = right;
    newnode->token = newstr;
    return newnode;
}

void add(char c) {
    if (count >= 40) {
        printf("Warning: Symbol table overflow at token: %s\n", yytext);
        return;
    }

    // Skip if the token is already in the symbol table
    for(int i = 0; i < count; i++) {
        if(symbol_table[i].id_name && strcmp(symbol_table[i].id_name, yytext) == 0) {
            return;
        }
    }

    switch(c) {
        case 'V': // Variable
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup(type);
            symbol_table[count].type = strdup("variable");
            symbol_table[count].line_no = yylineno;
            count++;
            break;
        case 'F': // Function
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup(type);
            symbol_table[count].type = strdup("function");
            symbol_table[count].line_no = yylineno;
            count++;
            break;
        case 'K': // Keyword
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup("keyword");
            symbol_table[count].type = strdup("keyword");
            symbol_table[count].line_no = yylineno;
            count++;
            break;
        case 'C': // Constant
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup(type);
            symbol_table[count].type = strdup("constant");
            symbol_table[count].line_no = yylineno;
            count++;
            break;
        case 'H': // Header
            symbol_table[count].id_name = strdup(yytext);
            symbol_table[count].data_type = strdup("header");
            symbol_table[count].type = strdup("header");
            symbol_table[count].line_no = yylineno;
            count++;
            break;
    }
}

void insert_type() {
    strcpy(type, yytext);
}

int search(char *type) {
    // Implementation for symbol table search
    // This is a placeholder implementation
    return 0;
}

void check_declaration(char *c) {
    // Implementation for declaration checking
    // This is a placeholder implementation
}

void check_return_type(char *type) {
    // Implementation for return type checking
    // This is a placeholder implementation
}

char *get_type(char *var) {
    // Implementation for getting variable type
    // This is a placeholder implementation
    return "int";
}

void print_tree(struct node *tree) {
    // Implementation for AST printing
    if (tree->left) {
        print_tree(tree->left);
    }
    printf("%s ", tree->token);
    if (tree->right) {
        print_tree(tree->right);
    }
}

void emit(char *op, char *arg1, char *arg2, char *result) {
    // Add the quad to the quad table
    strcpy(quad_table[quad_idx].op, op);
    strcpy(quad_table[quad_idx].arg1, arg1);
    strcpy(quad_table[quad_idx].arg2, arg2);
    strcpy(quad_table[quad_idx].result, result);
    quad_idx++;
}

char* new_temp() {
    static int temp_no = 1;
    char *temp = (char *)malloc(10);
    sprintf(temp, "t%d", temp_no++);
    return temp;
}

char* new_label() {
    static int label_no = 1;
    char *label = (char *)malloc(10);
    sprintf(label, "L%d", label_no++);
    return label;
}

void print_three_address_code() {
    printf("\nThree Address Code:\n");
    printf("----------------------------------------\n");
    printf("Index\tOp\tArg1\tArg2\tResult\n");
    printf("----------------------------------------\n");
    
    for(int i = 0; i < quad_idx; i++) {
        printf("%d\t%s\t%s\t%s\t%s\n", 
            i,
            quad_table[i].op,
            quad_table[i].arg1,
            quad_table[i].arg2,
            quad_table[i].result);
    }
    printf("----------------------------------------\n");
} 
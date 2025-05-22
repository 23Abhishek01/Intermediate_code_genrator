#ifndef COMPILER_H
#define COMPILER_H

struct node { 
    struct node *left; 
    struct node *right; 
    char *token; 
};

struct dataType {
    char * id_name;
    char * data_type;
    char * type;
    int line_no;
};

struct quad {
    char op[10];
    char arg2[50];
    char arg1[50];
    char result[50];
};

// Function declarations
struct node* mknode(struct node *left, struct node *right, char *token);
void add(char c);
void insert_type();
int search(char *type);
void print_tree(struct node *tree);
void print_inorder(struct node *tree);
void check_declaration(char *c);
void check_return_type(char *type);
int check_types(char *type1, char *type2);
char *get_type(char *var);
void emit(char *op, char *arg1, char *arg2, char *result);
char* new_temp();
char* new_label();
void backpatch(int from_idx, char* label);
void print_three_address_code();

#endif 
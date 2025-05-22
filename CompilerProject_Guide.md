# Comprehensive Compiler Design Project Guide
## Understanding Lexical Analysis and Syntax Analysis with Lex & Yacc

### Table of Contents
1. [Project Overview](#project-overview)
2. [Detailed Phase Analysis](#detailed-phase-analysis)
3. [Lex Implementation Details](#lex-implementation)
4. [Yacc Implementation Details](#yacc-implementation)
5. [Data Structures and Symbol Table](#data-structures)
6. [Intermediate Code Generation](#icg)
7. [Building and Running](#building)
8. [Extended Viva Questions](#viva-questions)

## Project Overview
This project implements a compiler for a C-like programming language. It includes:
- Lexical analysis using Flex (Lex)
- Syntax analysis using Bison (Yacc)
- Semantic analysis
- Intermediate code generation
- Symbol table management
- Error handling

## Detailed Phase Analysis

### 1. Lexical Analysis Phase
#### Purpose:
- Breaks input program into tokens
- Removes comments and whitespace
- Identifies lexical errors

#### Implementation Details:
```lex
%{
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"
%}

alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%
"int"    { return INT; }
"float"  { return FLOAT; }
{alpha}({alpha}|{digit})*   { return ID; }
// ... more token definitions
%%
```

#### Token Categories in Our Project:
1. Keywords: `int`, `float`, `char`, `if`, `else`, `while`, `for`, etc.
2. Operators: 
   - Arithmetic: `+`, `-`, `*`, `/`
   - Relational: `<`, `>`, `<=`, `>=`, `==`, `!=`
   - Logical: `&&`, `||`
3. Identifiers: Variable and function names
4. Constants: Numbers, strings, characters
5. Special symbols: `;`, `{`, `}`, `(`, `)`

### 2. Syntax Analysis Phase
#### Purpose:
- Validates program structure
- Builds Abstract Syntax Tree (AST)
- Reports syntax errors

#### Grammar Rules Implementation:
```yacc
program: headers main '(' ')' '{' body return '}'
       ;

body: FOR '(' statement ';' condition ';' statement ')' '{' body '}'
    | IF '(' condition ')' '{' body '}' else
    | statement ';'
    ;
```

#### Key Grammar Features:
1. Expression handling
2. Control structures (if, while, for)
3. Function declarations
4. Variable declarations
5. Error recovery

### 3. Semantic Analysis Phase
#### Implementation Features:
1. Type checking:
   ```c
   int check_types(char *type1, char *type2) {
       // Type compatibility checking
   }
   ```

2. Symbol table management:
   ```c
   struct dataType {
       char * id_name;    // Name of the identifier
       char * data_type;  // int, float, char etc.
       char * type;       // variable, function, array
       int line_no;       // Line where it's declared
   };
   ```

3. Scope handling
4. Declaration checking

### 4. Intermediate Code Generation
#### Three Address Code Generation:
```c
struct quad {
    char op[10];    // Operator
    char arg1[50];  // First operand
    char arg2[50];  // Second operand
    char result[50]; // Result
};
```

#### Types of Instructions Generated:
1. Assignment: `t1 = a + b`
2. Conditional jumps: `if a < b goto L1`
3. Unconditional jumps: `goto L2`
4. Function calls: `param x, call foo, 2`

## Data Structures Used

### 1. Abstract Syntax Tree
```c
struct node { 
    struct node *left; 
    struct node *right; 
    char *token; 
};
```
- Used for: Representing program structure
- Benefits: 
  - Easy traversal for code generation
  - Maintains expression hierarchy
  - Simplifies optimization

### 2. Symbol Table
```c
struct dataType {
    char * id_name;    // Name of the identifier
    char * data_type;  // int, float, char etc.
    char * type;       // variable, function, array
    int line_no;       // Line where it's declared
};
```
Operations:
- Insert: Add new symbols
- Lookup: Check existence and get attributes
- Update: Modify symbol attributes
- Delete: Remove symbols when scope ends

### 3. Quadruple Table
```c
struct quad {
    char op[10];
    char arg1[50];
    char arg2[50];
    char result[50];
};
```
Features:
- Sequential representation
- Easy to optimize
- Machine-independent
- Suitable for code generation

## Building and Running

### Prerequisites Installation:
1. Flex (Fast Lexical Analyzer):
   ```bash
   sudo apt-get install flex
   ```

2. Bison (Yacc replacement):
   ```bash
   sudo apt-get install bison
   ```

3. GCC Compiler:
   ```bash
   sudo apt-get install build-essential
   ```

### Build Process:
1. Generate lexical analyzer:
   ```bash
   flex lexer.l
   ```

2. Generate parser:
   ```bash
   bison -d parser.y
   ```

3. Compile:
   ```bash
   gcc lex.yy.c y.tab.c -o compiler
   ```

## Extended Viva Questions

### 1. Explain the role of each phase in your compiler
**Answer**:
- Lexical Analysis: Tokenizes input using flex patterns
- Syntax Analysis: Builds AST using Bison grammar rules
- Semantic Analysis: Performs type checking and scope validation
- ICG: Generates three-address code

### 2. How does your symbol table handle scoping?
**Answer**:
- Maintains scope level information
- Handles block-level and function-level scopes
- Supports symbol lookup in nested scopes
- Manages symbol visibility rules

### 3. Explain your error handling mechanism
**Answer**:
- Lexical errors: Invalid characters, malformed tokens
- Syntax errors: Grammar rule violations
- Semantic errors: Type mismatches, undeclared variables
- Error recovery: Continues parsing after error detection

### 4. How does your compiler handle type checking?
**Answer**:
- Validates type compatibility in assignments
- Checks function argument types
- Ensures array index types
- Handles type coercion

### 5. Explain the intermediate code generation process
**Answer**:
- Generates temporary variables
- Creates three-address code
- Handles control flow statements
- Manages function calls and returns

### 6. How does your AST help in code generation?
**Answer**:
- Maintains expression precedence
- Simplifies code generation traversal
- Helps in optimization
- Represents program structure

### 7. Explain the quadruple generation for loops
**Answer**:
- Entry condition checking
- Body code generation
- Increment/decrement handling
- Loop control flow management

### 8. How do you handle function calls in your compiler?
**Answer**:
- Parameter passing mechanism
- Return value handling
- Stack frame management
- Function prototype checking

### 9. Explain the optimization techniques used
**Answer**:
- Constant folding
- Dead code elimination
- Common subexpression elimination
- Loop optimization

### 10. How does your compiler handle arrays and pointers?
**Answer**:
- Array declaration processing
- Pointer type checking
- Array bounds checking
- Address calculation

## Conclusion
This compiler project demonstrates a practical implementation of compiler design principles. Understanding each phase and their interaction is crucial for compiler construction.

---
*Note: You can convert this markdown file to PDF using online tools or markdown editors.* 

Q: What happens when you compile "a = b + c"?
A: 1. Lexer breaks into tokens: ID(a), ASSIGN(=), ID(b), ADD(+), ID(c)
   2. Parser builds AST with '+' at root, '=' and 'c' as children
   3. Generate three-address code: t1 = b + c; a = t1

Q: How do you handle type checking?
A: Using check_types() function that verifies type compatibility
   in assignments and expressions

Q: How does your error recovery work?
A: 1. Lexical errors: Invalid characters reported
   2. Syntax errors: Parser error recovery
   3. Semantic errors: Type mismatch detection 

Source Code -> Lexer (lexer.l) -> Tokens -> Parser (parser.y) -> AST -> Semantic Analysis -> Three Address Code 
#include <stdio.h>

int main() {
    int i = 0;
    int choice = 2;
    
    // Test while loop
    while (i < 5) {
        printf("i = %d\n", i);
        i++;
    }
    
    // Test switch statement
    switch (choice) {
        case 1:
            printf("Choice is 1\n");
            break;
        case 2:
            printf("Choice is 2\n");
            break;
        default:
            printf("Unknown choice\n");
            break;
    }
    
    return 0;
}


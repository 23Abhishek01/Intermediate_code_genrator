@echo off
setlocal enabledelayedexpansion

echo Cleaning up old files...
if exist lex.yy.c del lex.yy.c
if exist y.tab.c del y.tab.c
if exist y.tab.h del y.tab.h
if exist compiler.exe del compiler.exe

echo Generating lexical analyzer...
flex lexer.l
if errorlevel 1 (
    echo Flex failed!
    goto :end
)

echo Generating parser...
bison -dy parser.y
if errorlevel 1 (
    echo Bison failed!
    goto :end
)

echo Compiling...
gcc -o compiler.exe y.tab.c lex.yy.c
if errorlevel 1 (
    echo GCC compilation failed!
    goto :end
)

if exist compiler.exe (
    echo Compilation successful!
    echo.
    if exist test.c (
        echo Running compiler with test.c...
        echo.
        type test.c | compiler.exe
    ) else (
        echo No test.c found. Creating sample test.c...
        (
            echo #include ^<stdio.h^>
            echo.
            echo int main^(^) {
            echo     int a = 5;
            echo     int b = 10;
            echo     if ^(a ^< b^) {
            echo         a = a + 1;
            echo     }
            echo     return a;
            echo }
        ) > test.c
        echo Created test.c. Running compiler...
        echo.
        type test.c | compiler.exe
    )
) else (
    echo Compilation failed!
)

:end
endlocal
pause 
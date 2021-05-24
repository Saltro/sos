void printstr(char *c);

int HariMain() {
    char s[10] = "Hello C L";

    int i, j;
    for (i = 0, j = 0; j < 9; i += 2, j++) {
        *(char *)(0xb8000+5*160+i) = s[j];
    }

    char *c = "Hello! C and ASM.";

    printstr(c);

    while (1) {
        ;
    }
    return 0;
}


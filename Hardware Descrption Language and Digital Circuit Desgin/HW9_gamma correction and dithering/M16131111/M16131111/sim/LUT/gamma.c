#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[])
{
    FILE *fp;
    int value;
    double i;
    double ga;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <gamma_value>\n", argv[0]);
        return 1;
    }

    sscanf(argv[1], "%lf", &ga);
    fp = fopen("./gav.txt", "w");
    if (fp == NULL) {
        perror("Failed to open output file");
        return 1;
    }

    for (i = 0; i <= 255; i++) {
        value = (int)(255 * 4 * pow(i / 255.0, ga));
        if (value < 0) value = 0;
        if (value > 1023) value = 1023;
        fprintf(fp, "%X\n", value);
    }

    fclose(fp);
    return 0;
}
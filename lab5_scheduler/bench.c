#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 100000000

int main()
{
    volatile unsigned long long sum = 0;

    clock_t start = clock();

    for (unsigned long long i = 0; i < N; i++) {
        sum += (i * 31) % 1000003;
    }

    clock_t end = clock();

    double seconds =
        (double)(end - start) / CLOCKS_PER_SEC;

    printf("Result: %llu\n", sum);
    printf("CPU time: %.4f seconds\n", seconds);

    return 0;
}
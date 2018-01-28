/* File:     h5.c
 *
 * Purpose: Read in three long ints and print result from assembly computation.
 *
 * Compile:  gcc -o add h5.c compute.s -I.
 * Run:      ./compute
 *
 * Input:    Three long ints
 * Output:   Their computation
 *
 * Notes:     
 * 1. This version should be run on a 64-bit system.
 */

#include <stdio.h>

long compute(long a, long b, long c);

int main(void) {
   long a, b, c, d;

   printf("Enter three ints\n");
   scanf("%ld%ld%ld", &a, &b, &c);

   d = compute(a, b, c);

   printf("The computation is %ld\n", d);

   return 0;
}
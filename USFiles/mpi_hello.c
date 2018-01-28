/* File:       mpi_hello.c
 *
 * Purpose:    A "hello,world" program that uses MPI
 *
 * Compile:    mpicc -g -Wall -o mpi_hello mpi_hello.c
 * Run:        mpiexec -n<number of processes> mpi_hello
 *
 * Input:      None
 * Output:     A greeting from each process
 *
 * Algorithm:  Each process sends a message to process 0,
 *             which prints the messages it has received,
 *             as well as its own message.
 */
#include <stdio.h>
#include <string.h>  /* For strlen             */
#include <mpi.h>     /* For MPI functions, etc */

const int MAX_STRING = 1000;

int main(void) {
   char       greeting[MAX_STRING];
   char       proc_name[MPI_MAX_PROCESSOR_NAME];
   int        my_rank, p, q, len;

   /* Start up MPI */
   MPI_Init(NULL, NULL);

   /* Get the number of processes */
   MPI_Comm_size(MPI_COMM_WORLD, &p);

   /* Get my rank among all the processes */
   MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

   MPI_Get_processor_name(proc_name, &len);

   if (my_rank == 0) {
      printf("Greetings from process %d of %d, running on %s\n", 
            my_rank, p, proc_name);
      for (q = 1; q < p; q++) {
         MPI_Recv(greeting, MAX_STRING, MPI_CHAR, q, 
            0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
         printf("%s\n", greeting);
      } 
   } else {
      sprintf(greeting, "Greetings from process %d of %d, running on %s", 
            my_rank, p, proc_name);
      MPI_Send(greeting, strlen(greeting)+1, MPI_CHAR, 0, 0,
            MPI_COMM_WORLD);
   }

   /* Shut down MPI */
   MPI_Finalize();
   return 0;
}  /* main */

/* File:     mpi_floyd.c
 * Author:   Tommie Watts
 * Purpose:  Implement Floyd's algorithm for solving the all-pairs shortest
 *           path problem:  find the length of the shortest path between each
 *           pair of vertices in a directed graph.
 *
 * Input:    n, the number of vertices in the digraph
 *           mat, the adjacency matrix of the digraph
 * Output:   A matrix showing the costs of the shortest paths
 *
 * Compile:  mpicc -g -Wall -o mpi_floyd mpi_floyd.c
 *           (See note 7)
 * Run:      mpiexec -n <number of processes> ./mpi_floyd
 *           For large matrices, put the matrix into a file with n as
 *           the first line and run with ./floyd < large_matrix
 *
 * Notes:
 * 1.  The input matrix is overwritten by the matrix of lengths of shortest
 *     paths.
 * 2.  Edge lengths should be nonnegative.
 * 3.  If there is no edge between two vertices, the length is the constant
 *     INFINITY.  So input edge length should be substantially less than
 *     this constant.
 * 4.  The cost of travelling from a vertex to itself is 0.  So the adjacency
 *     matrix has zeroes on the main diagonal.
 * 5.  No error checking is done on the input.
 * 6.  The adjacency matrix is stored as a 1-dimensional array and subscripts
 *     are computed using the formula:  the entry in the ith row and jth
 *     column is mat[i*n + j]
 * 7.  Use the compile flag -DSHOW_INT_MATS to print the matrix after its
 *     been updated with each intermediate city.
 */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <string.h>

const int INFINITY = 1000000;

void Read_matrix(int mat[], int n);
void Print_matrix(int mat[], int n);
void Print_row(int local_mat[], int n, int my_rank, int i);
void Floyd(int local_mat[], int n, int p, int my_rank);
int min(int one, int two);

int main(void) {
   int  n;
   int* temp_mat;
   int* local_mat;
   int p, my_rank;
   MPI_Comm comm;

   //Sets up MPI navigation variables
   MPI_Init(NULL, NULL);
   comm = MPI_COMM_WORLD;
   MPI_Comm_size(comm, &p);
   MPI_Comm_rank(comm, &my_rank);

   //Takes input on process 0 only.
   if(my_rank == 0) {  
      printf("How many vertices?\n");
      scanf("%d", &n);
   }

   //MPI Broadcast communicates info to all processes.
   MPI_Bcast(&n, 1, MPI_INT, 0, comm); 
   
   /*Create two matrices to store main matrix and
     individual matrices for each process.*/
   temp_mat = malloc(n*n*sizeof(int));
   local_mat = malloc(n*n*sizeof(int));

   //Only reads in one matrix on process 0 and stores in temp_mat
   if(my_rank == 0){
      printf("Enter the matrix\n");
      Read_matrix(temp_mat, n);
      printf("The OG Matrix\n");
      Print_matrix(temp_mat, n);
   }

   //sends data from process 0 to all process's
   MPI_Scatter(temp_mat, n*n/p, MPI_INT, local_mat, n*n/p, MPI_INT, 0, comm);
   
   //Runs Flloyd function
   Floyd(local_mat, n, p, my_rank);

   //gathers data from all the process's
   MPI_Gather(local_mat, n*n/p, MPI_INT, temp_mat, n*n/p, MPI_INT, 0, comm);


   //Output of matrix done only on process 0
   if(my_rank == 0){
      printf("That New Matrix:\n");
      Print_matrix(temp_mat, n);
   }

   //free's matrices
   free(temp_mat);
   free(local_mat);

   //ends MPI
   MPI_Finalize();
   return 0;
}  /* main */

/*-------------------------------------------------------------------
 * Function:  Read_matrix
 * Purpose:   Read in the adjacency matrix
 * In arg:    n
 * Out arg:   mat
 */
void Read_matrix(int mat[], int n) {
   int i, j;

   for (i = 0; i < n; i++)
      for (j = 0; j < n; j++)
         scanf("%d", &mat[i*n+j]);
}  /* Read_matrix */

/*-------------------------------------------------------------------
 * Function:  Print_matrix
 * Purpose:   Print the contents of the matrix
 * In args:   mat, n
 */
void Print_matrix(int mat[], int n) {
   int i, j;

   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         if (mat[i*n+j] == INFINITY)
            printf("i ");
         else
            printf("%d ", mat[i*n+j]);
      printf("\n");
   }
}  /* Print_matrix */


/*---------------------------------------------------------------------
 * Function:  Print_row
 * Purpose:   Convert a row of local_mat to a string and then print
 *            the row.  This tends to reduce corruption of output
 *            when multiple processes are printing.
 * In args:   all            
 */
void Print_row(int local_mat[], int n, int my_rank, int i){
   char char_int[100];
   char char_row[1000];
   int j, offset = 0;

   for (j = 0; j < n; j++) {
      if (local_mat[i*n + j] == INFINITY)
         sprintf(char_int, "i ");
      else
         sprintf(char_int, "%d ", local_mat[i*n + j]);
      sprintf(char_row + offset, "%s", char_int);
      offset += strlen(char_int);
   }  
   printf("Proc %d > row %d = %s\n", my_rank, i, char_row);
}  /* Print_row */

/*-------------------------------------------------------------------
 * Function:    Floyd
 * Purpose:     Apply Floyd's algorithm to the matrix mat
 * In arg:      n
 * In/out arg:  mat:  on input, the adjacency matrix, on output
 *              lengths of the shortest paths between each pair of
 *              vertices.
 */
void Floyd(int local_mat[], int n, int p, int my_rank) {
   int int_city, local_int_city, local_city1, city2, root, j, temp;
   int* row_int_city;

   row_int_city = malloc(n*n*sizeof(int));


   for (int_city = 0; int_city < n; int_city++) {
      root = int_city/(n/p);
      if(my_rank == root){
         local_int_city = int_city % (n/p);
         for(j = 0; j < n; j++)
            row_int_city[j] = local_mat[local_int_city*n +j]; 
      }
      MPI_Bcast(row_int_city, n, MPI_INT, root, MPI_COMM_WORLD);
      for (local_city1 = 0; local_city1 < n/p; local_city1++)
         for (city2 = 0; city2 < n; city2++) {
               temp = (local_mat[local_city1*n + int_city] + row_int_city[city2]);
               if (temp < local_mat[local_city1*n + city2])
                  local_mat[local_city1*n + city2] = temp;
          }
     
#     ifdef SHOW_INT_MATS
      printf("After int_city = %d\n", int_city);
      Print_matrix(local_mat, n);
#     endif
    }
}  /* Floyd */

/*-------------------------------------------------------------------
 * Function:    min
 * Purpose:     Finds smaller of two ints
 * In arg:      two numbers located in matrix
 * In/out arg:  returns whichever int is smaller
 *              
 *             
 */
int min(int temp1, int temp2){
   if(temp1 < temp2){
      return 1;
   }
   else{
      return 0;
   }
} /*min*/


# Author:  	Mitchel Hally 
# Purpose: Return the r value calculated by the call to Recursive(i, j)
# Function:     Recursive
# C prototype:  long Recursive(long i, long j) 
# Args: 	i = rdi
#		j = rsi 
#
# Return Val: Recursive(i,j) = rax

        .section        .text
        .global Recursive
     
Recursive:
        push %rbp
        mov  %rsp, %rbp
        sub  $24, %rsp          
                                
        mov  %rdi, 8(%rsp)      # Save i = rdi on the stack 
        mov  %rsi, 16(%rsp)     # Save j = rsi on the stack          
        
        cmp  $0, %rdi           
                                
        jge   i_gt_0            # If rdi == i > 0, jump 
        
        sub  %rsi, %rdi		# i - j                       
        mov  %rdi, %rax   
        jmp  done               # Go to done
        	
i_gt_0:

        cmp  $0, %rsi           
        
        jge   j_gt_0            # If rsi == j > 0, jump
        
        sub  %rsi, %rdi
	mov  %rdi, %rax 
	 
        jmp  done               # Go to done
        
j_gt_0:
        # i & j > 0 
        sub  $1, %rdi           # i = i - 1
        mov  16(%rsp), %rsi	# Retrieve j 
        call Recursive
        
        mov  %rax, 0(%rsp)      # Save Recursive(i-1) on the stack
        mov  8(%rsp), %rdi      # Retrieve i
        sub  $1, %rsi		# j = j - 1
        call Recursive
        
        mov  16(%rsp), %rsi	# Retrieve j 
        add  0(%rsp), %rax      # return Recursive(i-1, j) + Recursive(i, j-1)
        

done:
        leave                   # Assigns rbp to rsp:  no need to
                                #    add 24 to rsp

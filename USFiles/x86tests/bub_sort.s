# Author:  	Mitchel Hally
# Purpose:	Sort a list using bubble sort
# Function:     Bubble_sort
# C prototype:  void Bubble_sort(long a[], long n)
# Args: a = rdi 
# 		n = rsi 
# Return Val: nothing


        .section	.text
        .global Bubble_sort
        
Bubble_sort: 
    	push %rbp
        mov  %rsp, %rbp
        
		# list_length = %rsi = %r8
		# list_length = n 
        mov  %rsi, %r12    
        
		# OUTER LOOP 
loop_tst1: 
		cmp  $2, %r12		# Compares list_length and 2 
		jl   done			# Jumps if %r12 < 2 

        # Current element in i = %r13
        mov  $0, %r13

		# INNER LOOP
loop_tst2:
		mov %r12, %r10			# %r10 = list_length
		sub $1, %r10			# %r10 = list_length - 1 
	
		cmp %r10, %r13   		# Compare list_length - 1 
					  			#to i 
		jge end_lp2	  			# if $r13 == i >= %r10 
					  			# == list_length - 1 
	
		mov  0(%rdi, %r13, 8), %rdx	# %rdx = a[i]
		mov  %r13, %r14				# i is placed in %r14
		add  $1, %r14				# compute %r14 = i + 1 
		mov  0(%rdi, %r14, 8), %rcx	# get %rcx = a[i+1]
	
		cmp %rdx, %rcx
		jl  swap # if (a[i] > a[i+1]) 
         			
end_lp:
		add $1, %r13	# i++ 
			
		jmp loop_tst2
				
end_lp2:
		sub  $1, %r12	# list_length-=1
		
		jmp loop_tst1 

		# SWAP METHOD 
swap: 
		mov  %rcx, 0(%rdi, %r13, 8)	# a[i] = a[i+1]
		mov  %rdx, 0(%rdi, %r14, 8)	# a[i+1] = a[i]
	
		jmp end_lp

done: 
		leave
		ret

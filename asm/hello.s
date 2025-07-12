.intel_syntax noprefix
.section .rodata
msg:
    .ascii "Hello, world!\n"
len = . - msg
filename:
	.ascii "Cargo.toml\0"

.section .bss
buffer:
    .space 400   

.section .text

.global hello 
hello:
	mov rdi, 1
    	lea rsi, [rip + msg] 
    	mov rdx, len
	mov rax, 1
	syscall
    	ret

.global sum
sum:
	mov rax, rdi
    	add rax, rsi
    	ret

.global shell
shell:
	xor rax, rax
	mov rdi, rax
	push rax
	movabs rbx, 0x68732f6e69622f
	push rbx
	mov rdi, rsp
	xor rsi, rsi
	xor rdx, rdx
	mov rax, 59
	syscall
	ret

.global file_size
file_size:
	mov rax, 257        
	mov r10, 0          
	mov rdx, 0          
	mov rsi, rdi        
	mov rdi, -100       
	syscall
	cmp rax, 0
	jl exit
	mov r9, rax
    	xor r8, r8
	jmp read
read:
	mov rdi, r9
	mov rax, 0
	mov rdx, 100
	lea rsi, [rip + buffer]
	syscall
	cmp rax, 0
	je done
	js exit
	add r8, rax
	jmp read
done: 
	mov rdi, r9
    	mov rax, 3
    	syscall
	
	mov rax, r8
	ret

.local exit
exit:
	ret

.global write_mmap
write_mmap:
	mov r14, rdi

	mov rax, 9            
	mov rdi, 0         
	mov rsi, 4096         
	mov rdx, 3            
	mov r10, 0x22      
	mov r8, -1            
	xor r9, r9            
	syscall

	cmp rax, -4095        
	jae exit              

	mov r12, rax          
	mov r13, r12

.copy_loop:
	movb al, byte ptr [r14]        
	movb byte ptr [r12], al        
	inc r14               
	inc r12               
	test al, al           
	jnz .copy_loop        

	mov rax, r13          
	ret

.local copy_file

.global write_file_mmap
write_file_mmap:
	mov rax, 257
	mov rsi, rdi
	mov rdi, -100 # dirfd = AT_FDCWD
	mov rdx, 0x42 # flags = O_RDWR (0x2) | O_CREAT (0x40) = 0x42
	mov r10, 0644
	syscall
	cmp rax, 0
	jl exit
	
	mov r12, rax # store fd

	mov rax, 8
	mov rdi, r12
	mov rsi, 0 
	mov rdx, 2 # SEEK_END = 2
	syscall

	mov r13, rax # store length

	mov rax, 8 # reset offset
	mov rdi, r12
	mov rsi, 0 
	mov rdx, 0 
	syscall

	mov rax, 9            
	mov rdi, 0         
	mov rsi, r13         
	mov rdx, 3            
	mov r10, 0x1      
	mov r8, r12            
	xor r9, r9            
	syscall
	
	cmp rax, -4095        
	jae exit   

	mov r13, rax

	ret



.intel_syntax noprefix
.section .rodata
msg:
    	.asciz "Hello, world!\n"
len = . - msg
fail_msg: 
	.asciz "Falhou\n"
fail_len = . - fail_msg
filename:
	.ascii "Cargo.toml\0"
sockaddr_in:
    .word 2              
    .word 0x5c11        
    .long 0x0100007f   
    .space 8          
reuseaddr_val:
    .int 1

.section .bss
buffer:
    	.space 400   
pipefd:
	.skip 8             
socketfd:
	.skip 4
clientfd:
	.skip 4

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
	mov rax, 60
	xor rdi, rdi
	syscall

.local fail
fail:
	mov eax, 1 
	mov edi, 1 
	lea rsi, [rip + fail_msg]
	mov edx, fail_len
	syscall

	mov eax, 60
	mov edi, 1 
	syscall

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

.global fork
fork:
	mov rax, 57
	syscall

	ret

.global pid
pid:
	mov rax, 39
	syscall

	ret

.global exec_program
exec_program:
	mov rax, 59         
	mov rdi, rdi        
	mov rsi, rsi        
	mov rdx, rdx        
	syscall

	ret

.global pipe 
pipe:
	mov rax, 22
	lea rdi, [rip + pipefd]
	syscall
	cmp rax, 0
	js exit

	mov rax, 1 
	mov edi, dword [rip + pipefd + 4]
	lea rsi, [rip + msg]
	mov edx, len
	syscall
	cmp rax, 0
	js exit

	mov rax, 0 
	mov edi, dword [rip + pipefd]
	lea rsi, [rip + buffer]
	mov edx, 400
	syscall

	mov rdx, rax
	mov rax, 1 
	mov rdi, 1 
	lea rsi, [rip + buffer]
	syscall

	mov rax, 3
	mov edi, dword [rip + pipefd]
	syscall

	mov rax, 3 
	mov edi, dword [rip + pipefd + 4]
	syscall

	ret

.global dup
dup:
	mov eax, 32
	mov rdi, 1 
	syscall

	mov edi, eax
	lea rsi, [rip + msg]
	mov edx, len
	mov eax, 1
	syscall

	ret

.global tcp_server
tcp_server:
	mov eax, 41
	mov edi, 2          
	mov esi, 1          
	xor edx, edx        
	syscall
	mov [rip + socketfd], eax

	mov eax, 54
	mov edi, [rip + socketfd]
	mov esi, 1 
	mov edx, 2 
	lea r10, [rip + reuseaddr_val]
	mov r8, 4 
	syscall
	
	mov eax, 49
	mov edi, [rip + socketfd]
	lea rsi, [rip + sockaddr_in]
	mov edx, 16
	syscall
	cmp rax, 0
	js fail
	
	mov eax, 50
	mov edi, [rip + socketfd]
	mov esi, 5
	syscall
	cmp rax, 0
	js fail

	mov eax, 43
	mov edi, [rip + socketfd]
	xor rsi, rsi
	xor rdx, rdx
	syscall
	cmp rax, 0
	js fail
	mov [rip + clientfd], eax

	mov eax, 1
	mov edi, [rip + clientfd]
	lea rsi, [rip + msg]
	mov edx, len
	syscall
	cmp rax, 0
	js fail

	mov eax, 3
	mov edi, [rip + socketfd]
	syscall

	mov eax, 3
	mov edi, [rip + clientfd]
	syscall
	ret

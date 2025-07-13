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
binsh:
	.asciz "/bin/bash"
fifo_path:
	.asciz "/tmp/myfifo"

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
	mov rdi, 1		# write
    	lea rsi, [rip + msg] 
    	mov rdx, len
	mov rax, 1
	syscall
    	
	jmp exit

.global sum
sum:
	mov rax, rdi
    	add rax, rsi
    	ret

.global shell
shell:
	mov rax, 59		# execve
	lea rdi, [rip + binsh]
	xor rsi, rsi
	xor rdx, rdx
	syscall
	ret

.global file_size
file_size:
	mov rax, 257		# openat
	mov r10, 0          
	mov rdx, 0          
	mov rsi, rdi        
	mov rdi, -100       
	syscall
	cmp rax, 0
	jl fail

	mov r12, rax

	mov rax, 8		# lseek  
	mov rdi, r12            
	xor rsi, rsi           
	mov rdx, 2            
	syscall

	mov r13, rax

	mov rax, 3		# close
	mov rdi, r12
	syscall

	mov rax, r13
	ret

.local exit
exit:
	mov rax, 60		# exit
	xor rdi, rdi
	syscall

.local fail
fail:
	mov eax, 1		# write 
	mov edi, 1 
	lea rsi, [rip + fail_msg]
	mov edx, fail_len
	syscall

	mov eax, 60		# exit
	mov edi, 1 
	syscall

.global write_mmap
write_mmap:
	mov r14, rdi

	mov rax, 9		# mmap            
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
	mov al, byte ptr [r14]        
	mov byte ptr [r12], al        
	inc r14               
	inc r12               
	test al, al           
	jnz .copy_loop        

	mov rax, r13          
	ret

.global write_file_mmap
write_file_mmap:
	mov rax, 257		# openat
	mov rsi, rdi
	mov rdi, -100 		# dirfd = AT_FDCWD
	mov rdx, 0x42 		# flags = O_RDWR (0x2) | O_CREAT (0x40) = 0x42
	mov r10, 0644
	syscall
	cmp rax, 0
	jl exit
	
	mov r12, rax

	mov rax, 8		# lseek
	mov rdi, r12
	mov rsi, 0 
	mov rdx, 2
	syscall

	mov r13, rax 

	mov rax, 8		# lseek 
	mov rdi, r12
	mov rsi, 0 
	mov rdx, 0 
	syscall

	mov rax, 9        	# mmap    
	mov rdi, 0         
	mov rsi, r13         
	mov rdx, 3            
	mov r10, 0x1      
	mov r8, r12            
	xor r9, r9            
	syscall
	
	cmp rax, -4095        
	jae fail   

	ret

.global fork
fork:
	mov rax, 57		# fork
	syscall

	ret

.global pid
pid:
	mov rax, 39		# getpid
	syscall

	ret

.global exec_program
exec_program:
	mov rax, 59		# execve        
	mov rdi, rdi        
	mov rsi, rsi        
	mov rdx, rdx        
	syscall

	ret

.global pipe 
pipe:
	mov rax, 22		# pipe
	lea rdi, [rip + pipefd]
	syscall
	cmp rax, 0
	js exit

	mov rax, 1 		# write
	mov edi, dword [rip + pipefd + 4]
	lea rsi, [rip + msg]
	mov edx, len
	syscall
	cmp rax, 0
	js exit

	mov rax, 0 		# read
	mov edi, dword [rip + pipefd]
	lea rsi, [rip + buffer]
	mov edx, 400
	syscall

	mov rdx, rax
	mov rax, 1 		# write
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
	mov eax, 32		# dup
	mov rdi, 1 
	syscall

	mov edi, eax
	lea rsi, [rip + msg]
	mov edx, len
	mov eax, 1		# write
	syscall

	ret

.global tcp_server
tcp_server:
	mov eax, 41		# socket
	mov edi, 2          
	mov esi, 1          
	xor edx, edx        
	syscall
	mov [rip + socketfd], eax

	mov eax, 54		# setsockopt
	mov edi, [rip + socketfd]
	mov esi, 1 
	mov edx, 2 
	lea r10, [rip + reuseaddr_val]
	mov r8, 4 
	syscall
	
	mov eax, 49		# bind
	mov edi, [rip + socketfd]
	lea rsi, [rip + sockaddr_in]
	mov edx, 16
	syscall
	cmp rax, 0
	js fail
	
	mov eax, 50		# listen
	mov edi, [rip + socketfd]
	mov esi, 5
	syscall
	cmp rax, 0
	js fail

	mov eax, 43		# accept
	mov edi, [rip + socketfd]
	xor rsi, rsi
	xor rdx, rdx
	syscall
	cmp rax, 0
	js fail
	mov [rip + clientfd], eax

	mov eax, 1		# write
	mov edi, [rip + clientfd]
	lea rsi, [rip + msg]
	mov edx, len
	syscall
	cmp rax, 0
	js fail

	mov eax, 3		# close
	mov edi, [rip + socketfd]
	syscall

	mov eax, 3		# close
	mov edi, [rip + clientfd]
	syscall
	ret

.global bind_shell
bind_shell:
	mov eax, 41		# socket
	mov edi, 2          
	mov esi, 1          
	xor edx, edx        
	syscall
	mov [rip + socketfd], eax

	mov eax, 54		# setsockopt
	mov edi, [rip + socketfd]
	mov esi, 1 
	mov edx, 2 
	lea r10, [rip + reuseaddr_val]
	mov r8, 4 
	syscall
	
	mov eax, 49		# bind
	mov edi, [rip + socketfd]
	lea rsi, [rip + sockaddr_in]
	mov edx, 16
	syscall
	cmp rax, 0
	js fail
	
	mov eax, 50		# listen
	mov edi, [rip + socketfd]
	mov esi, 5
	syscall
	cmp rax, 0
	js fail

	mov eax, 43		# accept
	mov edi, [rip + socketfd]
	xor rsi, rsi
	xor rdx, rdx
	syscall
	cmp rax, 0
	js fail
	mov [rip + clientfd], eax

	mov eax, 3		# close
	mov edi, [rip + socketfd]
	syscall
	
	mov eax, 33		# dup2
	mov edi, [rip + clientfd]
	xor esi, esi       
	syscall

	mov eax, 33		# dup2
	mov edi, [rip + clientfd]
	mov esi, 1
	syscall

	mov eax, 33		# dup2
	mov edi, [rip + clientfd]
	mov esi, 2
	syscall

	lea rdi, [rip + binsh]
	xor rsi, rsi
	xor rdx, rdx
	mov eax, 59		# execve
	syscall

	mov eax, 3		# close
	mov edi, [rip + clientfd]
	syscall
	ret

.local create_fifo
create_fifo: 
	mov rax, 133		# mknod
	lea rdi, [rip + fifo_path]
	mov rsi, 0x1000 | 0x1A4
	syscall

	ret

.global write_fifo
write_fifo:
	call create_fifo

	mov rax, 257		# openat
	lea rsi, [rip + fifo_path]
	mov rdi, -100 	# dirfd = AT_FDCWD
	mov rdx, 0x2 	# flags = O_RDWR (0x2)
	mov r10, r10
	syscall

	mov r12, rax

	mov rax, 1 		# write
	mov rdi, r12
	lea rsi, [rip + msg]
	mov edx, len
	syscall

	mov eax, 3		# close
	mov rdi, r12
	syscall

	jmp exit

	ret

.global read_fifo
read_fifo:
	call create_fifo
	
	mov rax, 257		# openat
	lea rsi, [rip + fifo_path]
	mov rdi, -100 	# dirfd = AT_FDCWD
	mov rdx, 0x2 	# flags = O_RDWR (0x2)
	mov r10, r10
	syscall
	cmp rax, 0 
	js fail

	mov r12, rax

	mov rax, 0 		# read
	mov rdi, r12
	lea rsi, [rip + buffer]
	mov edx, len
	syscall

	mov r12, rax

	mov rax, 1 		# write
	mov rdi, 1
	lea rsi, [rip + buffer]
	mov rdx, r12
	syscall

	jmp read_fifo



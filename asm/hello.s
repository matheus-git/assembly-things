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
    	lea rax, [rip + msg] 
    	mov rdx, len
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

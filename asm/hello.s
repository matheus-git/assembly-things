.intel_syntax noprefix
.section .data
msg:
    .ascii "Hello, world!\n"
len = . - msg

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

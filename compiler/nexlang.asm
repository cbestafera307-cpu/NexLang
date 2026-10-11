.section .bss
.align 4

input:
    .space 1024

output:
    .space 4

# Espaço para os textos dos registradores R0-R9
strings:
    .space 1024

.section .text
.globl _start

_start:
    # read(0, input, 1024)
    li a0, 0
    la a1, input
    li a2, 1024
    li a7, 63
    ecall

    blez a0, error

    # Finaliza a entrada com NUL
    la t0, input
    add t0, t0, a0
    sb zero, 0(t0)

    la s1, strings
    la s2, input

    # Começa a interpretar a primeira instrução
    mv t0, s2

check_instruction:
    lbu t1, 0(t0)
    beqz t1, success

    # Ignora linhas vazias e espaços
    li t2, 10
    beq t1, t2, next_line
    li t2, 32
    beq t1, t2, advance
    li t2, 9
    beq t1, t2, advance

    # STR?
    li t2, 83
    beq t1, t2, check_str

    # PRNT?
    li t2, 80
    beq t1, t2, check_prnt

    # MOV?
    li t2, 77
    beq t1, t2, check_mov

    j error

advance:
    addi t0, t0, 1
    j check_instruction

next_line:
    addi t0, t0, 1
    j check_instruction

check_str:
    lbu t1, 1(t0)
    li t2, 84
    bne t1, t2, error

    lbu t1, 2(t0)
    li t2, 82
    bne t1, t2, error

    addi t0, t0, 3
    j parse_str

check_prnt:
    lbu t1, 1(t0)
    li t2, 82
    bne t1, t2, error

    lbu t1, 2(t0)
    li t2, 78
    bne t1, t2, error

    lbu t1, 3(t0)
    li t2, 84
    bne t1, t2, error

    addi t0, t0, 4
    j parse_prnt

check_mov:
    # Esta versão reconhece MOV, mas ainda não
    # implementa a codificação nesta rotina.
    lbu t1, 1(t0)
    li t2, 79
    bne t1, t2, error

    lbu t1, 2(t0)
    li t2, 86
    bne t1, t2, error

    j error

# STR, R0, "texto"
parse_str:
    # Ignora espaços e vírgulas
str_skip:
    lbu t1, 0(t0)
    li t2, 32
    beq t1, t2, str_advance
    li t2, 9
    beq t1, t2, str_advance
    li t2, 44
    beq t1, t2, str_advance
    j str_register

str_advance:
    addi t0, t0, 1
    j str_skip

str_register:
    lbu t1, 0(t0)
    li t2, 82
    bne t1, t2, error

    lbu t1, 1(t0)
    addi t1, t1, -48
    bltz t1, error
    li t2, 9
    bgt t1, t2, error

    # Endereço do slot do registrador
    slli t2, t1, 7
    la s3, strings
    add s3, s3, t2

    addi t0, t0, 2

str_find_quote:
    lbu t1, 0(t0)
    beqz t1, error

    li t2, 34
    beq t1, t2, str_copy_start

    addi t0, t0, 1
    j str_find_quote

str_copy_start:
    addi t0, t0, 1
    mv s4, t0

str_copy_loop:
    lbu t1, 0(t0)
    li t2, 34
    beq t1, t2, str_copy_done
    beqz t1, error

    sb t1, 0(s3)
    addi s3, s3, 1
    addi t0, t0, 1
    j str_copy_loop

str_copy_done:
    sb zero, 0(s3)
    addi t0, t0, 1
    j check_instruction

# PRNT, R0 ou PRNT, "texto"
parse_prnt:
prnt_skip:
    lbu t1, 0(t0)
    li t2, 32
    beq t1, t2, prnt_advance
    li t2, 9
    beq t1, t2, prnt_advance
    li t2, 44
    beq t1, t2, prnt_advance
    j prnt_argument

prnt_advance:
    addi t0, t0, 1
    j prnt_skip

prnt_argument:
    li t2, 34
    beq t1, t2, prnt_direct

    # PRNT, R0
    li t2, 82
    bne t1, t2, error

    lbu t1, 1(t0)
    addi t1, t1, -48
    bltz t1, error
    li t2, 9
    bgt t1, t2, error

    slli t2, t1, 7
    la s3, strings
    add s3, s3, t2

    # Calcula tamanho da string
    mv a1, s3
    li a2, 0

prnt_reg_len:
    lbu t1, 0(s3)
    beqz t1, prnt_reg_write
    addi a2, a2, 1
    addi s3, s3, 1
    j prnt_reg_len

prnt_reg_write:
    li a0, 1
    li a7, 64
    ecall

    addi t0, t0, 2
    j check_instruction

prnt_direct:
    addi t0, t0, 1
    mv s3, t0

prnt_direct_len:
    lbu t1, 0(t0)
    beqz t1, error

    li t2, 34
    beq t1, t2, prnt_direct_write

    addi t0, t0, 1
    j prnt_direct_len

prnt_direct_write:
    sub a2, t0, s3
    li a0, 1
    mv a1, s3
    li a7, 64
    ecall

    addi t0, t0, 1
    j check_instruction

success:
    li a0, 0
    li a7, 93
    ecall

error:
    li a0, 1
    li a7, 93
    ecall

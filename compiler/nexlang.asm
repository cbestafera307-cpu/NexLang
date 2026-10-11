
.section .bss
.align 2
input:
    .space 128
output:
    .space 4

.section .text
.globl _start

_start:
    # read(0, input, 128)
    li a0, 0
    la a1, input
    li a2, 128
    li a7, 63
    ecall

    blez a0, error

    la t0, input

    # Reconhece "MOV"
    lbu t1, 0(t0)
    li t2, 77
    bne t1, t2, error

    lbu t1, 1(t0)
    li t2, 79
    bne t1, t2, error

    lbu t1, 2(t0)
    li t2, 86
    bne t1, t2, error

    addi t0, t0, 3

skip_spaces:
    lbu t1, 0(t0)
    li t2, 32
    beq t1, t2, next_space
    li t2, 9
    beq t1, t2, next_space
    j check_reg

next_space:
    addi t0, t0, 1
    j skip_spaces

check_reg:
    # Espera R0 ate R9
    lbu t1, 0(t0)
    li t2, 82
    bne t1, t2, error

    addi t0, t0, 1
    lbu t1, 0(t0)
    addi t1, t1, -48

    bltz t1, error
    li t2, 9
    bgt t1, t2, error

    # NexASM R0 -> RISC-V x5
    addi t3, t1, 5
    addi t0, t0, 1

skip_comma_spaces:
    lbu t1, 0(t0)
    li t2, 32
    beq t1, t2, next_comma_space
    li t2, 9
    beq t1, t2, next_comma_space
    j check_comma

next_comma_space:
    addi t0, t0, 1
    j skip_comma_spaces

check_comma:
    li t2, 44
    bne t1, t2, error
    addi t0, t0, 1

skip_number_spaces:
    lbu t1, 0(t0)
    li t2, 32
    beq t1, t2, next_number_space
    li t2, 9
    beq t1, t2, next_number_space
    j parse_number

next_number_space:
    addi t0, t0, 1
    j skip_number_spaces

parse_number:
    li t4, 0
    li s0, 0

digit_loop:
    lbu t1, 0(t0)
    addi t2, t1, -48
    bltz t2, number_done
    li t5, 9
    bgt t2, t5, number_done

    # valor = valor * 10 + digito
    slli t6, t4, 3
    slli t4, t4, 1
    add t4, t4, t6
    add t4, t4, t2

    li s0, 1
    addi t0, t0, 1
    j digit_loop

number_done:
    beqz s0, error

    # Limite inicial: imediato de 0 a 2047
    li t2, 2047
    bgt t4, t2, error

    # Codifica: ADDI rd, x0, imediato
    # formato: imm[11:0] | rs1 | funct3 | rd | opcode
    slli t4, t4, 20
    slli t3, t3, 7
    or t4, t4, t3
    ori t4, t4, 0x13

    # Escreve a palavra de 32 bits
    la t0, output
    sw t4, 0(t0)

    # write(1, output, 4)
    li a0, 1
    la a1, output
    li a2, 4
    li a7, 64
    ecall

    # exit(0)
    li a0, 0
    li a7, 93
    ecall

error:
    # exit(1)
    li a0, 1
    li a7, 93
    ecall

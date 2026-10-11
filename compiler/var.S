
.section .data
.align 3

.globl var_count
var_count:
    .quad 0

.globl var_capacity
var_capacity:
    .quad 0

.globl var_table
var_table:
    .quad 0

.section .text
.globl var_init
.globl var_grow

# Linux RISC-V 64
# Cada entrada da tabela ocupa 32 bytes.
# Campos:
# +0  = endereço do nome
# +8  = endereço do valor
# +16 = tipo (1=CHAR, 2=INT, 3=HEXA)
# +24 = tamanho do valor

var_init:
    # Capacidade inicial: 64 variáveis.
    li a0, 64
    sd a0, var_capacity, t0
    j var_grow

var_grow:
    # Solicita uma tabela maior usando mmap.
    # A capacidade é dobrada a cada crescimento.

    la t0, var_capacity
    ld t1, 0(t0)

    slli t2, t1, 1
    sd t2, 0(t0)

    # bytes = capacidade * 32
    slli a1, t2, 5

    # mmap(NULL, tamanho, PROT_READ|PROT_WRITE,
    #      MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
    li a0, 0
    li a2, 3
    li a3, 34
    li a4, -1
    li a5, 0
    li a7, 222
    ecall

    # Em caso de erro, retorna zero.
    bltz a0, var_alloc_error

    la t0, var_table
    sd a0, 0(t0)

    ret

var_alloc_error:
    li a0, 0
    ret

.section .text
.globl inpt

# INPT — receber entrada
# a0 = endereço do buffer
# a1 = tamanho do bloco
# Retorna em a0 a quantidade de bytes lidos
# ou um código de erro.

inpt:
    mv a2, a1
    mv a1, a0
    li a0, 0
    li a7, 63
    ecall
    ret

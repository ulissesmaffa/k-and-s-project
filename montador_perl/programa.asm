; Programa de Teste 1
; Autor Joao Leonardo Fragoso
nop
nop
nop
load r2 15; r2 <- mem(15)
store 14 r3; mem(14) <- r3
move r1 r2; r2 <- r1
sub r1 r2 r3; r3 <- r1 - r2
bneg 10; salta para 10 se negativo
branch 11; salta para 11
bzero 1; salta se zero para 1
bnzero 2; salta se não zero para 2 (nova instrucao)
bnneg 12; salta se não negativo para 12 (nova instrucao)
nop
add r1 r2 r3
sub r1 r2 r4
and r0 r0 r0
or r0 r0 r0
nop
Nop
Nop
Halt
HALT
mem 0; coloca 0 na memoria nesta posicao
mem 1; coloca 1 na memoria
mem 2; coloca 2 na memoria
mem 15;
mem -17
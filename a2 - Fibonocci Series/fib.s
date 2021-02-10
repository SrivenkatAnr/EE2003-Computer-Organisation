.global fib
fib:
    li a1, 0
    li a2, 1
    li a4, 1

loop:
    add a3, a2, a1 
    addi a1, a2, 0
    addi a2, a3, 0
    addi a4, a4, 1
    blt a4, a0, loop

end:
    addi a0, a3, 0   # Return result in reg a0
    jr ra       # Return address was stored by original call
    

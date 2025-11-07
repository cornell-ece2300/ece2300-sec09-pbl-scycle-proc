
  addi x1, x0, 256   # x1 holds base address of src0
  addi x2, x0, 272   # x2 holds base address of src1
  addi x3, x0, 288   # x3 holds base address of dest
  addi x4, x0, 4     # x4 holds size of arrays

loop:
  lw   x5, 0(x1)     # x5 = src0[i] <--------.
  lw   x6, 0(x2)     # x6 = src1[i]          |
  add  x7, x5, x6    # x7 = x5 + x6          |
  sw   x7, 0(x3)     # dest[i] = x7          |
  addi x1, x1, 4     # next element of src0  |
  addi x2, x2, 4     # next element of src1  |
  addi x3, x3, 4     # next element of dest  |
  addi x4, x4, -1    # x4 = x4 - 1           |
  bne  x4, x0, loop  # goto loop if x4 != 0 -'
  addi x0, x0, 0     # nop
  addi x0, x0, 0     # nop

  .data

  # src0 array
  .word 1
  .word 2
  .word 3
  .word 4

  # src1 array
  .word 5
  .word 6
  .word 7
  .word 8

  # dest array
  .word 0
  .word 0
  .word 0
  .word 0

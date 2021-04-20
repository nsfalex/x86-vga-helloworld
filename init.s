/*  init.s:
 *    A simple x86 VGA text mode hello world.
 *
 *
 */

.section .rodata

test_text: .asciz  "Hello World!"

vga_colors:               /* VGA hardware text mode colors */
  .long   0x00000000      /* Black          */
  .long   0x00000001      /* Blue           */
  .long   0x00000002      /* Green          */
  .long   0x00000003      /* Cyan           */
  .long   0x00000004      /* Red            */
  .long   0x00000005      /* Magenta        */
  .long   0x00000006      /* Brown          */
  .long   0x00000007      /* Light Grey     */
  .long   0x00000008      /* Dark Grey      */
  .long   0x00000009      /* Light Blue     */
  .long   0x0000000A      /* Light Green    */
  .long   0x0000000B      /* Light Cyan     */
  .long   0x0000000C      /* Light Red      */
  .long   0x0000000D      /* Light Magenta  */
  .long   0x0000000E      /* Light Brown    */
  .long   0x0000000F      /* White          */



.section .data

term_color:  .byte  0x0  /* VGA terminal text color     */
term_column: .word  0    /* Terminal column to print on */
term_row:    .word  0    /* Terminal row to print on    */



/****** Start executable code ******/


.section .text
  .global hello


/* Hello kernel world! */

hello:
  call init_term        /* Initialize terminal interfaces */
  lea  test_text, %ecx
  call vga_putstr
.L99:
  hlt
  jmp .L99


/* Initialize the terminal environment and blank the screen */

init_term:

  /* Set VGA terminal color */
  mov  (vga_colors), %ebx     /* background = VGA color: black      */
  lea  vga_colors, %eax
  mov  0x1c(%eax), %ecx       /* foreground = VGA color: light grey */
  call vga_setcolor           /* Set global VGA color variable      */

  /* Iterate through all possible columns on screen and clear them */
  xor %ecx, %ecx    /* Zero out ecx */
  mov $0x20, %ebx   /* ASCII 30: Space (' ') */

/* Increment rows */
.L1:
  xor %edx, %edx    /* Zero out edx */

/* Increment columns */
.L2:
  push %ecx
  push %edx
  call vga_writebuffer  /* Write the (empty) space to the screen */
  pop  %edx
  pop  %ecx

  inc  %edx             /* Increment column counter register     */
  cmp  $79, %edx
  jle  .L2              /* Current column <= VGA screen width?   */

  inc  %ecx             /* Increment row counter register    */
  cmp  $24, %ecx
  jle  .L1              /* Current row <= VGA screen height? */

  /* Set the next write pos to the top left of the terminal */
  movw $0, (term_row)
  movw $0, (term_column)
  ret


/*  vga_putstr: Writes a NULL terminated string to the VGA buffer
 *      ecx: Pointer to the string
 */

vga_putstr:
  movb (%ecx), %bl
  test %bl, %bl
  jz   .IF3
  push %ecx
  call vga_putchar
  pop  %ecx
  inc  %ecx
  jmp  vga_putstr

.IF3:
  ret


/*  vga_putchar: Write a character to screen
 *      ebx: Character to write
 */

vga_putchar:
  xor  %ecx, %ecx           /* Zero out ecx               */
  xor  %edx, %edx           /* Zero out edx               */
  movw (term_row), %cx      /* Current row to print on    */
  movw (term_column), %dx   /* Current column to print on */
  call vga_writebuffer      /* Write character to buffer  */
  movw (term_column), %ax   /* Column we just wrote to    */
  inc  %ax                  /* Increment column           */
  cmp  $79, %ax             /* 0 to 79 = 80 columns       */
  jg   .IF1                 /* Current column+1 > VGA screen width? */
  movw %ax, (term_column)   /* Put the column+1 into memory */
  ret

.IF1:
  movw $0, (term_column)    /* Return the column to write on to zero */
  movw (term_row), %ax      /* Put the current terminal row into eax */
  inc  %ax                  /* Increment row to next row on screen   */
  cmp  $24, %ax             /* 0 to 24 rows = 25 rows                */
  jg   .IF2                 /* Current row + 1 > VGA screen height?  */
  mov  $0, %eax             /* Yes? Restart from row 0 */

.IF2:
  mov  %ax, (term_row)      /* Move the new row into memory          */
  ret


/*  vga_writebuffer: Write a character to the VGA text mode buffer
 *      ebx: Character to write
 *      ecx: Row to write to
 *      edx: Column to write to
 */

vga_writebuffer:

  /* Starting off */
  push %ebx
  xor  %eax, %eax   /* Zero out eax */

  /* Prepare the 16-bit character to write */
  movb (term_color), %ah    /* Move the terminal color into eax' upper 8 bits */
  movb %bl, %al             /* Move the character into the lower 8 bits       */
  mov  %eax, %ebx           /* Put the character into ebx for later use       */

  /* Calculate memory address to write to */
  mov $80, %eax       /* VGA text mode terminal width         */
  mul %cl             /* Multiply row number by buffer width  */
  add %edx, %eax      /* Add the remaining columns onto that  */
  mov $2, %edx
  mul %edx            /* VGA text mode entries are 2 bytes    */
  add $0xB8000, %eax  /* Add the VGA text buffer base pointer */
  mov %eax, %ecx

  /* Put the character into the VGA text mode buffer */
  movw %bx, (%ecx)

  /* Finishing up */
  pop %ebx
  ret


/*  vga_setcolor: Set the global VGA text color variable to something sensible
 *      bx: Background color
 *      cx: Foreground color
 */

vga_setcolor:
  xor  %eax, %eax
  movb %bl, %al           /* Move the background color into eax */
  shl  $4, %eax           /* Shift the color into the most significant 4 bits */
  xor  %cl, %al           /* Put the fg color in the least significant 4 bits */
  movb %al, (term_color)  /* Write the finished color variable to memory      */
  ret


// vim: syntax=asm

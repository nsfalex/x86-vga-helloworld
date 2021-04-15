.section .data:
test_text:    .ascii  "Hello World!\n"
term_color:   .2byte  0x0       /* VGA terminal text color                 */
term_buff:    .4byte  0xB8000   /* VGA terminal buffer pointer
                                   We're able to write to this as an array */
term_column:  .word   0         /* Terminal column to print on */
term_row:     .word   0         /* Terminal row to print on    */
vga_width:    .word   80        /* VGA char buffer character width  */
vga_height:   .word   25        /* VGA char buffer character height */
vga_colors:                     /* VGA hardware text mode colors    */
  .word   0x0000                /* Black          */
  .word   0x0001                /* Blue           */
  .word   0x0002                /* Green          */
  .word   0x0003                /* Cyan           */
  .word   0x0004                /* Red            */
  .word   0x0005                /* Magenta        */
  .word   0x0006                /* Brown          */
  .word   0x0007                /* Light Grey     */
  .word   0x0008                /* Dark Grey      */
  .word   0x0009                /* Light Blue     */
  .word   0x000A                /* Light Green    */
  .word   0x000B                /* Light Cyan     */
  .word   0x000C                /* Light Red      */
  .word   0x000D                /* Light Magenta  */
  .word   0x000E                /* Light Brown    */
  .word   0x000F                /* White          */


.section .text:
  .global init_kernel

/* Kernel entrypoint after bootstrap, returning from here
   doesn't make much sense */
init_kernel:
  call init_term                /* Initialize terminal interfaces */
  movl 28(vga_colors), %ebx     /* Light grey */
  movl (vga_colors), %ecx       /* Black      */
  call set_color                /* Initialize term_color */
L99:
  hlt
  jmp  L99


/* init_term: initializes the VGA terminal environment */
init_term:
  push %ebx
  movl $0, (term_row)     /* Initialize the row to print on to zero     */
  movl $0, (term_column)  /* Initialize the column to print on to zero  */
  movl $0, %ecx           /* Initialize the ecx register */
  movl $0x20, %ebx        /* ASCII space (' ') character */
L1:                       /* Loop through every possible location on screen
                             and empty / initialize it   */
  movl $0, %edx           /* Initialize the edx register */
L2:
  call vga_putchar        /* Write the space character to screen        */
  inc  %edx               /* Increment character position               */
  cmp  (vga_width), %edx  /* Make sure we're not writing off the screen */
  jl   L2

  inc  %ecx                /* Increment row to write on                  */
  cmp  (vga_height), %ecx  /* Make sure we're not writing off the screen */
  jle  L1
  ret


/* vga_putchar: writes a character to the VGA character buffer
 *    ebx: character to write
 *    ecx: row to write to
 *    edx: column to write to
 */
vga_putchar:
  push %ebp                 /* Preserve the contents of the ebp register   */
  movl %esp, %ebp           /* Copy the current stack pointer into ebp     */
  sub  $2, %esp             /* allocate 2 bytes on the stack               */
  movl term_color, %eax     /* Move the terminal color into eax            */
  shl  $8, %eax             /* Shift the term color 8 bits to the left     */
  xor  term_color, %eax     /* Add the character onto the last byte of eax */
  movl %eax, 2(%esp)        /* Write the finished character onto the stack */
  movl %ecx, %eax           /* Move the row number into eax       */
  mul  (vga_width), %eax    /* Multiply with the screen's width   */
  addl %edx, %eax           /* Add column to get memory address   */
  movl 2(%esp), %eax        /* Write the character to the screen  */
  movl %ebp, %esp           /* Return the stack pointer to normal */
  pop  %ebp                 /* Return ebp to it's original state  */
  ret


/* set_color: sets the terminal's color
 *    ebx: foreground color
 *    ecx: background color
 */
set_color:
  shl  4, %ebx
  xor  %ecx, %ebx
  movl %ebx, term_color
  ret


strlen:
  cmp $0x0, %eax    /* Check if next character is a null byte */
  inc %eax          /* Increment eax to check next character  */
  jne strlen        /* Keep looping if that's not the case    */
  ret

// vim: syntax=asm

.section .data:
test_text:        .ascii  "Hello World!\n"
test_len:         .equ    $ - test_text
terminal_color:   .short  0x0       /* VGA terminal text color */
terminal_buff:    .double 0x0       /* VGA terminal buffer     */
terminal_column:  .short  0         /* Terminal column to print on */
terminal_row:     .short  0         /* Terminal row to print on    */
vga_width:        .short  80        /* VGA framebuffer character width  */
vga_height:       .short  25        /* VGA framebuffer character height */
vga_colors:                         /* VGA hardware text mode colors    */
  .short  0x0000                    /* Black          */
  .short  0x0001                    /* Blue           */
  .short  0x0002                    /* Green          */
  .short  0x0003                    /* Cyan           */
  .short  0x0004                    /* Red            */
  .short  0x0005                    /* Magenta        */
  .short  0x0006                    /* Brown          */
  .short  0x0007                    /* Light Grey     */
  .short  0x0008                    /* Dark Grey      */
  .short  0x0009                    /* Light Blue     */
  .short  0x000A                    /* Light Green    */
  .short  0x000B                    /* Light Cyan     */
  .short  0x000C                    /* Light Red      */
  .short  0x000D                    /* Light Magenta  */
  .short  0x000E                    /* Light Brown    */
  .short  0x000F                    /* White          */


.section .text:
  .global init_kernel

/* Replacement for the enter instruction, faster than
   the x86 base enter instruction

   allocbytes is the amount of bytes to allocate on the stack
   by moving stack pointer down in increments of 4 */
.macro enter allocbytes
  push %ebp
  mov  %ebp, %esp
  sub  %esp, 4(\allocbytes)
.endm

/* Subsequent leave macro */
.macro leave
  mov  %esp, %ebp
  pop  %ebp
.endm

/* Kernel entrypoint after bootstrap, returning from here
   doesn't make much sense */
init_kernel:
  call init_term        /* Initialize terminal interfaces */
  mov  %eax, test_text
  call strlen

init_term:
  movw (terminal_row),    0       /* Initialize terminal_row to zero    */
  movw (terminal_column), 0       /* Initialize terminal_column to zero */
  call set_color
  movw (terminal_color),  0       /* Initialize terminal_column to zero */
  movl (terminal_buff),   0xB8000 /* Initialize terminal_column to zero */

set_color:
  enter 2

  leave

strlen:
  strlenloop:
  cmp %eax, 0x0     /* Check if next character is a null byte */
  inc %eax          /* Increment eax to check next character  */
  jne strlenloop    /* Keep looping if that's not the case    */

/*  vim: syntax=asm
 */

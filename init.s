/*  init.s:
 *    A simple x86 VGA text mode hello world.
 *
 *
 */

.global init_kernel


.section .data:

test_text:    .asciz  "Hello World!\n"

term_color:  .word  0x0  /* VGA terminal text color     */
term_column: .word  0    /* Terminal column to print on */
term_row:    .word  0    /* Terminal row to print on    */

vga_colors:              /* VGA hardware text mode colors */
  .word   0x0000         /* Black          */
  .word   0x0001         /* Blue           */
  .word   0x0002         /* Green          */
  .word   0x0003         /* Cyan           */
  .word   0x0004         /* Red            */
  .word   0x0005         /* Magenta        */
  .word   0x0006         /* Brown          */
  .word   0x0007         /* Light Grey     */
  .word   0x0008         /* Dark Grey      */
  .word   0x0009         /* Light Blue     */
  .word   0x000A         /* Light Green    */
  .word   0x000B         /* Light Cyan     */
  .word   0x000C         /* Light Red      */
  .word   0x000D         /* Light Magenta  */
  .word   0x000E         /* Light Brown    */
  .word   0x000F         /* White          */



/****** Start executable code ******/


.section .text:


/* Hello kernel world! */

hello:
  call init_term    /* Initialize terminal interfaces */
L99:
  hlt
  jmp  L99


/* Initialize the terminal environment and blank the screen */

init_term:
  /* Set VGA terminal color */


/*  vga_putchar: Write a character to the VGA text mode buffer
 *      bx: Character to write
 *     ecx: Row to write to
 *     edx: Column to write to
 */

vga_putchar:

  /* Starting off */
  push %ebx
  xor  %eax, %eax   /* Zero out eax */

  /* Prepare the 16-bit character to write */
  movw (term_color), %eax   /* Move the terminal color into eax         */
  shl  $8, %eax             /* Shift the color to the upper 8 bits      */
  movb %bl, %al             /* Move the character into the lower 8 bits */
  mov  %eax, %ebx           /* Put the character into ebx for later use */

  /* Calculate memory address to write to */
  mov $80, %eax       /* VGA text mode terminal width         */
  mul %ecx            /* Multiply row number by buffer width  */
  add %edx, %eax      /* Add the remaining columns onto that  */
  add $0xB8000, %eax  /* Add the VGA text buffer base pointer */
  mov %eax, %ecx

  /* Put the character into the VGA text mode buffer */
  movw %ebx, (%ecx)

  /* Finishing up */
  pop %ebx
  ret


/*  vga_setcolor: Set the global VGA text color variable to something sensible
 *      bx: Background color
 *      cx: Foreground color
 */

vga_setcolor:
  movb %bl, %al           /* Move the background color into eax */
  shl  $4, %eax           /* Shift the color into the most significant 4 bits */
  xor  %cl, %al           /* Put the fg color in the least significant 4 bits */
  movb %al, (term_color)  /* Write the finished color variable to memory      */
  ret


// vim: syntax=asm

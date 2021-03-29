.section .data:
terminal_color: .short  0x0 /* VGA terminal text color */
terminal_buff:  .double 0x0 /* VGA terminal buffer */
vga_width:  .short    80  /* VGA framebuffer character width  */
vga_height: .short    25  /* VGA framebuffer character height */
vga_colors:               /* VGA hardware text mode colors    */
  .short  0x0000          /* Black          */
  .short  0x0001          /* Blue           */
  .short  0x0002          /* Green          */
  .short  0x0003          /* Cyan           */
  .short  0x0004          /* Red            */
  .short  0x0005          /* Magenta        */
  .short  0x0006          /* Brown          */
  .short  0x0007          /* Light Grey     */
  .short  0x0008          /* Dark Grey      */
  .short  0x0009          /* Light Blue     */
  .short  0x000A          /* Light Green    */
  .short  0x000B          /* Light Cyan     */
  .short  0x000C          /* Light Red      */
  .short  0x000D          /* Light Magenta  */
  .short  0x000E          /* Light Brown    */
  .short  0x000F          /* White          */


.section .text:
  .global init_kernel

/* Replacement for the enter instruction, faster than
   the x86 base enter instruction */
.macro enter
  push %ebp
  mov  %ebp, %esp
  sub  %esp, imm
.endm

/* Subsequent leave macro */
.macro leave
  mov  %esp, %ebp
  pop  %ebp
.endm

/* Kernel entrypoint after bootstrap */
init_kernel:
  ret


strlen:
  enter
  leave


/*
  vim: syntax=asm
*/

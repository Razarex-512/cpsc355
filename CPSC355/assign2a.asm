// Modified Program for Integer Multiplication

// Strings definition
init_msg:      .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d) \n\n"
prod_msg:      .string "product = 0x%08x  multiplier = 0x%08x\n"
final_result:  .string "64-bit result = 0x%016lx (%ld)\n"

// Macros redefinition
define(ZERO_FLAG, 0) 
define(ONE_FLAG, 1) 
define(mult_reg, w19) 
define(multcand_reg, w20) 
define(prod_reg, w21) 
define(loop_counter, w22)
define(sign_flag, w23)
define(full_result, x24)
define(shift_temp1, x25)
define(shift_temp2, x26)
define(prod_64, x21)
define(mult_64, x19)

        .balign 4
        .global main
main:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp
	//initialize values
        mov     multcand_reg, -16843010 //initialize multiplicand
        mov     mult_reg, 70 //initialize multiplier
        mov     prod_reg, 0 //set prod to 0
        mov     loop_counter, 0 //initialize loop counter

        // Initial values print
        adrp    x0, init_msg
        add     x0, x0, :lo12:init_msg
        mov     w1, mult_reg
        mov     w2, mult_reg
        mov     w3, multcand_reg
        mov     w4, multcand_reg
        bl      printf

        cmp     mult_reg, 0 //check if value is neg or pos
        b.ge    start
        mov     sign_flag, ONE_FLAG

start:
        mov     loop_counter, 0
        b       condition_check

multiply_loop:
        tst     mult_reg, 0x1 //compare multiplier to 1
        b.eq    next_step // branch to next step if different
        add     prod_reg, prod_reg, multcand_reg //add if same

next_step:
        asr     mult_reg, mult_reg, 1 //asr by 1 of multiplier
        tst     prod_reg, 0x1 //compare product with 1
        b.eq    adjust_mult //if not eq branch to adjust mult
        orr     mult_reg, mult_reg, 0x80000000 //execute orr if equal
        b       shift_prod //branch to prod shift
adjust_mult:
        and     mult_reg, mult_reg, 0x7FFFFFFF

shift_prod:
        asr     prod_reg, prod_reg, 1 //asr of prod by 1
        add     loop_counter, loop_counter, 1 // increment

condition_check:
        cmp     loop_counter, 32 // compare loop count with 32
        b.lt    multiply_loop //if i less than 32 branch to multiplication loop
        cmp     sign_flag, ONE_FLAG //see if sign flag is true
        b.ne    print_result //if not equal branch to print module
        sub     prod_reg, prod_reg, multcand_reg //execute sub statement

print_result://print statement
        adrp    x0, prod_msg
        add     x0, x0, :lo12:prod_msg
        mov     w1, prod_reg
        mov     w2, mult_reg
        bl      printf

        // Convert product to 64-bit
        sxtw    shift_temp1, prod_reg
        and     shift_temp1, prod_64, 0xFFFFFFFF
        lsl     shift_temp1, shift_temp1, 32
        // Convert multiplier to 64-bit
        sxtw    shift_temp2, mult_reg
        and     shift_temp2, mult_64, 0xFFFFFFFF
        add     full_result, shift_temp1, shift_temp2

        // Final result print
        adrp    x0, final_result
        add     x0, x0, :lo12:final_result
        mov     x1, full_result
        mov     x2, full_result
        bl      printf

finish://reset stack
        mov     w0, 0
        ldp     x29, x30, [sp], 16
        ret


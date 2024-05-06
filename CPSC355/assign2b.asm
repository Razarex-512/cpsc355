// ASSIGNMENT 2B

// Section for defining output strings
start_msg:    .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d) \n\n" // Initial message format string
mid_msg:      .string "product = 0x%08x  multiplier = 0x%08x\n" // Mid-operation message format string
end_msg:      .string "64-bit result = 0x%016lx (%ld)\n" // Final result message format string

// Macro definitions with new names for readability and uniqueness
define(NO,0) // Define NO as 0, used for boolean logic
define(YES,1) // Define YES as 1, used for boolean logic
define(op_factor, w19) // Define op_factor as w19, representing the multiplier
define(op_multiplicand,w20) // Define op_multiplicand as w20, representing the multiplicand
define(op_product, w21) // Define op_product as w21, initially 0, will hold the intermediate product
define(counter, w22) // Define counter as w22, used for loop iteration
define(isNegative, w23) // Define isNegative as w23, flag for negative multiplier handling
define(compound_result, x24) // Define compound_result as x24, will hold the final 64-bit result
define(bridge1, x25) // Define bridge1 as x25, used for 64-bit conversion steps
define(bridge2, x26) // Define bridge2 as x26, used for 64-bit conversion steps
define(long_product,x21) // Re-define long_product as x21 for clarity, for 64-bit product
define(long_multiplier,x19) // Re-define long_multiplier as x19 for clarity, for 64-bit multiplier

        .balign 4 // Align the following instructions on a 4-byte boundary for performance
        .global main // Declare the main function as an entry point visible outside
main:
        stp     x29, x30, [sp, -16]! // Save the frame pointer and link register on the stack
        mov     x29, sp // Set the frame pointer to the current stack pointer

        // Initialize variables with specific values
        mov     op_multiplicand, 522133279 // Set multiplicand to a specific value
        mov     op_factor, 200 // Set multiplier to a specific value
        mov     op_product, 0 // Initialize product to 0
        mov     counter, 0 // Initialize loop counter to 0

        // Print initial values using printf
        adrp    x0, start_msg // Load address of the start_msg string
        add     x0, x0, :lo12:start_msg // Add lower 12 bits of start_msg address to x0
        mov     w1, op_factor // Move multiplier value to w1
        mov     w2, op_factor // Duplicate multiplier value to w2 for printf
        mov     w3, op_multiplicand // Move multiplicand value to w3
        mov     w4, op_multiplicand // Duplicate multiplicand value to w4 for printf
        bl      printf // Call printf to print the initial message

        // Check if the multiplier is negative
        cmp     op_factor, 0 // Compare multiplier with 0
        b.ge    operation_start // If greater or equal to 0, proceed to operation_start
        mov     isNegative, YES // If less than 0, set isNegative to YES
operation_start:
        mov     counter, 0 // Reset the counter to 0 for the loop
        b       pre_loop_check // Jump to loop condition check
process_loop:
        // Multiply operation begins
        tst     op_factor, 0x1 // Test the least significant bit of the multiplier
        b.eq    post_add_check // If LSB is 0, skip addition
        add     op_product, op_product, op_multiplicand // Add multiplicand to product if LSB is 1
post_add_check:
        // Right shift operations and checks
        asr     op_factor, op_factor, 1 // Arithmetic right shift on the multiplier
        tst     op_product, 0x1 // Test LSB of product for conditional logic
        b.eq    post_product_adjust // If LSB is 0, move to adjust the product
        orr     op_factor, op_factor, 0x80000000 // Set the MSB of multiplier if LSB of product was 1
        b       shift_product // Jump to shift the product
post_product_adjust:
        and     op_factor, op_factor, 0x7FFFFFFF // Clear the MSB of multiplier if necessary
shift_product:
        asr     op_product, op_product, 1 // Arithmetic right shift on the product
        add     counter, counter, 1 // Increment the counter for loop control
pre_loop_check:
        cmp     counter, 32 // Compare the counter with 32 to check loop termination
        b.lt    process_loop // If counter is less than 32, continue the loop
        cmp     isNegative, YES // Check if the multiplier was negative
        b.ne    output_result // If not negative, proceed to print the result
        sub     op_product, op_product, op_multiplicand // Adjust the product if multiplier was negative
output_result:
        // Print the intermediate result
        adrp    x0, mid_msg // Load address of the mid-operation message
        add     x0, x0, :lo12:mid_msg // Adjust address for the lower 12 bits
        mov     w1, op_product // Prepare product for printing
        mov     w2, op_factor // Prepare adjusted multiplier for printing
        bl      printf // Call printf to print the message

        // Convert to 64-bit format for final result
        sxtw    bridge1, op_product // Sign-extend the product to 64 bits
        and     bridge1, long_product, 0xFFFFFFFF // Isolate lower 32 bits of the product
        lsl     bridge1, bridge1, 32 // Shift left by 32 bits for high part
        sxtw    bridge2, op_factor // Sign-extend the multiplier to 64 bits
        and     bridge2, long_multiplier, 0xFFFFFFFF // Isolate lower 32 bits of the multiplier
        add     compound_result, bridge1, bridge2 // Combine the two 32-bit values for the 64-bit result

        // Print the final 64-bit result
        adrp    x0, end_msg // Load address of the final message string
        add     x0, x0, :lo12:end_msg // Adjust for the lower 12 bits of address
        mov     x1, compound_result // Prepare 64-bit result for printing
        mov     x2, compound_result // Duplicate 64-bit result for printf
        bl      printf // Call printf to print the final result
finish:
        mov     w0, 0
	ldp x29,x30,[sp],16
	ret


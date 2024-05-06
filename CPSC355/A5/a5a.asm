// Syed Raza - 30198389
// CPSC 355 - Assignment 5: Custom Queue Implementation in ARMv8

// Queue Configuration Constants
QUEUE_SIZE = 8               // Define queue size
MOD_MASK = 0x7               // Mask for modulo operation by queue size
BOOL_FALSE = 0               // Boolean false value
BOOL_TRUE = 1                // Boolean true value

// Register Aliases for Queue Management
headRegister    .req    x19  // Request register for head index of the queue
tailRegister    .req    x20  // Request register for tail index of the queue
queueRegister   .req    x25  // Request register for queue array

// Global Variables Initialization
.data                        // Data section for initialized data
    .global   headMemory     // Declare head index global variable
headMemory:   .word   -1     // Initialize head index to -1 (empty queue)
    .global   tailMemory     // Declare tail index global variable
tailMemory:   .word   -1     // Initialize tail index to -1 (empty queue)

.bss                         // Block Started by Symbol section for uninitialized data
    .global   queueMemory    // Declare queue array global variable
queueMemory:  .skip     QUEUE_SIZE * 4  // Allocate space for queue array

// Text Section for Print Format Strings
.text                        // Text section for code and literals
formatString1: .string "\nQueue underflow! Cannot dequeue from an empty queue. \n"  // Format string for queue underflow
formatString2: .string "\nQueue overflow! Cannot enqueue value into a full queue.\n" // Format string for queue overflow
formatString3: .string "\nEmpty queue\n"              // Format string for empty queue
formatString4: .string "\nCurrent queue contents:"    // Format string for displaying queue contents
formatString5: .string " %d"                          // Format string for integer values
formatString6: .string " <-- head"                    // Format string for head indicator
formatString7: .string " <-- tail"                    // Format string for tail indicator
formatString8: .string "\n"                           // Format string for newline

// Enqueue Function
.balign 4                   // Align the code to a 4-byte boundary
.global enqueue             // Make the enqueue function global
enqueue:                    // Define the start of the enqueue function
    stp     x29, x30, [sp, -16]!   // Save the frame pointer and return address on the stack
    mov     x29, sp                // Set the frame pointer to the current stack pointer

    mov     w22, w0                // Move the value to be enqueued into w22

    bl      queueFull              // Call the queueFull function to check if the queue is full
    cmp     w0, BOOL_FALSE         // Compare the result with BOOL_FALSE
    b.eq    continueEnqueue        // If queue is not full, continue to enqueue

    adrp    x0, formatString2      // Load the address of the queue overflow format string
    add     x0, x0, :lo12:formatString2  // Add the low 12 bits of the address
    bl      printf                 // Call printf to print the overflow message
    b       endEnqueue             // Jump to the end of the enqueue function

continueEnqueue:                   // Label for continuing enqueue operation
    bl      queueEmpty             // Call the queueEmpty function to check if the queue is empty
    cmp     w0, BOOL_FALSE         // Compare the result with BOOL_FALSE
    b.eq    firstElementEnqueue    // If queue is empty, jump to firstElementEnqueue

    mov     w9, 0                  // Set w9 to 0

    adrp    headRegister, headMemory   // Load the address of the head index variable
    add     headRegister, headRegister, :lo12:headMemory // Add the low 12 bits of the address
    str     w9, [headRegister]         // Store 0 in the head index (resetting it)

    adrp    tailRegister, tailMemory   // Load the address of the tail index variable
    add     tailRegister, tailRegister, :lo12:tailMemory // Add the low 12 bits of the address
    str     w9, [tailRegister]         // Store 0 in the tail index (resetting it)

    ldr     w24, [tailRegister]        // Load the current tail index into w24

    adrp    queueRegister, queueMemory // Load the address of the queue array
    add     queueRegister, queueRegister, :lo12:queueMemory // Add the low 12 bits of the address
    str     w22, [queueRegister, w24, SXTW 2] // Store the value to be enqueued at the current tail position

    b       endEnqueue                 // Jump to the end of the enqueue function

firstElementEnqueue:                   // Label for enqueuing the first element
    adrp    tailRegister, tailMemory   // Load the address of the tail index variable
    add     tailRegister, tailRegister, :lo12:tailMemory // Add the low 12 bits of the address
    ldr     w24, [tailRegister]        // Load the current tail index into w24

    add     w24, w24, 1                // Increment the tail index
    str     w24, [tailRegister]        // Store the incremented tail index

    adrp    queueRegister, queueMemory // Load the address of the queue array
    add     queueRegister, queueRegister, :lo12:queueMemory // Add the low 12 bits of the address
    str     w22, [queueRegister, w24, SXTW 2] // Store the value to be enqueued at the new tail position

endEnqueue:                             // Label for the end of the enqueue function
    ldp     x29, x30, [sp], 16          // Restore the frame pointer and return address from the stack
    ret                                // Return from the function

// Dequeue Function
.balign 4                   // Align the code to a 4-byte boundary
.global dequeue             // Make the dequeue function global
dequeue:                    // Define the start of the dequeue function
    stp       x29, x30, [sp, -16]! // Save the frame pointer and return address on the stack
    mov       x29, sp              // Set the frame pointer to the current stack pointer

    bl        queueEmpty           // Call the queueEmpty function to check if the queue is empty
    cmp       w0, BOOL_FALSE       // Compare the result with BOOL_FALSE
    b.eq      continueDequeue      // If queue is not empty, continue to dequeue

    adrp      x0, formatString1    // Load the address of the queue underflow format string
    add       x0, x0, :lo12:formatString1 // Add the low 12 bits of the address
    bl        printf               // Call printf to print the underflow message
    mov       w0, -1               // Set the return value to -1 (indicate error)
    b         endDequeue           // Jump to the end of the dequeue function

continueDequeue:                   // Label for continuing dequeue operation
    adrp      headRegister, headMemory // Load the address of the head index variable
    add       headRegister, headRegister, :lo12:headMemory // Add the low 12 bits of the address
    ldr       w9, [headRegister]      // Load the current head index into w9

    adrp      tailRegister, tailMemory // Load the address of the tail index variable
    add       tailRegister, tailRegister, :lo12:tailMemory // Add the low 12 bits of the address
    ldr       w10, [tailRegister]      // Load the current tail index into w10

    adrp      queueRegister, queueMemory // Load the address of the queue array
    add       queueRegister, queueRegister, :lo12:queueMemory // Add the low 12 bits of the address
    ldr       w11, [queueRegister, w9, SXTW 2] // Load the value at the head position into w11
    mov       w0, w11               // Move the dequeued value into w0 (return value)

    cmp       w9, w10               // Compare the head and tail indices
    b.eq      resetQueue            // If they are equal, the queue is now empty, so reset

    add       w9, w9, 1             // Increment the head index
    and       w9, w9, MOD_MASK      // Wrap the head index around using the modulo mask
    str       w9, [headRegister]    // Store the updated head index

    b         endDequeue            // Jump to the end of the dequeue function

resetQueue:                         // Label for resetting the queue
    mov       w12, -1               // Set w12 to -1
    str       w12, [headRegister]   // Reset the head index to -1
    str       w12, [tailRegister]   // Reset the tail index to -1

endDequeue:                         // Label for the end of the dequeue function
    ldp       x29, x30, [sp], 16    // Restore the frame pointer and return address from the stack
    ret                            // Return from the function

// Check if Queue is Full
queueFull:
    stp       x29, x30, [sp, -16]! // Save the frame pointer and return address on the stack
    mov       x29, sp              // Set the frame pointer to the current stack pointer

    adrp      headRegister, headMemory // Load the address of the head index variable
    add       headRegister, headRegister, :lo12:headMemory // Add the low 12 bits of the address
    ldr       w9, [headRegister]      // Load the current head index into w9

    adrp      tailRegister, tailMemory // Load the address of the tail index variable
    add       tailRegister, tailRegister, :lo12:tailMemory // Add the low 12 bits of the address
    ldr       w10, [tailRegister]      // Load the current tail index into w10

    add       w10, w10, 1             // Increment the tail index
    and       w10, w10, MOD_MASK      // Wrap the tail index around using the modulo mask

    cmp       w9, w10                 // Compare the incremented and wrapped tail index with the head index
    b.ne      notFull                 // If they are not equal, the queue is not full
    mov       w0, BOOL_TRUE           // Set the return value to BOOL_TRUE (queue is full)
    b         endCheckFull            // Jump to the end of the queueFull function

notFull:                              // Label for queue not being full
    mov       w0, BOOL_FALSE          // Set the return value to BOOL_FALSE (queue is not full)

endCheckFull:                         // Label for the end of the queueFull function
    ldp       x29, x30, [sp], 16      // Restore the frame pointer and return address from the stack
    ret                               // Return from the function

// Check if Queue is Empty
queueEmpty:
    stp       x29, x30, [sp, -16]! // Save the frame pointer and return address on the stack
    mov       x29, sp              // Set the frame pointer to the current stack pointer

    adrp      headRegister, headMemory // Load the address of the head index variable
    add       headRegister, headRegister, :lo12:headMemory // Add the low 12 bits of the address
    ldr       w9, [headRegister]      // Load the current head index into w9
    cmp       w9, -1                  // Compare the head index with -1 (indicating an empty queue)
    b.ne      notEmpty                // If the head index is not -1, the queue is not empty
    mov       w0, BOOL_TRUE           // Set the return value to BOOL_TRUE (queue is empty)
    b         endCheckEmpty           // Jump to the end of the queueEmpty function

notEmpty:                             // Label for queue not being empty
    mov       w0, BOOL_FALSE          // Set the return value to BOOL_FALSE (queue is not empty)

endCheckEmpty:                        // Label for the end of the queueEmpty function
    ldp       x29, x30, [sp], 16      // Restore the frame pointer and return address from the stack
    ret                               // Return from the function

// Display Queue Contents
.balign 4                 // Align the code to a 4-byte boundary
.global display           // Make the display function global
display:                  // Define the start of the display function
    stp       x29, x30, [sp, -16]! // Save the frame pointer and return address on the stack
    mov       x29, sp              // Set the frame pointer to the current stack pointer
    mov       w9, 0                // Initialize w9 to 0
    bl        queueEmpty           // Call the queueEmpty function to check if the queue is empty
    cmp       w0, BOOL_FALSE       // Compare the result with BOOL_FALSE
    b.eq      continueDisplay      // If queue is not empty, continue to display

    adrp      x0, formatString3    // Load the address of the empty queue format string
    add       x0, x0, :lo12:formatString3 // Add the low 12 bits of the address
    bl        printf               // Call printf to print the empty queue message
    b         endDisplay           // Jump to the end of the display function

continueDisplay:                  // Label for continuing display operation
    adrp      headRegister, headMemory // Load the address of the head index variable
    add       headRegister, headRegister, :lo12:headMemory // Add the low 12 bits of the address
    ldr       w10, [headRegister]     // Load the current head index into w10

    mov       w21, w10                // Move the head index into w21

    adrp      tailRegister, tailMemory // Load the address of the tail index variable
    add       tailRegister, tailRegister, :lo12:tailMemory // Add the low 12 bits of the address
    ldr       w11, [tailRegister]      // Load the current tail index into w11

    mov       w26, 0                   // Initialize w26 to 0
    sub       w27, w11, w10            // Calculate the difference between tail and head indices
    add       w27, w27, 1              // Increment the difference by 1 to get the number of elements

    cmp       w27, 0                   // Compare the number of elements with 0
    b.gt      startDisplayLoop         // If the number of elements is greater than 0, start the display loop
    add       w27, w27, QUEUE_SIZE     // Adjust the number of elements for wrap-around case

startDisplayLoop:                     // Label for starting the display loop
    adrp      x0, formatString4        // Load the address of the current queue contents format string
    add       x0, x0, :lo12:formatString4 // Add the low 12 bits of the address
    bl        printf                   // Call printf to print the current queue contents message

    adrp      queueRegister, queueMemory // Load the address of the queue array
    add       queueRegister, queueRegister, :lo12:queueMemory // Add the low 12 bits of the address

    b         loopTest                 // Jump to the loop test

displayLoop:                           // Label for the display loop
    adrp        x0, formatString8       // Load the address of the newline format string
    add         x0, x0, :lo12:formatString8 // Add the low 12 bits of the address
    bl          printf                  // Call printf to print a newline

    adrp      x0, formatString5         // Load the address of the integer value format string
    add       x0, x0, :lo12:formatString5 // Add the low 12 bits of the address

    ldr       w1, [queueRegister, w21, SXTW 2] // Load the current queue element into w1
    bl        printf                       // Call printf to print the current queue element

    cmp       w21, w10                     // Compare the current index with the head index
    b.ne      nextElement                  // If not at the head index, jump to nextElement

    adrp      x0, formatString6            // Load the address of the head indicator format string
    add       x0, x0, :lo12:formatString6 // Add the low 12 bits of the address
    bl        printf                       // Call printf to print the head indicator

nextElement:                              // Label for processing the next element
    add         w21, w21, 1               // Increment the current index
    and         w21, w21, MOD_MASK        // Wrap the current index around using the modulo mask
    add         w26, w26, 1               // Increment the element count

loopTest:                                // Label for the loop test
    cmp         w26, w27                  // Compare the element count with the total number of elements
    b.lt        displayLoop               // If less, continue the display loop

    adrp      x0, formatString7           // Load the address of the tail indicator format string
    add       x0, x0, :lo12:formatString7 // Add the low 12 bits of the address
    bl        printf                      // Call printf to print the tail indicator

endDisplay:                              // Label for the end of the display function
    ldp       x29, x30, [sp], 16          // Restore the frame pointer and return address from the stack
    ret                                 // Return from the function


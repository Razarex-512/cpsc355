        // Define macros for boolean values
        define(FALSE, 0)
        define(TRUE, 1)

        // String templates for printing cuboid details
infoPrint:      .string "%s Cuboid's Origin = (%d, %d) Base width = %d Base length = %d Height = %d Volume = %d\n"
startPrint:     .string "Initial cuboid values:\n"
updatePrint:    .string "\nChanged cuboid values:\n"

        // Label strings for identifying cuboids
labelOne:       .string "first"
labelTwo:       .string "second"

        .balign 4                           // Align data on a 4-byte boundary

        // Equates for struct Point
        posX = 0                            // X offset in Point struct
        posY = 4                            // Y offset in Point struct
        sizePoint = 8                       // Total size of Point struct

        // Equates for struct Cuboid
        originCub = 0                       // Origin offset in Cuboid struct
        baseCub = 8                         // Base dimensions offset in Cuboid struct
        heightCub = 16                      // Height offset in Cuboid struct
        volumeCub = 20                      // Volume offset in Cuboid struct

        // Equates for struct Dimension
        width = 0                           // Width offset in Dimension struct
        length = 4                          // Length offset in Dimension struct
        sizeDim = 8                         // Total size of Dimension struct

        // Memory allocation equates
        baseOffset = 16                     // Base offset for cuboid in memory

        // Equates for managing cuboids
        cubOne = 20                         // Offset for first cuboid
        cubTwo = 20                         // Offset for second cuboid
        totalMem = baseCub                  // Total memory for base of cuboid

        // Allocation and deallocation sizes
        spaceAlloc = -(16 + totalMem) & -16 // Total space allocated, aligned to 16 bytes
        spaceFree = -spaceAlloc             // Total space to free, negated value of spaceAlloc
        cubSize = 16                        // Size for a cuboid's data
        cubOneOffset = 128                  // Offset for the first cuboid's data
        cubTwoOffset = 36                   // Offset for the second cuboid's data

        // Function to create and initialize a new Cuboid
initCuboid:
        stp x29, x30, [sp, spaceAlloc]!     // Save frame pointer, link register and allocate stack space
        mov x29, sp                         // Set frame pointer to the start of the stack frame

        // Initialize cuboid origin to (0, 0)
        mov w1, 0                           // Set origin X to 0
        str w1, [x29, cubSize + originCub + posX] // Store origin X in struct

        mov w2, 0                           // Set origin Y to 0
        str w2, [x29, cubSize + originCub + posY] // Store origin Y in struct

        // Set base dimensions to 2x2
        mov w3, 2                           // Set base width to 2
        str w3, [x29, cubSize + baseCub + width] // Store base width in struct

        mov w4, 2                           // Set base length to 2
        str w4, [x29, cubSize + baseCub + length] // Store base length in struct

        // Set cuboid height to 3
        mov w5, 3                           // Set height to 3
        str w5, [x29, cubSize + heightCub] // Store height in struct

        // Calculate and store volume of the cuboid
        mul w6, w3, w4                      // Calculate base area (width * length)
        mul w6, w5, w6                      // Calculate volume (base area * height)
        str w6, [x29, cubSize + volumeCub]  // Store volume in struct

        // Copy the initialized cuboid data back to the caller's space
        ldr w9, [x29, cubSize + originCub + posX] // Load origin X from struct
        str w9, [x8, originCub + posX]            // Store origin X in caller's space

        ldr w9, [x29, cubSize + originCub + posY] // Load origin Y from struct
        str w9, [x8, originCub + posY]            // Store origin Y in caller's space

        ldr w9, [x29, cubSize + baseCub + width]  // Load base width from struct
        str w9, [x8, baseCub + width]              // Store base width in caller's space

        ldr w9, [x29, cubSize + baseCub + length]  // Load base length from struct
        str w9, [x8, baseCub + length]              // Store base length in caller's space

        ldr w9, [x29, cubSize + heightCub]         // Load height from struct
        str w9, [x8, heightCub]                    // Store height in caller's space

        ldr w9, [x29, cubSize + volumeCub]         // Load volume from struct
        str w9, [x8, volumeCub]                    // Store volume in caller's space

        ldp x29, x30, [sp], spaceFree              // Restore frame pointer, link register and deallocate stack space
        ret                                        // Return to caller

        // Function to move a cuboid by delta X and Y
shift:
        stp x29, x30, [sp, -16]!                    // Save frame pointer, link register and allocate stack space
        mov x29, sp                                 // Set frame pointer to the start of the stack frame

        // Update cuboid's origin by deltaX and deltaY
        ldr w9, [x0, originCub + posX]              // Load current origin X
        add w9, w9, w1                              // Add deltaX to origin X
        str w9, [x0, originCub + posX]              // Store updated origin X

        ldr w10, [x0, originCub + posY]             // Load current origin Y
        add w10, w10, w2                            // Add deltaY to origin Y
        str w10, [x0, originCub + posY]             // Store updated origin Y

        ldp x29, x30, [sp], 16                      // Restore frame pointer, link register and deallocate stack space
        ret                                         // Return to caller

        // Function to scale a cuboid by a factor
adjustScale:
        stp x29, x30, [sp, -16]!                    // Save frame pointer, link register and allocate stack space
        mov x29, sp                                 // Set frame pointer to the start of the stack frame

        // Scale cuboid's base dimensions and height by the factor
        ldr w9, [x0, baseCub + width]               // Load current base width
        mul w9, w9, w1                              // Multiply base width by factor
        str w9, [x0, baseCub + width]               // Store scaled base width

        ldr w10, [x0, baseCub + length]             // Load current base length
        mul w10, w10, w1                            // Multiply base length by factor
        str w10, [x0, baseCub + length]             // Store scaled base length

        ldr w11, [x0, heightCub]                    // Load current height
        mul w11, w11, w1                            // Multiply height by factor
        str w11, [x0, heightCub]                    // Store scaled height

        // Recalculate and store cuboid's volume
        mul w4, w9, w10                             // Calculate scaled base area
        mul w4, w11, w4                             // Calculate scaled volume
        str w4, [x0, volumeCub]                     // Store scaled volume

        ldp x29, x30, [sp], 16                      // Restore frame pointer, link register and deallocate stack space
        ret                                         // Return to caller

        // Function to print cuboid's details
displayCuboid:
        stp x29, x30, [sp, -32]!                     // Save frame pointer, link register and allocate stack space
        mov x29, sp                                  // Set frame pointer to the start of the stack frame

        str x19, [x29, 16]                           // Store temporary register value on stack
        mov x19, x0                                  // Copy cuboid's base address to a temporary register

        adrp x0, infoPrint                           // Load address of the infoPrint string template
        add x0, x0, :lo12:infoPrint                  // Adjust address to the low 12 bits offset of infoPrint
        mov w1, w1                                   // Move label index to w1 (for printf)
        ldr w2, [x19, originCub + posX]              // Load origin X for printing
        ldr w3, [x19, originCub + posY]              // Load origin Y for printing
        ldr w4, [x19, baseCub + width]               // Load base width for printing
        ldr w5, [x19, baseCub + length]              // Load base length for printing
        ldr w6, [x19, heightCub]                     // Load height for printing
        ldr w7, [x19, volumeCub]                     // Load volume for printing

        bl printf                                    // Call printf to print cuboid details

        ldp x29, x30, [sp], 32                       // Restore frame pointer, link register and deallocate stack space
        ret                                          // Return to caller

        // Function to check if two cuboids have equal dimensions
sizeMatch:
        stp x29, x30, [sp, -32]!                      // Save frame pointer, link register and allocate stack space
        mov x29, sp                                   // Set frame pointer to the start of the stack frame

        mov w24, FALSE                               // Initialize result as FALSE

        // Load dimensions of the first cuboid
        ldr w9, [x0, baseCub + width]                // Load width of first cuboid
        ldr w10, [x0, baseCub + length]              // Load length of first cuboid
        ldr w11, [x0, heightCub]                     // Load height of first cuboid

        // Load dimensions of the second cuboid
        ldr w12, [x1, baseCub + width]               // Load width of second cuboid
        ldr w13, [x1, baseCub + length]              // Load length of second cuboid
        ldr w14, [x1, heightCub]                     // Load height of second cuboid

        // Compare dimensions and set result to TRUE if equal
        cmp w9, w12                                  // Compare width of both cuboids
        b.ne skipCheck                               // If widths differ, skip to next check

        cmp w10, w13                                 // Compare length of both cuboids
        b.ne skipCheck                               // If lengths differ, skip to next check

        cmp w11, w14                                 // Compare height of both cuboids
        b.ne skipCheck                               // If heights differ, skip to next check

        mov w24, TRUE                                // Set result to TRUE if all dimensions match
        mov w0, w24                                  // Move result to return register
        bl finish                                    // Branch to finish label to clean up and return

skipCheck:
        mov w0, w24                                  // Move result to return register (remains FALSE if not all dimensions match)
        bl finish                                    // Branch to finish label to clean up and return

finish:
        ldp x29, x30, [sp], 32                       // Restore frame pointer, link register and deallocate stack space
        ret                                          // Return to caller

        //------------- MAIN PROGRAM ---------------

        .global main                                 // Expose main function globally

main:
        stp x29, x30, [sp, spaceAlloc]!              // Save frame pointer, link register and allocate stack space for main
        mov x29, sp                                  // Set frame pointer to the start of the stack frame

        // Initialize and print details of the first cuboid
        add x8, x29, cubOneOffset                    // Calculate address of the first cuboid's storage
        bl initCuboid                                // Call initCuboid to initialize the first cuboid

        // Initialize and print details of the second cuboid
        add x8, x29, cubTwoOffset                    // Calculate address of the second cuboid's storage
        bl initCuboid                                // Call initCuboid to initialize the second cuboid

        // Print the initial state of both cuboids
        adrp x0, startPrint                          // Load address of the startPrint string
        add x0, x0, :lo12:startPrint                 // Adjust address to the low 12 bits offset of startPrint
        bl printf                                    // Call printf to print initial state message

        // Display details of the first cuboid
        add x0, x29, cubOneOffset                    // Calculate address of the first cuboid's storage
        ldr w1, =labelOne                            // Load the label "first" for the first cuboid
        bl displayCuboid                             // Call displayCuboid to print the first cuboid's details

        // Display details of the second cuboid
        add x0, x29, cubTwoOffset                    // Calculate address of the second cuboid's storage
        ldr w1, =labelTwo                            // Load the label "second" for the second cuboid
        bl displayCuboid                             // Call displayCuboid to print the second cuboid's details

        // Compare the dimensions of both cuboids
        add x0, x29, cubOneOffset                    // Calculate address of the first cuboid's storage
        add x1, x29, cubTwoOffset                    // Calculate address of the second cuboid's storage
        bl sizeMatch                                 // Call sizeMatch to compare dimensions of both cuboids
        cmp w0, TRUE                                 // Compare the result of sizeMatch with TRUE
        b.ne alternatePath                           // Branch to alternatePath if cuboids are not equal in size

        // Move the first cuboid by deltaX and deltaY if cuboids are equal in size
        add x0, x29, cubOneOffset                    // Calculate address of the first cuboid's storage
        mov w1, 3                                    // Set deltaX for moving the first cuboid
        mov w2, -6                                   // Set deltaY for moving the first cuboid
        bl shift                                     // Call shift to move the first cuboid

        // Scale the second cuboid if cuboids are equal in size
        add x0, x29, cubTwoOffset                    // Calculate address of the second cuboid's storage
        mov w1, 4                                    // Set scale factor for the second cuboid
        bl adjustScale                               // Call adjustScale to scale the second cuboid

alternatePath:
        // Print the updated state of both cuboids
        adrp x0, updatePrint                         // Load address of the updatePrint string
        add x0, x0, :lo12:updatePrint                // Adjust address to the low 12 bits offset of updatePrint
        bl printf                                    // Call printf to print updated state message

        // Display updated details of the first cuboid
        add x0, x29, cubOneOffset                    // Calculate address of the first cuboid's storage
        ldr w1, =labelOne                            // Load the label "first" for the first cuboid
        bl displayCuboid                             // Call displayCuboid to print updated details of the first cuboid

        // Display updated details of the second cuboid
        add x0, x29, cubTwoOffset                    // Calculate address of the second cuboid's storage
        ldr w1, =labelTwo                            // Load the label "second" for the second cuboid
        bl displayCuboid                             // Call displayCuboid to print updated details of the second cuboid

        mov w0, 0                                    // Set return value of main to 0 (success)
        ldp x29, x30, [sp], spaceFree                // Restore frame pointer, link register and deallocate stack space for main
        ret                                          // Return from main


// ARMv8 assembly program to compute e^x and e^-x using series expansions. Inputs are read from a binary file named via command line. Outputs are displayed in a formatted table with precision up to 10 decimal points.
// Macro definitions for readability
define(fileDesc, w19)
define(bytesRead, x20)
define(bufferStart, x21)
define(sumSeries, d22)
define(currentTerm, d23)
define(numerator, d24)
define(denominator, d25)
define(iteration, d26)
define(termCount, d27)
define(currentInput, d28)
define(negateFactor, d29)
define(signFactor, d30)
define(expPositive, d16)
define(expNegative, d17)
// Constants for buffer and file operations
bufferLength = 8
memoryAdjust = -(16 + bufferLength) & -16
memoryRestore = -memoryAdjust
bufferOffset = 16
openFlag = -100
        .data
precisionLimit:.double 0r1.0e-10      // Threshold for series expansion termination
        .text
// Strings for output formatting
errorOpen:.string "Error opening file"
headerRow:.string " x                   e^x                  e^-x\n"
dataFormat:.string "%13.10f \t %16.10f \t %13.10f \t \n"
debugFormat:.string "N: %13.10f, D: %13.10f, Term: %13.10f, Sum: %13.10f\n\n"
signMsg:.string "Sign: %13.10f\n"
        // Entry point of the program
        .balign 4
        .global main
main:   stp     x29, x30, [sp, memoryAdjust]! // Preserve frame and link registers, allocate stack space
        mov     x29, sp                       // Update frame pointer
        fmov    iteration, 1.0e+0            // Set loop counter initial value
        // Attempt to open the input file
        mov     w0, openFlag                  // Directory flag (current directory)
        ldr     x1, [x1, 8]                   // Retrieve file name from command line argument
        mov     w2, 0                         // File open mode (read-only)
        mov     w3, 0                         // Mode flag (not applicable)
        mov     x8, 56                        // System call number for openat
        svc     0                             // Invoke system call
        mov     fileDesc, w0                  // Store file descriptor
        // Check file open operation result
        cmp     fileDesc, 0                   // Check if file opened successfully
        b.ge    proceed                       // Proceed if no error
        adrp    x0, errorOpen                 // Prepare error message
        add     x0, x0, :lo12:errorOpen
        bl      printf                        // Display error message
        mov     w0, -1                        // Set return code to -1
        b       terminate                     // Exit program
proceed:adrp    x0, headerRow                 // Load header row for output
        add     x0, x0, :lo12:headerRow
        bl      printf                        // Print header row
        add     bufferStart, x29, bufferOffset // Calculate buffer starting address
        // Begin reading from file in a loop
readLoop:mov    w0, fileDesc                   // File descriptor
        mov     x1, bufferStart               // Buffer address
        mov     w2, bufferLength              // Number of bytes to read
        mov     x8, 63                        // System call number for read
        svc     0                             // Invoke system call
        mov     bytesRead, x0                 // Store number of bytes read
        // Verify read operation result
        cmp     bytesRead, bufferLength       // Compare read bytes with expected
        b.ne    finalize                      // If mismatch, proceed to finalize
//--Calculation Logic-----------------------------------------------------------------------------------------------------------
        // Compute e^x
        ldr     d0, [bufferStart]             // Load the input value x
        fmov    signFactor, 1.0               // Initialize positive sign
        fmov    d1, signFactor                // Set sign for calculation
        bl      computeSeries                 // Perform series computation
        fmov    expPositive, d0               // Store e^x result
        // Compute e^-x
        ldr     d0, [bufferStart]             // Reload the input value x
        fmov    signFactor, -1.0              // Set for negative exponent
        fmov    d1, signFactor                // Update sign for calculation
        bl      computeSeries                 // Perform series computation for negative exponent
        fmov    expNegative, d0               // Store e^-x result
//--Output------------------------------------------------------------------------------------------------------------
        adrp    x0, dataFormat                // Prepare format string for output
        add     x0, x0, :lo12:dataFormat
        ldr     d0, [bufferStart]             // Load input value for display
        fmov    d1, expPositive               // Prepare e^x for display
        fmov    d2, expNegative               // Prepare e^-x for display
        bl      printf                        // Print formatted results
        b       readLoop                      // Repeat for next input
finalize:mov     w0, fileDesc                  // Prepare to close file
        mov     x8, 57                        // System call number for close
        svc     0                             // Invoke system call to close file
        mov     w0, 0                         // Set successful return code
terminate:ldp    x29, x30, [sp], memoryRestore // Restore frame and link registers, deallocate stack space
        ret                                  // Return from main

// Compute series expansion for e^x or e^-x based on sign
computeSeries:stp x29, x30, [sp, -16]!        // Save frame and link registers, allocate stack space
        mov     x29, sp                       // Update frame pointer
        // Initialize calculation variables
        fmov    currentInput, d0              // Store input value
        fmov    signFactor, d1                // Store sign (+/-)
        fmov    negateFactor, 1.0
        fmov    numerator, currentInput
        fmov    termCount, 1.0
        fmov    denominator, 1.0
        fmov    sumSeries, xzr
calcLoop: fdiv    currentTerm, numerator, denominator // Calculate current term of series
          // Check against precision limit
          adrp    x26, precisionLimit         // Address of precision limit
          add     x26, x26, :lo12:precisionLimit
          ldr     iteration, [x26]            // Load precision limit
          fcmp    currentTerm, iteration      // Compare current term with limit
          b.le    increment                   // If less than limit, proceed
          // Update term sign and add to sum
          fmul    negateFactor, negateFactor, signFactor // Toggle sign
          fmul    currentTerm, currentTerm, negateFactor // Apply sign to current term
          fadd    sumSeries, sumSeries, currentTerm // Add term to sum
          // Prepare next term
          fmul    numerator, currentInput, numerator // Update numerator
          fmov    iteration, 1.0              // Reset iteration counter
          fadd    termCount, termCount, iteration // Increment term count
          fmul    denominator, denominator, termCount // Update denominator
          b       calcLoop                    // Continue loop
increment:
    fmov    d31, 1.0                          // Move 1.0 into a floating-point register
    fadd    sumSeries, sumSeries, d31        // Add 1.0 to sumSeries using the floating-point register
    fmov    d0, sumSeries                    // Set return value
    ldp     x29, x30, [sp], 16               // Restore frame and link registers, deallocate stack space
    ret                                      // Return from computeSeries


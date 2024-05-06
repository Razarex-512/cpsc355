// Assignment 2c Modified
// Implements integer multiplication with updated identifiers and comments

// Redefine strings for output
initVals:     .string "Init Multiplier=0x%08x (%d), Init Multiplicand=0x%08x (%d) \n\n"
finalProduct: .string "Final Product=0x%08x, Final Multiplier=0x%08x\n"
fullResult:   .string "64-bit Final Result=0x%016lx (%ld)\n"

// Redefine macros with new names
define(ZERO,0)
define(ONE, 1)
define(multReg, w19)
define(multcandReg,w20)
define(prodReg, w21)
define(loopCounter, w22)
define(isNeg, w23)
define(fullProd, x24)
define(aux1, x25)
define(aux2, x26)
define(prodReg64,x21)
define(multReg64,x19)

        .balign 4
        .global main
main:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Initialize operands and product
        mov     multcandReg, -252645136
        mov     multReg, -256
        mov     prodReg, 0
        mov     loopCounter, 0

        // Print initial values
        adrp    x0, initVals
        add     x0, x0, :lo12:initVals
        mov     w1, multReg
        mov     w2, multReg
        mov     w3, multcandReg
        mov     w4, multcandReg
        bl      printf

        // Check if multiplier is negative
        cmp     multReg, 0
        b.ge    start
        mov     isNeg, ONE
start:
        mov     loopCounter, 0
        b       condCheck

multiplyLoop:
        // Test and add if LSB of multiplier is set
        tst     multReg, 0x1
        b.eq    shiftCheck
        add     prodReg, prodReg, multcandReg
shiftCheck:
        // Shift and adjust product and multiplier
        asr     multReg, multReg, 1
        tst     prodReg, 0x1
        b.eq    negCheck
        orr     multReg, multReg, 0x80000000
        b       shiftProd
negCheck:
        and     multReg, multReg, 0x7FFFFFFF
shiftProd:
        asr     prodReg, prodReg, 1
        add     loopCounter, loopCounter, 1

condCheck:
        // Continue if not done with all bits
        cmp     loopCounter, 32
        b.lt    multiplyLoop

        // Adjust for negative multiplicand
        cmp     isNeg, ONE
        b.ne    printProd
        sub     prodReg, prodReg, multcandReg
printProd:
        // Print product and multiplier
        adrp    x0, finalProduct
        add     x0, x0, :lo12:finalProduct
        mov     w1, prodReg
        mov     w2, multReg
        bl      printf

        // Convert to 64-bit result
        sxtw    aux1, prodReg
        and     aux1, prodReg64, 0xFFFFFFFF
        lsl     aux1, aux1, 32
        sxtw    aux2, multReg
        and     aux2, multReg64, 0xFFFFFFFF
        add     fullProd, aux1, aux2

        // Print 64-bit result
        adrp    x0, fullResult
        add     x0, x0, :lo12:fullResult
        mov     x1, fullProd
        mov     x2, fullProd
        bl      printf
done:
        // Restore registers and return
        mov     w0, 0
        ldp     x29, x30, [sp], 16
        ret


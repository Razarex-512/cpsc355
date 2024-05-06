// ARMv8 assembly language program to implement given sorting algorithm. Creates space on the stack to store all local variables. 
// Uses m4 macros or assembler equates for all stack variable offsets. Reads or writes memory when using or assigning local variables. 

labelUnsortedArray:         .string "\nUnsorted array:    \n"                   // Format for printing out unsorted array
labelSortedArray:           .string "\nSorted array:  \n"                       // Format for printing out sorted array
printElements:              .string "v[%d] = %d\n"                              // Prints array elements
                            
                            .balign 4                                           // Ensures instructions are properly aligned
                            .global main                                        // Makes label "main" visible to the linker

                            // Assembler equates
                            arr_size      =    50                                   // Array contains 50 elements
                            block_size    =    arr_size * 4                             // Block size of array (200 bytes)
                            i_size    =    4                                    // 4 bytes for i 
                            j_size    =    4                                    // 4 bytes for j 
                            temp_size =    4                                    // 4 bytes for temp
                           
                            i_s_offset       =    16                                   // Stack offset for i var
                            j_s_offset       =    20                                   // Stack offset for j var
                            temp_offset    =    24                                   // Stack offset for temp var
                           base_offset       =    28                                   // Stack offset for array base

                            alloc     =    -(16 + i_s_offset + j_s_offset + temp_offset +base_offset + block_size) & -16      // Allocate memory
                            dealloc   =    -alloc                                               // Deallocate memory

                            fp      .req x29                                    //frame pointer x29 register to fp
                            lr      .req x30                                    // link register x30 register to lr

main:                       stp     fp, lr, [sp, alloc]!                        // Store frame pointer and link register
                            mov     fp, sp                                      // Update frame pointer to current stack pointer

                            // Define m4 macros
                            define(base_address, x19)                               // Assign 64-bit register x19 to base_address
                            define(index_i, w20)                                      // Assign word size register w20 to index_i
                            define(index_j, w21)                                      // Assign word size register w21 to index_j
                            define(temp, w22)                                   // Assign word size register w22 to temp
                            define(j_neg_1, w23)                                     // Assign word size register w23 to j_neg_1 to store value of j-1
                            define(v_index_i, w24)                                     // Assign word size register w24 to v_index_i
                            define(v_index_j, w25)                                     // Assign word size register w25 to v_index_j
                            define(v_j_neg_1, w26)                                    // Assign word size register w26 to v_j_neg_1 to store value of v[j-1]

                            add     base_address, fp,base_offset                           // Calculate base address 

                            ldr     index_i, [fp, i_s_offset]                                // Load i value from address
                            mov     index_i, 0                                        // Set index_i = 0
                            str     index_i, [fp, i_s_offset]                                // Value in index register stored to address in [fp, i_s_offset]

                            ldr     index_j, [fp, j_s_offset]                                // Load index_j from address
                            mov     index_j, 0                                        // Set index_j to 0
                            str     index_j, [fp, j_s_offset]                                // Value in address stored to j

                            ldr     temp, [fp, temp_offset]                          // Value in address loaded into temp variable
                            mov     temp, 0                                     //temp = 0
                            str     temp, [fp, temp_offset]                          // Value in temp stored to address in [fp, temp_offset]

                            b       randLoopCheck                               // Branch to first loop check (check i value)

randValue:                  ldr	    index_i, [fp, i_s_offset]					            // Value at address found in [fp, i_s_offset] loaded into index register
                            bl      rand                                        // Calls rand
                            and     v_index_i, w0, 0xFF                                // Add 0xFF in v_index_i
                            str     v_index_i, [base_address, index_i, SXTW 2]                   // Value in v_index_i register stored to address
                            
			                add	    index_i, index_i, 1									    // Increment index value by 1 at end of each iteration
			                str	    index_i, [fp, i_s_offset]							    // Value found in index register is stored to address found in [fp, i_s_offset]

randLoopCheck:              cmp     index_i, arr_size                                     // Compare index value to 50 (array elements size)
                            b.lt    randValue                                   // If less than 50, branch to randValue loop again

                            adrp    x0, labelUnsortedArray                      // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:labelUnsortedArray            // Set first argument of printf (lower 12 bits)
                            bl      printf                                      // Calls printf

                            mov     index_i, 0                                        // Initialize i to 0
                            str     index_i, [fp, i_s_offset]                                // Value  found in index register stored to address found in [fp, i_s_offset]
                            b       prePrintCheck                          // Branch to prePrintCheck

unsortedPrint:         ldr     index_i, [fp, i_s_offset]                                // Value from address loaded into index register (i)
                            ldr     v_index_i, [base_address, index_i, SXTW 2]                   // Value from address loaded into v_index_i (v[i])

                            adrp    x0, printElements                           // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:printElements                 // Set first argument of printf (lower 12 bits)
                            mov     w1, index_i                                       // First %d in statement is index value
                            mov     w2, v_index_i                                      // Second %d in statement is value at v[i]
                            bl      printf                                      // Calls printf

                            add     index_i, index_i, 1                                     // i++
                            str     index_i, [fp, i_s_offset]                                // Store index value at address in [fp, i_s_offset]

prePrintCheck:         cmp     index_i, arr_size                                     // Compares index with 50
                            b.lt    unsortedPrint                          // If i less than 50, repeat print loop

                            // sorting starts here 

                            ldr     index_i, [fp, i_s_offset]                                // Load  i from address
                            mov     index_i, 1                                        // Set i to 1
                            str     index_i, [fp, i_s_offset]                                // Set new i to address [fp, i_s_offset]
                            b       checkOuterLoop                              // Branch to outer loop test

outerLoop:                  ldr     index_i, [fp, i_s_offset]                                // Load i from address
                            ldr     v_index_i, [base_address, index_i, SXTW 2]                   // Load value into  v[i] from address
                            str     v_index_i, [fp, temp_offset]                            // Move v[i] into temp and store it
                                                                
                            ldr     index_i, [fp, i_s_offset]                                // Load i from address
                            str     index_i, [fp, j_s_offset]                                // Move j into i and store it to address
                            b       checkInnerLoop                             // Branch to inner loop test

innerLoop:                 ldr     index_j, [fp, j_s_offset]                                // Load j from address
                            sub     j_neg_1, index_j, 1                                    // Subtract j-1 and store it in j_neg_1
                            ldr     v_j_neg_1, [base_address, j_neg_1, SXTW 2]                 // Load value into v[j-1] from address using j_neg_1
                            add     j_neg_1, j_neg_1, 1                                   // j_neg_1= j_neg_1 + 1
                            str     v_j_neg_1, [base_address, j_neg_1, SXTW 2]                 // Move value of v[j-1] to v[j] and store it to address

                            ldr     index_j, [fp, j_s_offset]                                // Load j from address
                            sub     index_j, index_j, 1                                     // j--
                            str     index_j, [fp, j_s_offset]                                // Store j to address

checkInnerLoop:            ldr     index_j, [fp, j_s_offset]                                // Load j from address
                            cmp     index_j, 0                                        // Compare j to 0
                            b.le    done                                        // If j < 0 (first condition fails) then branch to done
                            sub     j_neg_1, index_j, 1                                    // Subtract j-1 and store in j_neg_1
                            ldr     v_j_neg_1, [x19, j_neg_1, sxtw 2]                      // Load value into v[j-1] from address using j_neg_1
                            ldr     temp, [fp, temp_offset]                          // Load value into temp from its address
                            cmp     temp, v_j_neg_1                                   // Compare value of temp and v[j-1]
                            b.ge    done                                        // If temp > v[j-1] (second condition fails) branch to done
                            b       innerLoop                                  // Branch to second loop if conditions pass

done:                       ldr     index_j, [fp, j_s_offset]                                // Load j from its address
                            ldr     temp, [fp, temp_offset]                          // Load temp from its address
                            str     temp, [base_address, index_j, SXTW 2]                 // Move temp into v[j] and store it to address

                            ldr     index_i, [fp, i_s_offset]                                // Loa i from address
                            add     index_i, index_i, 1                                     // i++
                            str     index_i, [fp, i_s_offset]                                // Store i into address

checkOuterLoop:             ldr     index_i, [fp, i_s_offset]                                // Load index i from address
                            cmp     index_i, arr_size                                     // Compare value of i with size (50)
                            b.lt    outerLoop                                   // If i < 50 then repeat sorting loop
                            adrp    x0, labelSortedArray				        // Set first argument of printf (higher bits)
		       	            add     x0, x0, :lo12:labelSortedArray	            // Set first argument of printf (lower 12 bits)
			                bl	    printf										// Calls printf

                            mov     index_i, 0                                        // Initialize i to 0
                            str     index_i, [fp, i_s_offset]                                // Value found in index register stored to address found in [fp, i_s_offset]
                            b       printSortedCheck                            // Branch to printSortedCheck

printSortedArray:           ldr     index_i, [fp, i_s_offset]                                // Value from address loaded into index register (i)
                            ldr     v_index_j, [base_address, index_i, SXTW 2]                   // Value from address loaded into v_index_j (v[j])

                            adrp    x0, printElements                           // Set first argument of printf (higher bits)
                            add     x0, x0, :lo12:printElements                 // Set first argument of printf (lower 12 bits)
                            mov     w1, index_i                                       // First %d in statement is index value
                            mov     w2, v_index_j                                      // Second %d in statement is value at v[j]
                            bl      printf                                      // Calls printf

                            add     index_i, index_i, 1                                     // Increment index value by 1
                            str     index_i, [fp, i_s_offset]                                // Store index value at address found in [fp, i_s_offset]

printSortedCheck:           cmp     index_i, arr_size                                     // Compares index value with 50
                            b.lt    printSortedArray                            // If i < 50, repeat print loop

end:			            mov	    x0, 0									 	// Return code 0 for successful termination
			                ldp     fp, lr, [sp], dealloc				        // Restore state of frame pointer and link register, deallocate memory
			                ret											 	    // Returns control to calling code

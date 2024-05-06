// File: unique_a5b.asm
// Author: Syed Raza
// Summary:
// An ARMv8 assembly program to interpret date input and output the date, month, and season.

// Register Aliases
define(arg_count, w20)         // Alias for the argument count
define(arg_values, x21)        // Alias for the pointer to argument values
define(loop_index, w23)        // Alias for loop index
define(month_num, w24)         // Alias for the month number extracted from input
define(day_num, w25)           // Alias for the day number extracted from input
define(month_pointer, x26)     // Alias for pointer to month string
define(season_pointer, x27)    // Alias for pointer to season string
define(suffix_pointer, x28)    // Alias for pointer to day suffix string

// Frame Record Registers
frame_pointer		.req	x29 // Frame pointer for stack frame management
link_register		.req	x30 // Link register for return address

// Store strings in the .text section for program use
		.text
winter_str:	.string	"winter"
spring_str:	.string	"spring"
summer_str:	.string	"summer"
autumn_str:	.string	"fall"

jan_str:	.string	"January"
feb_str:	.string	"February"
mar_str:	.string	"March"
apr_str:	.string	"April"
may_str:	.string	"May"
jun_str:	.string	"June"
jul_str:	.string	"July"
aug_str:	.string	"August"
sep_str:	.string	"September"
oct_str:	.string	"October"
nov_str:	.string	"November"
dec_str:	.string	"December"

st_suffix:	.string	"st"
nd_suffix:	.string	"nd"
rd_suffix:	.string	"rd"
th_suffix:	.string	"th"

// Usage and Error Messages
usage_msg:	.string	"usage: unique_a5b mm dd\n"
success_output:	.string	"%s %d%s is in %s\n"
month_error_msg:.string	"Months must be between 1 and 12 inclusively\n"
day_error_msg:	.string	"Days must be between 1 and 31 inclusively\n"

// External pointer arrays in .data section
               .data
               .balign 8										
months_arr:    .dword	jan_str, feb_str, mar_str, apr_str, may_str, jun_str, jul_str, aug_str, sep_str, oct_str, nov_str, dec_str
seasons_arr:    .dword	winter_str, spring_str, summer_str, autumn_str
day_suffixes_arr:    .dword	st_suffix, nd_suffix, rd_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, st_suffix, nd_suffix, rd_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, th_suffix, st_suffix

                .text										
                .balign 4										
                .global main									
main:		    stp	    frame_pointer, link_register, [sp, -16]!	// Store frame pointer and link register, prepare stack frame						
                mov	    frame_pointer, sp	// Update frame pointer to current stack pointer					

                mov	    arg_count, w0	// Store argument count in arg_count	    		
                mov	   arg_values, x1	// Store pointer to argument values in arg_values						

                cmp	    arg_count, 3	// Compare argument count to expected 3											
                b.ne	usage_error	// Branch to usage_error if not equal								

                mov	    loop_index, 1	// Initialize loop index to access first argument (month)													
                ldr	    x0, [arg_values, loop_index, SXTW 3]	// Load first argument (month) into x0							
                bl	    atoi	// Convert ASCII string to integer																
                mov	    month_num, w0	// Store converted month number in month_num		                                          	

                cmp 	month_num, 1	// Check if month_num is less than 1													
                b.lt	month_error	// Branch to month_error if true										
                cmp	    month_num, 12	// Check if month_num is greater than 12													
                b.gt	month_error	// Branch to month_error if true										

                mov	    loop_index, 2	// Set loop index to access second argument (day)													
                ldr     x0, [arg_values, loop_index, SXTW 3]	// Load second argument (day) into x0							
                bl	    atoi	// Convert ASCII string to integer																
                mov     day_num, w0	// Store converted day number in day_num														

                cmp	    day_num, 1	// Check if day_num is less than 1														
                b.lt	day_error	// Branch to day_error if true											
                cmp	    day_num, 31	// Check if day_num is greater than 31													 	
                b.gt	day_error	// Branch to day_error if true											

                adrp    x0, success_output	// Load address of the success output format string												
                add     x0, x0, :lo12:success_output	// Add offset to address of the success output format string										

                sub	    loop_index, month_num, 1	// Adjust loop index to access correct month string from months_arr											
                adrp    month_pointer, months_arr	// Load address of months_arr											
                add     month_pointer, month_pointer, :lo12:months_arr	// Add offset to address of months_arr					
                ldr     x1, [month_pointer, loop_index, SXTW 3]	// Load month string based on month_num							

                mov	    w2, day_num	// Set day number to w2														

                sub	    loop_index, day_num, 1	// Adjust loop index to access correct day suffix from day_suffixes_arr											
                adrp    suffix_pointer, day_suffixes_arr	// Load address of day_suffixes_arr									
                add     suffix_pointer, suffix_pointer, :lo12:day_suffixes_arr	// Add offset to address of day_suffixes_arr				
                ldr     x3, [suffix_pointer, loop_index, SXTW 3]	// Load day suffix based on day_num							


evaluate_spring:		cmp	    month_num, 3	// Check if month_num is less than 3												
                    b.lt	evaluate_winter	// Branch to evaluate_winter if true												

                    cmp	    month_num, 3	// Check if month_num equals 3												
                    b.eq	spring_or_winter	// Branch to spring_or_winter if true												

                    cmp	    month_num, 6	// Check if month_num equals 6												
                    b.eq	spring_or_summer	// Branch to spring_or_summer if true												

                    cmp	    month_num, 6	// Check if month_num is greater than 6												
                    b.gt	evaluate_summer	// Branch to evaluate_summer if true												

spring_continue:     mov	    loop_index,1	// Set loop index to access spring from seasons_arr												
                    adrp    season_pointer, seasons_arr	// Load address of seasons_arr									
                    add     season_pointer, season_pointer, :lo12:seasons_arr	// Add offset to address of seasons_arr				
                    ldr	    x4, [season_pointer, loop_index, SXTW 3]	// Load "spring" string						
                    b	    season_decided	// Branch to season_decided												

spring_or_winter:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	evaluate_winter	// Branch to evaluate_winter if true												
                    b	    spring_continue	// Branch to spring_continue if not true												

spring_or_summer:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	spring_continue	// Branch to spring_continue if true												
                    b	    evaluate_summer	// Branch to evaluate_summer if not true												

evaluate_winter:		cmp	    month_num, 3	// Check if month_num is less than 3												
                    b.lt	winter_continue	// Branch to winter_continue if true												

                    cmp	    month_num, 12	// Check if month_num equals 12												
                    b.eq	winter_or_autumn	// Branch to winter_or_autumn if true												

                    cmp	    month_num, 12	// Check if month_num is less than 12												
                    b.lt	evaluate_autumn	// Branch to evaluate_autumn if true												

winter_continue:	mov     loop_index, 0	// Set loop index to access winter from seasons_arr												
                    adrp    season_pointer, seasons_arr	// Load address of seasons_arr									
                    add     season_pointer, season_pointer, :lo12:seasons_arr	// Add offset to address of seasons_arr				
                    ldr     x4, [season_pointer, loop_index, SXTW 3]	// Load "winter" string						
                    b	    season_decided	// Branch to season_decided												

winter_or_autumn:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	evaluate_autumn	// Branch to evaluate_autumn if true												
                    b	    winter_continue	// Branch to winter_continue if not true												

evaluate_summer:		cmp	    month_num, 6	// Check if month_num equals 6												
                    b.eq	summer_or_spring	// Branch to summer_or_spring if true												

                    cmp 	month_num, 6	// Check if month_num is less than 6												
                    b.lt	evaluate_spring	// Branch to evaluate_spring if true												

                    cmp	    month_num, 9	// Check if month_num equals 9												
                    b.eq	summer_or_autumn	// Branch to summer_or_autumn if true												

                    cmp	    month_num, 9	// Check if month_num is greater than 9												
                    b.gt	evaluate_autumn	// Branch to evaluate_autumn if true												

summer_continue:	mov     loop_index, 2	// Set loop index to access summer from seasons_arr												
                    adrp    season_pointer, seasons_arr	// Load address of seasons_arr								
                    add     season_pointer, season_pointer, :lo12:seasons_arr	// Add offset to address of seasons_arr			
                    ldr     x4, [season_pointer, loop_index, SXTW 3]	// Load "summer" string					
                    b	    season_decided	// Branch to season_decided												

summer_or_spring:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	evaluate_spring	// Branch to evaluate_spring if true												
                    b	    summer_continue	// Branch to summer_continue if not true												

summer_or_autumn:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	summer_continue	// Branch to summer_continue if true												
                    b	    evaluate_autumn	// Branch to evaluate_autumn if not true												

evaluate_autumn:		cmp	    month_num, 9	// Check if month_num equals 9												
                    b.eq	autumn_or_summer	// Branch to autumn_or_summer if true												

                    cmp	    month_num, 9	// Check if month_num is less than 9												
                    b.lt	evaluate_summer	// Branch to evaluate_summer if true												

                    cmp	    month_num, 12	// Check if month_num equals 12												
                    b.eq	autumn_or_winter	// Branch to autumn_or_winter if true												

autumn_continue:	    mov     loop_index, 3	// Set loop index to access autumn from seasons_arr												
                    adrp    season_pointer, seasons_arr	// Load address of seasons_arr								
                    add     season_pointer, season_pointer, :lo12:seasons_arr	// Add offset to address of seasons_arr			
                    ldr     x4, [season_pointer, loop_index, SXTW 3]	// Load "autumn" string					
                    b	    season_decided	// Branch to season_decided												

autumn_or_summer:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	evaluate_summer	// Branch to evaluate_summer if true												
                    b	    autumn_continue	// Branch to autumn_continue if not true												

autumn_or_winter:	cmp	    day_num, 21	// Check if day_num is less than 21													
                    b.lt	autumn_continue	// Branch to autumn_continue if true												
                    b	    evaluate_winter	// Branch to evaluate_winter if not true												


season_decided:	bl	    printf	// Print the formatted success message using printf														
                b	    program_end	// Branch to end of program													

day_error:	    adrp    x0, day_error_msg	// Load address of day error message												
                add     x0, x0, :lo12:day_error_msg	// Add offset to address of day error message										
                bl	    printf	// Print the day error message using printf															
                b	    program_end	// Branch to end of program													

month_error:	    adrp    x0, month_error_msg	// Load address of month error message											
                add     x0, x0, :lo12:month_error_msg	// Add offset to address of month error message									
                bl	    printf	// Print the month error message using printf															
                b	    program_end	// Branch to end of program													

usage_error:	    adrp	x0, usage_msg	// Load address of usage message													
                add	    x0, x0, :lo12:usage_msg	// Add offset to address of usage message											
                bl	    printf	// Print the usage message using printf															

program_end:	    mov	    w0, 0	// Set return value to 0															
                ldp	    frame_pointer, link_register, [sp], 16	// Restore frame pointer and link register from stack							
                ret		// Return from function																	


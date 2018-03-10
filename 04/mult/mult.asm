// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

//WARNING! This script edits the value of R1 to 0,
//In essence it returns R0=R0, R1=0, R2=R0*R1

//Initial Result (R2) to 0
@R2
M=0

// This loop is going to end when R1 = 0
// If R1/=0 then it is going to add R0 to R2
// Then reduce R1 by 1
(LOOP)
    //if R1=0 end
    @R1
    D=M
    @END
    D;JEQ

    // Add R0 to result
    @R0
    D=M
    @R2
    M=M+D

    // Decrease R1 by 1
    @R1
    M=M-1

    //Do main loop again
    @LOOP
    0; JMP

(END)
    @END
    0; JMP
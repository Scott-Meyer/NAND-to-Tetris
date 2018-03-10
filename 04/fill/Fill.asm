// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.
// When things continued not to work,
//      https://github.com/omarrayward/from-nand-to-tetris/blob/master/04/fill/Fill.asm
// was used as a refrence.

(MAIN)
    // Set D for if statement
    @KBD
    D=M
    // If no key pressed
    @NOKEY
    D; JEQ
    // Else
    @KEYPRESS
    0; JMP


    (NOKEY)
        @c
        M=0
        @CHANGESCREEN
        0;JMP
    (KEYPRESS)
        @c
        M=-1
        @CHANGESCREEN
        0;JMP

    (CHANGESCREEN)
        //Initialize variables
            //i = 8192
            //curPixel = first pixel
        @8192
        D=A
        @i
        M=D

        @SCREEN
        D=A
        @curPixel
        M=D

        (LOOP)
            // Set D to value of color
            @c
            D=M

            // Set the value of A to the screen register number and modify its value
            // to have the value of color (0 white; -1 black)
            @curPixel
            A=M
            M=D

            // Add one to curPixel (to CHANGESCREEN the right pixels in the next
            // loop)
            @curPixel
            M=M+1

            // Subtract 1 from pixCount
            @i
            M=M-1
            D=M

            // if pixCount is 0 => go to MAIN program
            @MAIN
            D; JEQ

            // if pixCount is not 0, continue CHANGESCREENing
            @LOOP
            0; JMP
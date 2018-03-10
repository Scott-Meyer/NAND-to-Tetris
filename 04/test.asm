  (START)
    // There are 8192 registers dealing with the screen
    // initialize numScreenRegistersToPaint to 8192
    @8192
    D=A
    @numScreenRegistersToPaint
    M=D

    // Set the value of var currentScreenRegister to the first register of the screen
    @SCREEN
    D=A
    @currentScreenRegister
    M=D

    // Set D to the value of keyboard. 0=> No press // 1=> press
    @KBD
    D=M

    // If no press => set paint color to white
    @SETWHITE
    D; JEQ

    // If press => set paint color to black
    @SETBLACK
    0; JMP

  // Set var color to 0
  (SETWHITE)
    @color
    M=0

    @PAINT
    0;JMP

  // Set var color to -1
  (SETBLACK)
    @color
    M=-1

    @PAINT
    0;JMP

  // Paint the screem
  (PAINT)
    // Set D to value of color
    @color
    D=M

    // Set the value of A to the screen register number and modify its value
    // to have the value of color (0 white; -1 black)
    @currentScreenRegister
    A=M
    M=D

    // Add one to currentScreenRegister (to paint the right pixels in the next
    // loop)
    @currentScreenRegister
    M=M+1

    // Subtract 1 from numScreenRegistersToPaint
    @numScreenRegistersToPaint
    M=M-1
    D=M

    // if numScreenRegistersToPaint is 0 => go to start program
    @START
    D; JEQ

    // if numScreenRegistersToPaint is not 0, continue painting
    @PAINT
    0; JMP
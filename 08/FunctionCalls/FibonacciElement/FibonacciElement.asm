@256
D=A
@SP
M=D
@Sys.initFUNCTIONRETURN0
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@LCL
M=D
@5
D=D-A
@ARG
M=D
@Sys.init
0;JMP
(Sys.initFUNCTIONRETURN0)
//-------------------//
// Main
//-------------------//
////// BEGIN /////FunctionCalls/FibonacciElement/Main.vm
// function Main.fibonacci 0
(Main.fibonacci)
// push argument 0
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt 
@SP
M=M-1
A=M
D=M
@SP
M=M-1
@SP
A=M
D=M-D
@BOOL0
D;JLT
@SP
A=M
M=0
@ENDBOOL0
0;JMP
(BOOL0)
@SP
A=M
M=-1
(ENDBOOL0)
@SP
M=M+1
// if-goto IF_TRUE
@SP
M=M-1
A=M
D=M
@Main$IF_TRUE
D;JNE
// goto IF_FALSE
@Main$IF_FALSE
0;JMP
// label IF_TRUE 
(Main$IF_TRUE)
// push argument 0
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// return
@LCL
D=M
@R13
M=D
@R13
D=M
@5
D=D-A
A=D
D=M
@R14
M=D
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M
@SP
M=D+1
@R13
D=M
@1
D=D-A
A=D
D=M
@THAT
M=D
@R13
D=M
@2
D=D-A
A=D
D=M
@THIS
M=D
@R13
D=M
@3
D=D-A
A=D
D=M
@ARG
M=D
@R13
D=M
@4
D=D-A
A=D
D=M
@LCL
M=D
@R14
A=M
0;JMP
// label IF_FALSE 
(Main$IF_FALSE)
// push argument 0
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
@SP
M=M-1
@SP
A=M
M=M-D
@SP
M=M+1
// call Main.fibonacci 1 
@Main.fibonacciFUNCTIONRETURN1
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@LCL
M=D
@6
D=D-A
@ARG
M=D
@Main.fibonacci
0;JMP
(Main.fibonacciFUNCTIONRETURN1)
// push argument 0
@ARG
D=M
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
@SP
M=M-1
@SP
A=M
M=M-D
@SP
M=M+1
// call Main.fibonacci 1 
@Main.fibonacciFUNCTIONRETURN2
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@LCL
M=D
@6
D=D-A
@ARG
M=D
@Main.fibonacci
0;JMP
(Main.fibonacciFUNCTIONRETURN2)
// add 
@SP
M=M-1
A=M
D=M
@SP
M=M-1
@SP
A=M
M=M+D
@SP
M=M+1
// return
@LCL
D=M
@R13
M=D
@R13
D=M
@5
D=D-A
A=D
D=M
@R14
M=D
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M
@SP
M=D+1
@R13
D=M
@1
D=D-A
A=D
D=M
@THAT
M=D
@R13
D=M
@2
D=D-A
A=D
D=M
@THIS
M=D
@R13
D=M
@3
D=D-A
A=D
D=M
@ARG
M=D
@R13
D=M
@4
D=D-A
A=D
D=M
@LCL
M=D
@R14
A=M
0;JMP
//-------------------//
// Sys
//-------------------//
////// BEGIN /////FunctionCalls/FibonacciElement/Sys.vm
// function Sys.init 0
(Sys.init)
// push constant 4
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
// call Main.fibonacci 1 
@Main.fibonacciFUNCTIONRETURN3
D=A
@SP
A=M
M=D
@SP
M=M+1
@LCL
D=M
@SP
A=M
M=D
@SP
M=M+1
@ARG
D=M
@SP
A=M
M=D
@SP
M=M+1
@THIS
D=M
@SP
A=M
M=D
@SP
M=M+1
@THAT
D=M
@SP
A=M
M=D
@SP
M=M+1
@SP
D=M
@LCL
M=D
@6
D=D-A
@ARG
M=D
@Main.fibonacci
0;JMP
(Main.fibonacciFUNCTIONRETURN3)
// label WHILE
(Sys$WHILE)
// goto WHILE 
@Sys$WHILE
0;JMP
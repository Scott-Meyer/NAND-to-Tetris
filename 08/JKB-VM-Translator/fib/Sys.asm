// Processing file fib\Sys.vm
// Line 1: // This file is part of www.nand2tetris.org
// Line 2: // and the book "The Elements of Computing Systems"
// Line 3: // by Nisan and Schocken, MIT Press.
// Line 4: // File name: projects/08/FunctionCalls/FibonacciElement/Sys.vm
// Line 5: 
// Line 6: // Pushes n onto the stack and calls the Main.fibonacii function,
// Line 7: // which computes the n'th element of the Fibonacci series.
// Line 8: // The Sys.init function is called "automatically" by the 
// Line 9: // bootstrap code.
// Line 10: 
// Line 11: function Sys.init 0
// Line 11: command = function, arg1 = Sys.init, arg2 = 0
(Sys.init)
// Line 12: push constant 4
// Line 12: command = push, arg1 = constant, arg2 = 4
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
// Line 13: call Main.fibonacci 1   // Compute the 4'th fibonacci element
// Line 13: command = call, arg1 = Main.fibonacci, arg2 = 1
@Main.fibonacci
D=A
@R15
M=D
@1
D=A
@R14
M=D
@_1
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
@R14
D=D-M
@5
D=D-A
@ARG
M=D
@R15
A=M
0;JMP
(_1)
// Line 14: label WHILE
// Line 14: command = label, arg1 = WHILE, arg2 = 
(Sys.init$WHILE)
// Line 15: goto WHILE              // Loop infinitely
// Line 15: command = goto, arg1 = WHILE, arg2 = 
@Sys.init$WHILE
0;JMP

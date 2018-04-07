// Performing system initialization
// Initialize the stack pointer to 256
@256
D=A
@SP
M=D
// Set LCL, ARG, THIS, and THAT to -1
A=A+1
M=-1
A=A+1
M=-1
A=A+1
M=-1
A=A+1
M=-1
// Call Sys.init
@Sys.init
D=A
@R15
M=D
@0
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
// Loop forever
@_2
(_2)
0;JMP
// Processing file fib\Main.vm; short file name = Main
// Line 1: // This file is part of www.nand2tetris.org
// Line 2: // and the book "The Elements of Computing Systems"
// Line 3: // by Nisan and Schocken, MIT Press.
// Line 4: // File name: projects/08/FunctionCalls/FibonacciElement/Main.vm
// Line 5: 
// Line 6: // Computes the n'th element of the Fibonacci series, recursively.
// Line 7: // n is given in argument[0].  Called by the Sys.init function 
// Line 8: // (part of the Sys.vm file), which also pushes the argument[0] 
// Line 9: // parameter before this code starts running.
// Line 10: 
// Line 11: function Main.fibonacci 0
// Line 11: command = function, arg1 = Main.fibonacci, arg2 = 0
(Main.fibonacci)
// Line 12: push argument 0
// Line 12: command = push, arg1 = argument, arg2 = 0
@ARG
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 13: push constant 2
// Line 13: command = push, arg1 = constant, arg2 = 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// Line 14: lt                     // check if n < 2
// Line 14: command = lt, arg1 = lt, arg2 = 
@SP
A=M-1
A=A-1
D=M
A=A+1
D=D-M
@_3
D;JLT
@_4
D=0;JMP
(_3)
D=-1
(_4)
@SP
AM=M-1
A=A-1
M=D
// Line 15: if-goto IF_TRUE
// Line 15: command = if-goto, arg1 = IF_TRUE, arg2 = 
@SP
AM=M-1
D=M
@Main.fibonacci$IF_TRUE
D;JNE
// Line 16: goto IF_FALSE
// Line 16: command = goto, arg1 = IF_FALSE, arg2 = 
@Main.fibonacci$IF_FALSE
0;JMP
// Line 17: label IF_TRUE          // if n<2, return n
// Line 17: command = label, arg1 = IF_TRUE, arg2 = 
(Main.fibonacci$IF_TRUE)
// Line 18: push argument 0        
// Line 18: command = push, arg1 = argument, arg2 = 0
@ARG
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 19: return
// Line 19: command = return, arg1 = , arg2 = 
@LCL
D=M
@5
A=D-A
D=M
@R14
M=D
@SP
AM=M-1
D=M
@ARG
A=M
M=D
D=A+1
@R15
M=D
@LCL
D=M
@SP
M=D
@SP
AM=M-1
D=M
@THAT
M=D
@SP
AM=M-1
D=M
@THIS
M=D
@SP
AM=M-1
D=M
@ARG
M=D
@SP
AM=M-1
D=M
@LCL
M=D
@R15
D=M
@SP
M=D
@14
A=M
0;JMP
// Line 20: label IF_FALSE         // if n>=2, return fib(n-2)+fib(n-1)
// Line 20: command = label, arg1 = IF_FALSE, arg2 = 
(Main.fibonacci$IF_FALSE)
// Line 21: push argument 0
// Line 21: command = push, arg1 = argument, arg2 = 0
@ARG
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 22: push constant 2
// Line 22: command = push, arg1 = constant, arg2 = 2
@2
D=A
@SP
A=M
M=D
@SP
M=M+1
// Line 23: sub
// Line 23: command = sub, arg1 = sub, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M-D
// Line 24: call Main.fibonacci 1  // compute fib(n-2)
// Line 24: command = call, arg1 = Main.fibonacci, arg2 = 1
@Main.fibonacci
D=A
@R15
M=D
@1
D=A
@R14
M=D
@_5
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
(_5)
// Line 25: push argument 0
// Line 25: command = push, arg1 = argument, arg2 = 0
@ARG
D=M
@0
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 26: push constant 1
// Line 26: command = push, arg1 = constant, arg2 = 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
// Line 27: sub
// Line 27: command = sub, arg1 = sub, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M-D
// Line 28: call Main.fibonacci 1  // compute fib(n-1)
// Line 28: command = call, arg1 = Main.fibonacci, arg2 = 1
@Main.fibonacci
D=A
@R15
M=D
@1
D=A
@R14
M=D
@_6
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
(_6)
// Line 29: add                    // return fib(n-1) + fib(n-2)
// Line 29: command = add, arg1 = add, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M+D
// Line 30: return
// Line 30: command = return, arg1 = , arg2 = 
@LCL
D=M
@5
A=D-A
D=M
@R14
M=D
@SP
AM=M-1
D=M
@ARG
A=M
M=D
D=A+1
@R15
M=D
@LCL
D=M
@SP
M=D
@SP
AM=M-1
D=M
@THAT
M=D
@SP
AM=M-1
D=M
@THIS
M=D
@SP
AM=M-1
D=M
@ARG
M=D
@SP
AM=M-1
D=M
@LCL
M=D
@R15
D=M
@SP
M=D
@14
A=M
0;JMP
// Processing file fib\Sys.vm; short file name = Sys
// Line 31: // This file is part of www.nand2tetris.org
// Line 32: // and the book "The Elements of Computing Systems"
// Line 33: // by Nisan and Schocken, MIT Press.
// Line 34: // File name: projects/08/FunctionCalls/FibonacciElement/Sys.vm
// Line 35: 
// Line 36: // Pushes n onto the stack and calls the Main.fibonacii function,
// Line 37: // which computes the n'th element of the Fibonacci series.
// Line 38: // The Sys.init function is called "automatically" by the 
// Line 39: // bootstrap code.
// Line 40: 
// Line 41: function Sys.init 0
// Line 41: command = function, arg1 = Sys.init, arg2 = 0
(Sys.init)
// Line 42: push constant 4
// Line 42: command = push, arg1 = constant, arg2 = 4
@4
D=A
@SP
A=M
M=D
@SP
M=M+1
// Line 43: call Main.fibonacci 1   // Compute the 4'th fibonacci element
// Line 43: command = call, arg1 = Main.fibonacci, arg2 = 1
@Main.fibonacci
D=A
@R15
M=D
@1
D=A
@R14
M=D
@_7
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
(_7)
// Line 44: label WHILE
// Line 44: command = label, arg1 = WHILE, arg2 = 
(Sys.init$WHILE)
// Line 45: goto WHILE              // Loop infinitely
// Line 45: command = goto, arg1 = WHILE, arg2 = 
@Sys.init$WHILE
0;JMP

// Performing system initialization
// Initialize the stack pointer to 256
@256
D=A
@SP
M=D
// Processing file ../FunctionCalls/SimpleFunction\SimpleFunction.vm; short file name = SimpleFunction
// Line 1: // This file is part of www.nand2tetris.org
// Line 2: // and the book "The Elements of Computing Systems"
// Line 3: // by Nisan and Schocken, MIT Press.
// Line 4: // File name: projects/08/FunctionCalls/SimpleFunction/SimpleFunction.vm
// Line 5: 
// Line 6: // Performs a simple calculation and returns the result.
// Line 7: function SimpleFunction.test 2
// Line 7: command = function, arg1 = SimpleFunction.test, arg2 = 2
(SimpleFunction.test)
@2
D=-A
(_1)
@SP
AM=M+1
A=A-1
M=0
@_1
D=D+1;JLT
// Line 8: push local 0
// Line 8: command = push, arg1 = local, arg2 = 0
@LCL
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
// Line 9: push local 1
// Line 9: command = push, arg1 = local, arg2 = 1
@LCL
D=M
@1
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 10: add
// Line 10: command = add, arg1 = add, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M+D
// Line 11: not
// Line 11: command = not, arg1 = not, arg2 = 
@SP
A=M-1
M=!M
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
// Line 13: add
// Line 13: command = add, arg1 = add, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M+D
// Line 14: push argument 1
// Line 14: command = push, arg1 = argument, arg2 = 1
@ARG
D=M
@1
D=D+A
A=D
D=M
@SP
A=M
M=D
@SP
M=M+1
// Line 15: sub
// Line 15: command = sub, arg1 = sub, arg2 = 
@SP
AM=M-1
D=M
A=A-1
M=M-D
// Line 16: return
// Line 16: command = return, arg1 = , arg2 = 
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

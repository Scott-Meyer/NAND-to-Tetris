Program written in the Racket programming langauge

Please download racket from "https://racket-lang.org/" to test compiling or any function in the provided interpreter (requires commenting out line for CMD args at end of file)

To use provided exe simply run "VMTranslator.exe [path]"
example: VMtranslator.exe "D:/Documents/nand2tetris/projects/08/FunctionCalls/StaticsTest"


Note: Had to do some hacky logic that checks if the file has functions in it or not, and do some initial stuffs.
Also, may not work with \ in place of /, worked when I made sure to excape them (IE: D:\\Documents) but only one of my computers.


PS: If you are grading my project 7 at the same time, and using the provided project folder, you will get crazy errors because I acedentally left
hidden OSX files in ther (IE .something.vm) and my program finds them... gives super bad error.
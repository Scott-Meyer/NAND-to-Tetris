Run assembler.exe

Enter the location (path+name of asm file).
The path/name is sensitive to capitals
here are some examples:
    add/Add.asm
    ../pong/Pong.asm


Once you enter a asm file, a '.hack' file of the same name will be created in the same directory.


IMPORTANT
I made some big mistakes coding this. Everything works, but it takes an inordinate amount of time.
For example, the pong.asm file takes 10-25minutes. But it DOES work, just give it time.


If for some reason, the executable doesn't work, or you need a MAC/Linux executable you can re-compile the project
Simply download the haskell platform (https://www.haskell.org/downloads#platform).
After install, open a commandprompt/terminal and browse to the location of the assembler.hs file
type 'ghc assembler' to make an executable file
Alternativly, you can run the file in the interpreter. Run 'ghci assembler.hs' then type 'main'.
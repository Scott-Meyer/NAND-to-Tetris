To use VMTranslator:

Extract entire "P08" folder.
Open and run "main.exe"

When prompted, enter path to VM files (May be a specific file, or a folder containing the VM)
	If choosing to enter path to folder, do not leave a tailing /. 
		For example:	  Correct: tests/MemoryAccess/BasicTest
				Incorrect: test/MemoryAccess/BasicTest/


Once you enter a path the new ASM will be saved to the location of the VM you entered. (name of ASM file will be name of folder)
You may now enter another path.

Close to exit.


Note: I put a rule in for Sys.init, if a function definition of Sys.init is found the auto calling to be put in, if there isn't one it won't.
(there is a minor mistake in this, it doesn't actually look for the full defenition just "Sys.init" so if you 
have a comment like "//note this doesn't use a Sys.init function" it will attempt to run it.
-- This is probably the messiest bit of haskell
--     I have ever made
--     But it works.... if stupdly slowly.

module Main where

import Text.Regex
import Data.List.Split
import Text.Printf
import Debug.Trace

file = "add/Add.asm"
type Labels = [(String, Int)]

commands = [("0","0101010")
           ,("1","0111111")
           ,("-1","0111010")
           ,("D","0001100")
           ,("A","0110000")
           ,("M","1110000")
           ,("!D","0001101")
           ,("!A","0110001")
           ,("!M","1110001")
           ,("-D","0001111")
           ,("-A","0110011")
           ,("-M","1110011")
           ,("D+1","0011111")
           ,("A+1","0110111")
           ,("M+1","1110111")
           ,("D-1","0001110")
           ,("A-1","0110010")
           ,("M-1","1110010")
           ,("D+A","0000010")
           ,("D+M","1000010")
           ,("D-A","0010011")
           ,("D-M","1010011")
           ,("A-D","0000111")
           ,("M-D","1000111")
           ,("D&A","0000000")
           ,("D&M","1000000")
           ,("D|A","0010101")
           ,("D|M","1010101")]
jumps = [("None","000")
        ,("JGT","001")
        ,("JEQ","010")
        ,("JGE","011")
        ,("JLT","100")
        ,("JNE","101")
        ,("JLE","110")
        ,("JMP","111")]
dests = [("M","001")
        ,("D","010")
        ,("MD","011")
        ,("A","100")
        ,("AM","101")
        ,("AD","110")
        ,("AMD","111")]

assemble :: String -> String
assemble str = foldl (\ acc x -> acc ++ (proc lab x) ++ "\n") "" (stripLabels assembly)
    where decomment = lines (subRegex (mkRegex commentRE) str "")
          assembly = [str | str<-decomment, str /= ""]
          commentRE = "([/]{2}).*|[ ]+|[\t]+|[\r]+"
          lab = l ++ (symbols l assembly)
          l = labels assembly

cmd_decode :: String -> String
cmd_decode str = snd (head [x|x<-commands, fst x == str])

dest_decode :: String -> String
dest_decode str = snd (head [x|x<-dests, fst x == str])

jmp_decode :: String -> String
jmp_decode str = snd (head [x|x<-jumps, fst x == str])

proc :: Labels -> String -> String
proc labs str
    | head str == '@' = a_cmd labs str
    | '=' `elem` str  = c_cmd str
    | ';' `elem` str  = jmp_cmd str
    | otherwise = "Error"

a_cmd :: Labels -> String -> String
a_cmd labs str 
    |head strnum `elem` ['0'..'9'] = '0' : fbinary num
    |tail str == "SCREEN" = "0100000000000000"
    |tail str == "KBD"    = "0110000000000000"
    |tail str == "SP"     = "0000000000000000"
    |tail str == "LCL"    = "0000000000000001"
    |tail str == "ARG"    = "0000000000000010"
    |tail str == "THIS"   = "0000000000000011"
    |tail str == "THAT"   = "0000000000000100"
    |otherwise = '0' : fbinary (head [x | (lab, x)<-labs, lab==(tail str)])
    where num = read strnum :: Int
          strnum = if (head (tail str) == 'R') then tail (tail str) else tail str
          binary x = (printf "%b" x) :: String
          fbinary x = (take (15 - (length (binary x))) (repeat '0')) ++ (binary x)

c_cmd :: String -> String
c_cmd str = "111" ++ (cmd_decode cmd) ++ (dest_decode dest) ++ "000"
    where (dest:cmd:_) = splitOn "=" str

jmp_cmd :: String -> String
jmp_cmd str = "111" ++ (cmd_decode cond) ++ "000" ++ (jmp_decode jmp)
    where (cond:jmp:_) = splitOn ";" str

labels :: [String] -> Labels
labels str = labels' 0 str
labels' :: Int -> [String] -> Labels
labels' _ [] = []
labels' i (x:xs)
    |head x == '(' = (tail (init x), i) : (labels' i xs)
    |otherwise     = labels' (i+1) xs

symbols :: Labels -> [String] -> Labels
symbols labs asm = symbols' 16 labs asm
symbols' :: Int -> Labels -> [String] -> Labels
symbols' _ _ [] = []
symbols' i labs (x:xs)
    | isSymb    = if (tail x `notElem` (map fst labs))
                        then (tail x, i) : symbols' (i+1) ((tail x, i):labs) xs
                        else symbols' i labs xs
    | otherwise = symbols' i labs xs
    where isSymb  = and [head x == '@'
                        , second /= 'R'
                        , second `notElem` ['0'..'9']
                        , tail x /= "SCREEN"
                        , tail x /= "KBD"
                        , tail x /= "SP"
                        , tail x /= "LCL"
                        , tail x /= "ARG"
                        , tail x /= "THIS"
                        , tail x /= "THAT"]
          second = head (tail x)


stripLabels :: [String] -> [String]
stripLabels [] = []
stripLabels (x:xs)
    |head x == '(' = stripLabels xs
    |otherwise     = x : stripLabels xs
          
runner :: IO ()
runner = do 
    putStrLn "Enter file name (\"exit\" to quit): "
    inl <- getLine
    if (inl == "exit")
        then putStrLn "Bye."
        else do 
            f <- readFile inl
            let assembled = assemble f
            let newfile = take (length inl - 4) inl ++ ".hack"
            writeFile newfile assembled
            putStrLn ("File written to " ++ newfile)
            runner

main :: IO ()
main = putStrLn "Welcome to haskell HACK assembler" >> runner

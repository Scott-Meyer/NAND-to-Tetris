func :: Int -> String
func x 
    | x > 15 = ""
    | otherwise = "Bit(in=in["
                ++ show x ++ "], load=loud, out=out["
                ++ show x ++ "]);\n" 
                ++ (func (x + 1))
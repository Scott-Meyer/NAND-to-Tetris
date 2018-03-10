func :: Int -> String
func x 
    | x > 15 = ""
    | otherwise = "FullAdder(a=a[" 
                ++ show x ++ "], b=b[" 
                ++ show x ++ "], c=c" 
                ++ show (x - 1) ++", sum=out[" 
                ++ show x ++"], carry=c" 
                ++ show x ++ ");\n" 
                ++ (func (x + 1))
import Data.List

filepath = "./assets/24.txt"
windowMin = 200000000000000
windowMax = 400000000000000

cleanInput :: String -> String
cleanInput [] = []
cleanInput (x:xs)
    | x == '@' || x == ',' = cleanInput xs
    | otherwise = x:cleanInput xs

inputToHailsList f = do
    content <- readFile f
    let hails = map (map read) $ map words $ map cleanInput $ lines content :: [[Float]]
    return hails

intersectionPoint :: ( [Float] , [Float] ) -> [Float]
intersectionPoint ( [x,y,_,vx,vy,_] , [x',y',_,vx',vy',_] )
    | denom == 0 = [windowMin-1, windowMin-1] -- unaccessible coordinate from the window
    | inpast == True = [windowMin-1,windowMin-1]
    | ix < windowMin || ix > windowMax = [windowMin-1,windowMin-1]
    | iy < windowMin || iy > windowMax = [windowMin-1,windowMin-1]
    | otherwise = [ix,iy]
    where
      a  = vy / vx
      a' = vy' / vx'
      b  = y - (a * x)
      b' = y' - (a' * x')
      denom = a' - a
      ix = (b - b') / denom
      iy = ((a' * b) - (a * b')) / denom
      inpast = inPast [ix,iy] [x,y,vx,vy] [x',y',vx',vy']

inPast :: [Float] -> [Float] -> [Float] -> Bool
inPast [ix,iy] [x,y,vx,vy] [x',y',vx',vy']
    | (vx == 0 && vy >  0 && y < iy) || (vx' == 0 && vy' >  0 && y' < iy) = True
    | (vx == 0 && vy <  0 && y > iy) || (vx' == 0 && vy' <  0 && y' > iy) = True
    | (vx > 0  && vy == 0 && ix < x) || (vx' > 0  && vy' == 0 && ix < x') = True
    | (vx > 0  && vy >  0 && ix < x) || (vx' > 0  && vy' >  0 && ix < x') = True
    | (vx > 0  && vy >  0 && iy < y) || (vx' > 0  && vy' >  0 && iy < y') = True
    | (vx > 0  && vy <  0 && ix < x) || (vx' > 0  && vy' <  0 && ix < x') = True
    | (vx > 0  && vy <  0 && iy > y) || (vx' > 0  && vy' <  0 && iy > y') = True
    | (vx < 0  && vy == 0 && ix > x) || (vx' < 0  && vy' == 0 && ix > x') = True
    | (vx < 0  && vy >  0 && ix > x) || (vx' < 0  && vy' >  0 && ix > x') = True
    | (vx < 0  && vy >  0 && iy < y) || (vx' < 0  && vy' >  0 && iy < y') = True
    | (vx < 0  && vy <  0 && ix > x) || (vx' < 0  && vy' <  0 && ix > x') = True
    | (vx < 0  && vy <  0 && iy > y) || (vx' < 0  && vy' <  0 && iy > y') = True
    | otherwise = False

getAllPairs list = [(x,y) | (x:ys) <- tails list, y <- ys]

main = do
    hails <- inputToHailsList filepath
    print $ length $ [intersection | intersection <- ( map intersectionPoint $ getAllPairs hails), intersection /=  [windowMin-1, windowMin-1]]

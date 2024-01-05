-- to be cringed about soon...
import Data.Scientific -- for arbitrary precision arithmetic

filepath = "./assets/24.txt"

cleanInput :: String -> String
cleanInput [] = []
cleanInput (x:xs)
    | x == '@' = cleanInput xs
    | x == ',' = cleanInput xs
    | otherwise = x:cleanInput xs

inputToHailsList f = do
    content <- readFile f
    let hails = map (map read) $ map words $ map cleanInput $ lines content :: [[Scientific]]
    return hails

-- Normalized hail gets substracted the [x,y,z,vx,vy,vz] of hail 0
normalizeHail :: [Scientific] -> [Scientific] -> [Scientific]
normalizeHail [x,y,z,vx,vy,vz] [x',y',z',vx',vy',vz'] = [x'-x, y'-y,z'-z,vx'-vx, vy'-vy,vz'-vz]

normalVector :: [Scientific] -> [Scientific]
normalVector [x,y,z,vx,vy,vz] = [y * vz - z * vy, z * vx - x * vz, x * vy - y * vx]

h1Minush2 :: [Scientific] -> [Scientific] -> [Scientific]
h1Minush2 [x,y,z,_,_,_] [x',y',z',_,_,_] = [x-x',y-y',z-z']

planeIntersection :: [Scientific] -> [Scientific] -> [Scientific] -> Scientific -> [Scientific]
planeIntersection [x,y,z,vx,vy,vz] [nx,ny,nz] [dx,dy,dz] time = [x+(vx*time),y+(vy*time),z+(vz*time)]

time :: [Scientific] -> [Scientific] -> [Scientific] -> Scientific
time [x,y,z,vx,vy,vz] [nx,ny,nz] [dx,dy,dz] = (dx*nx+dy*ny+dz*nz)/(vx*nx+vy*ny+vz*nz)

rockVelocity :: [Scientific] -> [Scientific] -> Scientific -> Scientific -> [Scientific]
rockVelocity [x,y,z] [x',y',z'] t2 t3 = [(x'-x)/(t3-t2),(y'-y)/(t3-t2),(z'-z)/(t3-t2)]

rockPosition :: [Scientific] -> [Scientific] -> Scientific -> [Scientific]
rockPosition [x,y,z] [rvx,rvy,rvz] t3 = [x+(rvx*(0-t3)),y+(rvy*(0-t3)),z+(rvz*(0-t3))]

rockPositionNormalized :: [Scientific] -> [Scientific] -> [Scientific]
rockPositionNormalized [x,y,z,_,_,_] [rx,ry,rz] = [rx+x,ry+y,rz+z]

main = do
    hails <- inputToHailsList filepath
    -- make everything relative to h0 (origin)
    let h1 = normalizeHail (hails !! 0) (hails !! 1)
    let normal = normalVector h1 -- the rock should pass in the plane crossing h1 trajectory and the origin
    -- find when and where to arbitrary hails will cross the plane
    let h2 = normalizeHail (hails !! 0) (hails !! 2)
    let h3 = normalizeHail (hails !! 0) (hails !! 3)
    let h1Diffh2 = h1Minush2 h1 h2
    let h1Diffh3 = h1Minush2 h1 h3
    let t2 = time (normalizeHail (hails !! 0) (hails !! 2)) normal h1Diffh2
    let t3 = time (normalizeHail (hails !! 0) (hails !! 3)) normal h1Diffh3
    let h2Inter = planeIntersection (normalizeHail (hails !! 0) (hails !! 2)) normal h1Diffh2 t2
    let h3Inter = planeIntersection (normalizeHail (hails !! 0) (hails !! 3)) normal h1Diffh3 t3
    -- deduce velocity of the rock, go backward in time to find its original position after renormalizing frame of reference
    let rockVel = rockVelocity h2Inter h3Inter t2 t3
    let rockPos = rockPosition h3Inter rockVel t3
    let rockNorm = rockPositionNormalized (hails !! 0) rockPos
    print (sum rockNorm)

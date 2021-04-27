module Main where
import Lib
import Graphics.Gloss
import Graphics.Gloss.Data.ViewPort
import Graphics.Gloss.Interface.Pure.Game

type Position = (Float, Float)
type Velocity = Float
type Object  = (Position, Velocity, Picture)

-- Defining game elements
data SpaceSurvivalGame = Game
  { shipLocation :: (Float, Float)        
  , shipHVelocity :: Float
  , asteroidPosition :: (Float, Float)
  , bulletPosition :: (Float, Float)
  , player :: Object
  , bullets :: [Object]
  , asteroids :: [Object]
  , paused :: Bool
  } deriving Show

-- Initial game state
initialState :: SpaceSurvivalGame
initialState = Game
  { shipLocation = (0,-250)
  , shipHVelocity = 0
  , asteroidPosition = (0, 250)
  , bulletPosition = (0,0)
  , player = ((0,-250), 0, ship)
  , bullets = [((0,0),0, bullet)]
  , asteroids = [((0,250), 0, asteroid 5 5)]
  , paused = False  
  }

asteroid :: Float -> Float -> Picture
asteroid w h = scale w h $ color white $ lineLoop
          [(1,5),(1,6),(2,4),(3,3),(4,3),(4,2),(3,2),(4,0),(3,-1),(2,-3),(0,-3),(-3,1),(-4,2),(-4,3),(-2,3),(1,5)]

bullet :: Picture
bullet = color white $ rectangleSolid 3 5

ship :: Picture
ship = color white $ lineLoop [(10,0), (0,25 ), (-10, 0), (9,0)]                

-- Draw all pictures at screen
drawObject :: Object -> Picture
drawObject ((x,y), v, p) =
  translate x y p

drawGame :: [Object] -> Picture
drawGame objects = 
  pictures $ map drawObject objects        

render :: SpaceSurvivalGame -> Picture
render game = 
    pictures [ drawObject (player game)            
             , drawGame (bullets game)
             , drawGame (asteroids game)]


-- Keys configurations
handleKeys :: Event -> SpaceSurvivalGame -> SpaceSurvivalGame
handleKeys (EventKey (SpecialKey KeyLeft ) Down _ _) game = game { player = updateVelocity (player game) (-playerSpeed)}
handleKeys (EventKey (SpecialKey KeyLeft ) Up _ _) game = game {player = updateVelocity (player game) 0}
handleKeys (EventKey (SpecialKey KeyRight ) Down _ _) game = game {player = updateVelocity (player game) playerSpeed}
handleKeys (EventKey (SpecialKey KeyRight ) Up _ _) game = game {player = updateVelocity (player game) 0}
handleKeys (EventKey (SpecialKey KeySpace ) Down _ _) game = bulletsGenerator game
-- handleKeys (EventKey (SpecialKey KeyUp ) Up _ _) game = game {}
-- handleKeys (EventKey (SpecialKey KeyDown ) Down _ _) game = game {}
-- handleKeys (EventKey (SpecialKey KeyDown ) Up _ _) game = game {}
handleKeys _ game = game

bulletsGenerator :: SpaceSurvivalGame -> SpaceSurvivalGame
bulletsGenerator game = game {bullets = (retrieveObjectPosition (player game), 0, bullet) : bullets game}

retrieveObjectPosition :: Object -> Position
retrieveObjectPosition ((x, y), v, p) = (x, y)

retrieveVelocity :: Object -> Float
retrieveVelocity ((x, y), v, p) = v

updateVelocity :: Object -> Float -> Object
updateVelocity  ((x, y), v, p ) velocity =  ((x, y), velocity, p )

updatePositionX :: Object -> Float
updatePositionX ((x, y), v, p)  = x + v

updatePositionY :: Object -> Float
updatePositionY ((x, y), v, p)  = y + v

updatePlayerPosition :: SpaceSurvivalGame -> SpaceSurvivalGame
updatePlayerPosition game = game {player = ((limitMovement x' width 20,  y ), v, ship)}
                        where
                          y = -250
                          x' = updatePositionX (player game)
                          v = retrieveVelocity( player game)


-- Call the all functions and update the game
update :: Float -> SpaceSurvivalGame -> SpaceSurvivalGame
update seconds game = if not (paused game) then updatePlayerPosition game else game

limitMovement :: Float -> Int -> Float -> Float
limitMovement move width playerWidth
        | move < leftLimit = leftLimit
        | move > rightLimit = rightLimit 
        | otherwise = move
        where
          leftLimit = playerWidth/2 - fwidth/2 
          rightLimit = fwidth /2 - playerWidth/2
          fwidth = fromIntegral width :: Float

playerSpeed :: Float
playerSpeed = 5

-- Window dimensions
width, height, offset :: Int
width = 400
height = 600
offset = 150

-- Window configurations
window :: Display
window = InWindow "Space Survival" (width, height) (offset, offset)

-- Background color/image
background :: Color
background = black

-- Frames per second
fps :: Int
fps = 60

-- Main
main :: IO ()
main = play window background fps initialState render handleKeys update
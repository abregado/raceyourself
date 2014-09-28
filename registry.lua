--requires
lane = require('lane')
block = require('block')
powerup = require('powerup')
tc = require('touch')
scoring = require('scoring')
player = require('player')
HC = require('HardonCollider')
camera = require ('hump-master/camera')
vl = require ('hump-master/vector-light')
shapes = require ('HardonCollider.shapes')
tween = require ('tween')


--global declarations
lg = love.graphics
lm = love.mouse
lw = love.window

DEBUG_MODE = true

LANES = 3
BLOCK_SPEED = 300
AI_DELAYMAX = 67

DEATH_TIME = 5
PUNCH_TIME = 0.5
STUN_TIME = 1.5

PUNCH_DIST = 0.175

JUMP_HALF_DUR = 0.3
JUMP_DELAY_DUR = 0.1
LANE_SWAP_DUR = 0.2


playerSize = 0.3 * lw.getHeight() / (LANES * 3)

VIEWCONE = {w=playerSize*3,h=playerSize*2}

--player globals
tapThreshold = 10
touchMoved = false

horizSwipeRatio = 1.5
vertSwipeRatio = 1.5

percentPlayerX = 0.1
playerLane = math.ceil(LANES / 2)

--control
cont={}
cont.jump = "up"
cont.crouch = "down"
cont.punch = "right"
cont.laneUp = "w"
cont.laneDown = "s"
cont.quit = "escape"

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}
laneGFX = {w=screen.w,h=screen.h/LANES}

gfx = {}

level={}
level.lanes={}
level.players={}
level.activePlayer = nil
level.collider = HC.new()
    

color = {}
color.lane = {30,30,30}
color.divider = {255,255,255}
color.colliding = {60,60,60}
color.debug = {255,255,255}
color.controlled = {255,255,255}
color.block={}
color.block[1] = {255,0,0}
color.block[2] = {0,255,0}
color.block[3] = {0,0,255}


COLORS = {{255,0,0},
          {0,255,0},
          {0,0,255},
          {255,255,0},
          {0,255,255},
          {255,0,255},
          {255,255,255}}

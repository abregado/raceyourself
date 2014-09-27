--requires
lane = require('lane')
block = require('block')
tc = require('touch')
player = require('player')
HC = require('HardonCollider')
camera = require ('hump-master/camera')
vl = require ('hump-master/vector-light')
shapes = require ('HardonCollider.shapes')


--global declarations
lg = love.graphics
lm = love.mouse
lw = love.window

LANES = 3
BLOCK_SPEED = 300

--player globals
tapThreshold = 10
touchMoved = false

horizSwipeRatio = 1.5
vertSwipeRatio = 1.5

percentPlayerX = 0.1
playerSize = 0.3 * lw.getHeight() / (LANES * 3)

playerLane = math.ceil(LANES / 2)

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}
laneGFX = {w=screen.w,h=screen.h/LANES}

gfx = {}

level={}
level.lanes={}
level.players={}
level.activePlayer = nil

color = {}
color.lane = {30,30,30}
color.divider = {255,255,255}
color.colliding = {60,60,60}
color.debug = {60,255,60}
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

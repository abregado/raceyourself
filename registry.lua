--requires
lane = require('lane')
block = require('block')

--global declarations
lg = love.graphics

LANES = 3
BLOCK_SPEED = 10

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}
laneGFX = {w=screen.w,h=screen.h/LANES}

gfx = {}

level={}
level.lanes={}

color = {}
color.lane = {30,30,30}
color.divider = {255,255,255}
color.block={}
color.block[1] = {255,0,0}
color.block[2] = {0,255,0}
color.block[3] = {0,0,255}

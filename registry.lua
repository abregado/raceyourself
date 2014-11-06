--global declarations
la = love.audio
lg = love.graphics
lm = love.mouse
lw = love.window
fs = love.filesystem

--requires
lane = require('lane')
block = require('block')
powerup = require('powerup')
tc = require('touch')
ps = require('particles')
scoring = require('scoring')
player = require('player')
HC = require('HardonCollider')
camera = require ('hump-master/camera')
vl = require ('hump-master/vector-light')
shapes = require ('HardonCollider.shapes')
tween = require ('tween')
an = require ('anim8/anim8')
dataControl = require('dataControl')
gs = require('hump-master/gamestate')
list = require('buttonlist')
button = require('button')
require('serialize')


fonts = {}
fonts[1] = lg.newFont()
lg.setFont(fonts[1])

scoreboard = {}
timeScore = 20
killScore = 100
coinScore = 300
rawData = {}

DEBUG_MODE = false

LANES = 3
AI_DELAYMAX = 67

DEATH_TIME = 5
PUNCH_TIME = 0.5
STUN_TIME = 0.5

PUNCH_DIST = 0.175

JUMP_HALF_DUR = 0.3
JUMP_DELAY_DUR = 0.1
LANE_SWAP_DUR = 0.2

playerSize = 0.3 * lw.getHeight() / (LANES * 3)

BLOCKSIZE = playerSize*2
ROTSPEED=10

ANDROID_INSTRUCTIONS = "Swipe up and down to dodge, Swipe forward to attack. Tap a lane to swap with your wingman"
DESKTOP_INSTRUCTIONS = "Press UP and DOWN to dodge, Press RIGHT to attack. Press W and S to swap places with a your wingmen"
ANDROID_RESTART = "Tap to restart"
DESKTOP_RESTART = "Press R to restart, or escape to return to the menu"
START_LIVES = 5

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
cont.restart = "r"

--graphics globals
screen = {w=lg.getWidth(),h=lg.getHeight()}
laneGFX = {w=screen.w,h=screen.h/LANES}

START_BLOCK_SPEED = laneGFX.w /1.5
BLOCK_SPEED = laneGFX.w
MAX_BLOCK_SPEED = laneGFX.w*1.3
if love.system.getOS() == "Android" then
    MAX_BLOCK_SPEED = laneGFX.w
end

--gamestates
state={}
state.menu = require('state_menu')
state.game = require('state_game')
state.score = require('state_score')

VIEWCONE = {w=playerSize*5,h=screen.h/LANES*.9}
gfx = {}

level = require 'level'
    

color = {}
color.lane = {30,30,30}
color.divider = {255,255,255}
color.colliding = {60,60,60}
color.debug = {255,255,0}
color.respawn = {255,255,255,80}
color.render = {255,255,255,255}
color.controlled = {255,255,255}
color.contOverlay = {255,0,0}
color.menuBG = {47,199,193}
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
          
sheets = {}

anims = {}
          
as = {}
as.pShip={}
as.pShip[1] = lg.newImage('assets/rship_sheet.png')
as.pShip[2] = lg.newImage('assets/gship_sheet.png')
as.pShip[3] = lg.newImage('assets/bship_sheet.png')
as.pBullet={}
as.pBullet[1] = lg.newImage('assets/rbullet.png')
as.pBullet[2] = lg.newImage('assets/gbullet.png')
as.pBullet[3] = lg.newImage('assets/bbullet.png')
as.laneBG = lg.newImage('assets/bg_tile.png')
as.laneOver = lg.newImage('assets/lane_overlay.png')
as.eShip ={}
as.eShip[1] = lg.newImage('assets/renemy.png')
as.eShip[2] = lg.newImage('assets/genemy.png')
as.eShip[3] = lg.newImage('assets/benemy.png')
as.pup = lg.newImage('assets/powerup.png')
as.asteroid = {}
as.asteroid[1] = lg.newImage('assets/a1.png')
as.asteroid[2] = lg.newImage('assets/a2.png')
as.asteroid[3] = lg.newImage('assets/a3.png')
as.title = lg.newImage('assets/title.png')


-- sounds globals

sfx = {}
sfx.explosion = la.newSource("assets/SFX/explosion.ogg", "static")
sfx.impact = la.newSource("assets/SFX/impact.ogg", "static")
sfx.powerup = la.newSource("assets/SFX/powerup.ogg", "static")
sfx.punch = la.newSource("assets/SFX/punch.ogg", "static")
sfx.respawn = la.newSource("assets/SFX/respawn.ogg", "static")
sfx.switch = la.newSource("assets/SFX/switch.ogg", "static")
sfx.theme = {}
--sfx.theme[1] = la.newSource("assets/music/theme1.mp3")
sfx.theme[2] = la.newSource("assets/music/theme2.mp3")
--sfx.theme[3] = la.newSource("assets/music/theme3.mp3")

currentTheme = 2


-- HUD

edgeBuffer = lw.getHeight() * 0.02

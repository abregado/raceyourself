-- Entry menu contains a buttonlist and some visual data

local sboard = {}
local font = lg.newFont(30)
local color = {}
color.font = {255,255,255}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local pos = {}
pos.x = screen.w/4
pos.y = (screen.h/6*4)+1

function sboard:init()
    self.mlist = list.new(pos.x,pos.y,1,self)
    self.mlist.buttons[1].label = "Back to Menu"
    self.mlist.buttons[1].click = function() gs.switch(state.menu) end
    sboard.clicked = false
    sboard.texts = {}
end

function sboard:enter(from)
    sboard.clicked = false
    
    sboard.texts[1] = "Current High Score"
    sboard.texts[2] = tostring(math.floor(score:getHighScore()))
    sboard.texts[3] = " "
    sboard.texts[4] = "Average of Top Three Scores"
    if score:getBestAverage() then
        sboard.texts[5] = tostring(math.floor(score:getBestAverage()))
    else
        sboard.texts[5] = "play three games to get your average"
    end
    sboard.texts[6] = " "
    sboard.texts[7] = "Total Games Played"
    sboard.texts[8] = tostring(score:getGamesPlayed())
    
end

function sboard:draw()
    
	self.mlist:draw()
    lg.setFont(font)
    lg.setColor(color.font)
    local y = 25
    for i,v in ipairs(sboard.texts) do
        local x = (screen.w/2) - (font:getWidth(v)/2)
        
        lg.print(v,x,y)
        y=y+font:getHeight()
    end
end

function sboard:keypressed(key,code)
    if DEBUG_MODE then
        if key == "s" then
            dataControl.save()
        elseif key == "l" then
            dataControl.load()
        end
    end
end

function sboard:mousepressed(x,y,button)
    sboard.clicked = true
end

function sboard:mousereleased(x,y,button)
	local b = self.mlist:checkClick(x,y)
	if button == "l" and b and sboard.clicked then
		b:click()
	end
    sboard.clicked=false
end

function sboard:leave()
end

function sboard:update(dt)
end

return sboard

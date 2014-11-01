-- Entry menu contains a buttonlist and some visual data

local sboard = {}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local pos = {}
pos.x = screen.w/4
pos.y = (screen.h/6*5)+1

function sboard:init()
    self.mlist = list.new(pos.x,pos.y,1,self)
    self.mlist.buttons[1].label = "Back to Menu"
    self.mlist.buttons[1].click = function() gs.switch(state.menu) end
    sboard.clicked = false
end

function sboard:enter(from)
    sboard.clicked = false
end

function sboard:draw()
	self.mlist:draw()
    lg.print("total scores saved: "..#scoreboard,0,0)
    local y = 25
    for i,v in ipairs(scoreboard) do
        lg.print(v.score,0,y)
        y=y+25
    end
    lg.print("Highscore: "..score:getHighScore(),0,y)
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

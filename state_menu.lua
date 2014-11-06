-- Entry menu contains a buttonlist and some visual data

local menu = {}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local pos = {}
pos.x = screen.w/4
pos.y = screen.h/4

function menu:init()
    menu.titleScale = screen.w/as.title:getWidth()
    pos.y = as.title:getHeight()*menu.titleScale*1.1
    self.mlist = list.new(pos.x,pos.y,3,self)
    self.mlist.buttons[1].label = "Start Game"
    self.mlist.buttons[1].click = function() gs.switch(state.game) end
    self.mlist.buttons[2].label = "Scoreboard"
    self.mlist.buttons[2].click = function() gs.switch(state.score) end
    self.mlist.buttons[3].label = "Quit"
    self.mlist.buttons[3].click = function() love.event.quit() end
    menu.clicked = false
    
    
end

function menu:enter(from)
    menu.clicked = false
    lg.setBackgroundColor(color.menuBG)
end

function menu:draw()
    lg.setColor(255,255,255)
    lg.draw(as.title,0,0,0,menu.titleScale)
	self.mlist:draw()
end

function menu:keypressed(key,code)
    if DEBUG_MODE then
        if key == "s" then
            dataControl.save()
        elseif key == "l" then
            dataControl.load()
        end
    end
end

function menu:mousepressed(x,y,button)
    menu.clicked = true
end

function menu:mousereleased(x,y,button)
	local b = self.mlist:checkClick(x,y)
	if button == "l" and b and menu.clicked then
		b:click()
	end
    menu.clicked=false
end

function menu:leave()
end

function menu:update(dt)
end

return menu

-- a column of buttons acting as a single object
lg = love.graphics
lm = love.mouse

local list = {}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local size = {}
size.buttonHSpace = screen.h/24
size.buttonHeight = screen.h/6
size.buttonWidth = screen.w/2

function list.new(xin,yin,bquant,state)
	local o = {}
	o.buttons = {}
	o.x = xin or 0
	o.y = yin or 0
	o.spacing = size.buttonHSpace
    o.height = size.buttonHeight
    o.width = size.buttonWidth
	o.state = state
	
	o.addButton = list.addButton
	o.draw = list.draw
	o.checkClick = list.checkClick
		
	for i=1,bquant do
		o:addButton()
	end
	
	return o
end

function list:addButton()
    local newbut = button.new(self.x,self.y+(#self.buttons*(self.height+self.spacing)),self.width,self.height)
	table.insert(self.buttons,newbut)
end

function list:draw()
	lg.setColor(255,255,255)
	for i,v in ipairs(self.buttons) do
		v:draw()
	end
end

function list:checkClick(xin,yin)
	for i,v in ipairs(self.buttons) do
		if v:check() then
			return v
		end
	end
	return nil
end


return list

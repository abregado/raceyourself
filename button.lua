-- menu button to be added to button lists and stacked vertically

lg = love.graphics
lm = love.mouse


local button = {}

button.font = lg.newFont(30)

local colors = {}
colors.ready = {160,150,150}
colors.clicked = {0,255,0}
colors.hover = {0,0,255}
colors.bg = {60,60,60}
colors.font = {30,30,30}


function button.new(xin,yin,win,hin)
	local o = {}
	o.x = xin
	o.y = yin
	o.w = win
	o.h = hin
	o.qbase = lg.newQuad(0,0,320,32,320,96)
	o.qhover = lg.newQuad(0,32,320,32,320,96)
	o.qclick = lg.newQuad(0,64,320,32,320,96)
    o.label = "Unlabeled Button"
    
    o.colors={}
    o.colors.ready = colors.ready
    o.colors.clicked = colors.clicked
    o.colors.hover = colors.hover
    o.colors.bg = colors.bg
    o.colors.font = colors.font
    
	o.click = button.click
	o.draw = button.draw
	o.check = button.check
	
	return o
end

function button:click()
	return true
end

function button:draw()
	local label = self.label
	lg.setColor(self.colors.bg)
    lg.rectangle("fill",self.x,self.y,self.w,self.h)
    
    local osString = love.system.getOS()
    if self:check() and osString ~= "Android" then
        if lm.isDown("l") then
		lg.setColor(self.colors.clicked)
		else
		lg.setColor(self.colors.hover)
		end
	else
		lg.setColor(self.colors.ready)
	end
    lg.rectangle("fill",self.x+5,self.y+5,self.w-10,self.h-10)
    lg.setColor(0,0,0,125)
    lg.setLineWidth(2)
    lg.rectangle("line",self.x+5,self.y+5,self.w-10,self.h-10)
    
    lg.setLineWidth(1)
	lg.setColor(self.colors.font)
    local font = button.font
	lg.setFont(font)
    local tw = font:getWidth(label)
    local th = font:getHeight(label)
    lg.print(label,self.x+(self.w/2)-(tw/2),self.y+(self.h/2)-(th/2))
	
	
end

function button:check()
	local mx,my = lm.getPosition()
	if mx >= self.x and mx <=self.x+self.w and my >= self.y and my <= self.y+self.h then
		return true
	else
		return false
	end
end

return button

local b = {}

function b.new(x,y,color,boxType)
    o={}
    
    o.x= x
    o.y= y
    
    o.w = BLOCKSIZE
    o.h = BLOCKSIZE
    
    o.isGarbage = false
    o.isBlock = true
    o.color = color
    o.rot = 0
    
    o.boxType = boxType
    
    o.cob = level.collider:addCircle(0,0,o.w/2)
    o.cob:moveTo(o.x,o.y)
    o.cob.parent = o
    
    b.setupMethods(o)
    
    return o
    
end

function b.setupMethods(o)
    o.move = b.move
    o.draw = b.draw
    o.destroy = b.destroy
    o.drawSprite = b.drawSprite
end

function b:move(dt)
    self.x = self.x - (dt*BLOCK_SPEED)
    
    if self.x+self.w < 0 then
        self:destroy()
        
    end
    
    self.cob:moveTo(self.x,self.y)
    self.rot = self.rot+dt*ROTSPEED
end

function b:draw()
    self:drawSprite()
    
    if DEBUG_MODE then
        lg.setColor(COLORS[self.color])
        self.cob:draw('line')
    end
end

function b:drawSprite()
    lg.setColor(color.render)
    local sp = as.eShip[self.color]
    local gw = sp:getWidth()
    local gh = sp:getHeight()
    local sx = BLOCKSIZE/gw*1.8
    local sy = BLOCKSIZE/gh*1.8
    local ox = gw/2*sx
    local oy = gh/2*sy
    lg.draw(sp,self.x-ox,self.y-oy,0,sx,sy)
end

function b:destroy()
    self.isGarbage=true
end

return b

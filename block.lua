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
    
    o.boxType = boxType
    
    o.cob = level.collider:addRectangle(0,0,o.w,o.h)
    o.cob:moveTo(o.x,o.y)
    o.cob.parent = o
    
    b.setupMethods(o)
    
    return o
    
end

function b.setupMethods(o)
    o.move = b.move
    o.draw = b.draw
    o.destroy = b.destroy
end

function b:move(dt)
    self.x = self.x - (dt*BLOCK_SPEED)
    
    if self.x+self.w < 0 then
        self:destroy()
        
    end
    
    self.cob:moveTo(self.x,self.y)
    
end

function b:draw(x,y)
    lg.setColor(COLORS[self.color])
    self.cob:draw('fill')
end

function b:destroy()
    self.isGarbage=true
end

return b

local b = {}

function b.new()
    o={}
    
    o.x=laneGFX.w
    o.y=0
    o.isGarbage = false
    o.w = laneGFX.h/3
    
    o.boxType = math.random(1,3)
    
        
    b.setupMethods(o)
    return o
    
end

function b.setupMethods(o)
    o.move = b.move
    o.draw = b.draw
end

function b:move(dt)
    self.x = self.x - (dt*BLOCK_SPEED)
    
    if self.x < 0 then
        self.isGarbage = true
    end
end

function b:draw(x,y)
    lg.setColor(color.block[1])
    lg.rectangle("fill",x+self.x,y+self.y,self.w,self.w)
end

return b

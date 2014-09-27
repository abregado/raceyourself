local b = {}

function b.new()
    o={}
    
    o.x=laneGFX.w
    o.y= laneGFX.h/3
    o.isGarbage = false
    o.w = laneGFX.h/3
    o.h = laneGFX.h/3
    
    o.boxType = math.floor(math.random(1,3))
    o.boxColor = math.floor(math.random(1,3))
    
    if o.boxType == 1 then
        o.y=0
        o.h=laneGFX.h/3*2
    elseif o.boxType == 2 then
    elseif o.boxType == 3 then
        o.h=laneGFX.h/3*2
    end
    
    b.setupMethods(o)
    return o
    
end

function b.setupMethods(o)
    o.move = b.move
    o.draw = b.draw
end

function b:move(dt)
    self.x = self.x - (dt*BLOCK_SPEED)
    
    if self.x+self.w < 0 then
        self.isGarbage = true
    end
end

function b:draw(x,y)
    lg.setColor(color.block[self.boxColor])
    
    lg.rectangle("fill",x+self.x,y+self.y,self.w,self.h)

end

return b

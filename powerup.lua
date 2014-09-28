local pu = {}

function pu.new(x,y)
    o = {}

    o.x= x
    o.y= y
    
    o.w = playerSize
    o.h = playerSize
    o.size = playerSize
    
    o.isGarbage = false
    o.isPowerup = true
    
    o.color = COLORS[4]
    
    o.cob = level.collider:addCircle(0,0,o.w)
    o.cob:moveTo(o.x,o.y)
    o.cob.parent = o
    
    pu.setupMethods(o)
    return o
end

function pu.setupMethods(o)
    o.move = pu.move
    o.draw = pu.draw
    o.destroy = pu.destroy
    o.drawSprite = pu.drawSprite
end


function pu:move(dt)
    self.x = self.x - (dt * BLOCK_SPEED)

    if self.x + self.size / 2 < 0 then
        self:destroy()
    end

    self.cob:moveTo(self.x, self.y)
end

function pu:draw()
    self:drawSprite()
    
    if DEBUG_MODE then
        if self.isGarbage then
            lg.setColor(0,0,0)
        else
            lg.setColor(self.color)
        end
        self.cob:draw('line')
    end
end

function pu:drawSprite()
    lg.setColor(color.render)
    local sp = as.pup
    local gw = sp:getWidth()
    local gh = sp:getHeight()
    local sx = self.size/gw*3.5
    local sy = self.size/gh*3.5
    local ox = gw/2*sx
    local oy = gh/2*sy
    lg.draw(sp,self.x-ox,self.y-oy,0,sx,sy)
end

function pu:destroy()
    self.isGarbage = true
end

return pu

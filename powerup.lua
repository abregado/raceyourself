local pu = {}

function pu.new(lane, b)
    o = {}

    o.isPowerup = true

    o.x, _ = b.cob:center()
    o.y = lane.y

    o.size = playerSize

    o.ox = 0
    o.oy = laneGFX.h / 6

    o.isGarbage = false
    o.lane = lane

    o.color = COLORS[4]

    pu.setupMethods(o)

    local pos

    if b then
        if b.boxType == 1 then
            o:setPos(3)
        elseif b.boxType == 2 then
            pos = math.floor(math.random(1,2))
            o:setPos(2 * pos - 1)
        else
            o:setPos(1)
        end
    else
        pos = math.floor(math.random(1,3))
        o:setPos(pos)
    end

    o.cob = level.collider:addCircle(o.x+o.ox, o.y+o.oy, o.size / 2)
    o.cob.parent = o

    return o
end

function pu.setupMethods(o)
    o.move = pu.move
    o.draw = pu.draw
    o.destroy = pu.destroy
    o.setPos = pu.setPos
end

function pu:setPos(pos)
    self.oy = ((2 * pos - 1) * laneGFX.h / 6)
end

function pu:move(dt)
    self.x = self.x - (dt * BLOCK_SPEED)

    if self.x + self.ox + self.size / 2 < 0 then
        self:destroy()
    end

    self.cob:moveTo(self.x+self.ox, self.y+self.oy)
end

function pu:draw()
    if self.isGarbage then
        lg.setColor(0,0,0)
    else
        lg.setColor(self.color)
    end
    self.cob:draw('fill')
end

function pu:destroy()
    self.isGarbage = true
end

return pu

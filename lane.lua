local l = {}

function l.new(pos)
    local o={}
    o.x = 0
    o.y = (pos-1)*laneGFX.h
    
    o.w = screen.w
    o.h = laneGFX.h
    o.bgBlocks = {}
    for i=0,4 do
        table.insert(o.bgBlocks,{x=i*o.w/3,y=o.y})
    end

    o.pos = pos
    o.blocks = {}
    o.powerups = {}
    o.player = nil

    l.setupMethods(o)
    
    return o

end

function l.setupMethods(o)
    --always add new object methods here
    o.draw = l.draw
    o.update = l.update
    o.removeBlocks = l.removeBlocks
    o.spawnBlock = l.spawnBlock
    o.removePowerups = l.removePowerups
    o.spawnPowerup = l.spawnPowerup
    o.givePlayer = l.givePlayer
    o.withinBounds = l.withinBounds
    o.drawBlocks = l.drawBlocks
    o.drawPowerups = l.drawPowerups
    
    return o
end 

function l:draw()
    lg.setColor(255,255,255)
    
    --[[for i,v in ipairs(self.bgBlocks) do
        local gw = as.laneBG:getHeight()
        local gh = as.laneBG:getHeight()
        local sx = self.w/gw/3
        local sy = self.h/gh
        lg.draw(as.laneBG,v.x,v.y,0,sx,sy)
    end]]
    
    if self.player.isControlled then
        local gw = as.laneOver:getHeight()
        local gh = as.laneOver:getHeight()
        local sx = self.w/gw/3
        local sy = self.h/gh
        lg.setColor(COLORS[self.player.color])
        lg.setBlendMode('additive')
        lg.draw(as.laneOver,self.x,self.y,0,sx,sy)
        lg.setBlendMode('alpha')
    end
    
    
    
end

function l:drawBlocks()
    --draw all blocks in this lane
    for i,v in ipairs(self.blocks) do
        v:draw()
    end
end

function l:drawPowerups()
    --draw all powerups in this lane
    for i,v in ipairs(self.powerups) do
        v:draw()
    end
end

function l:givePlayer(player)
    self.player = player
    --self.collider:addShape(player.cob)
end

function l:update(dt)

    --move all the blocks in this lane
    for i,v in ipairs(self.blocks) do
        v:move(dt)
    end
    
    
    
    --scroll background
    for i,v in ipairs(self.bgBlocks) do
        v.x = v.x -(dt*BLOCK_SPEED*0.5)
        if v.x< (self.w/-3) then
            v.x = self.w/3*4
        end
    end

    --move all the powerups in this lane
    for i,v in ipairs(self.powerups) do
        v:move(dt)
    end
    
    --garbage disposal
    self:removeBlocks()
    self:removePowerups()
    
    --for testing, add a block when there are none
    if #self.blocks==0 and #self.powerups ==0 and self.player.isActive then
        self:spawnBlock()
    end
    
end

function l:spawnBlock()
    --actually spawns a new obstacle which can include blocks and powerups
    local spaces = {}
    for i=1, 3 do
        local space = {x=self.w,y=(i*self.h/4)+self.y}
        table.insert(spaces,space)
    end
    
    local oType = math.random(1,7)
    local pRand = math.random(1,3)
    local cRand = math.random(1,LANES)
    
    local cGap = BLOCK_SPEED
    
    if oType == 1 then
        --two obstacles at top, maybe a powerup
        table.insert(self.blocks,block.new(spaces[1].x,spaces[1].y,cRand,oType))
        table.insert(self.blocks,block.new(spaces[2].x,spaces[2].y,cRand,oType))
        if pRand == 3 then
            table.insert(self.powerups,powerup.new(spaces[3].x,spaces[3].y))
        end
    elseif oType == 2 then
        --one obstacle middle, maybe one powerup
        table.insert(self.blocks,block.new(spaces[2].x,spaces[2].y,cRand,oType))
        if not pRand == 2 then
            table.insert(self.powerups,powerup.new(spaces[pRand].x,spaces[pRand].y))
        end
    elseif oType == 3 then
        --two obstacles at the bottom, maybe a powerup
        table.insert(self.blocks,block.new(spaces[3].x,spaces[3].y,cRand,oType))
        table.insert(self.blocks,block.new(spaces[2].x,spaces[2].y,cRand,oType))
        if pRand == 1 then
            table.insert(self.powerups,powerup.new(spaces[1].x,spaces[1].y))
        end
    elseif oType == 4 then
        --three powerups
        table.insert(self.powerups,powerup.new(spaces[1].x,spaces[1].y))
        table.insert(self.powerups,powerup.new(spaces[2].x,spaces[2].y))
        table.insert(self.powerups,powerup.new(spaces[3].x,spaces[3].y))
    elseif oType == 5 then
        --one random powerup
        
        table.insert(self.powerups,powerup.new(spaces[pRand].x,spaces[pRand].y))
    elseif oType == 6 then
        --two obstacles at the bottom, maybe a powerup
        --followed by the opposite side, same color
        table.insert(self.blocks,block.new(spaces[3].x,spaces[3].y,cRand,3))
        table.insert(self.blocks,block.new(spaces[2].x,spaces[2].y,cRand,3))
        table.insert(self.blocks,block.new(spaces[1].x+cGap,spaces[1].y,cRand,1))
        table.insert(self.blocks,block.new(spaces[2].x+cGap,spaces[2].y,cRand,1))
    elseif oType == 7 then
        --double length obstacle
        table.insert(self.blocks,block.new(spaces[2].x,spaces[2].y,cRand,7))
        table.insert(self.blocks,block.new(spaces[2].x+48,spaces[2].y,cRand,7))
    end

end

function l:removeBlocks(all)
    if all then
        self.blocks={}
    else        
        for i,v in ipairs(self.blocks) do
            if v.isGarbage then
                level.collider:remove(v.cob)
                table.remove(self.blocks,i)
            end
        end
    end
end

function l:spawnPowerup(b)
    local pup = powerup.new(self, b)
    table.insert(self.powerups,pup)
end

function l:removePowerups(all)
    if all then
        self.powerups={}
    else        
        for i,v in ipairs(self.powerups) do
            if v.isGarbage then
                level.collider:remove(v.cob)
                table.remove(self.powerups,i)
            end
        end
    end
end

function l:withinBounds(x,y)
    local oy = self.y
    local my = self.y+laneGFX.h
    if y >= oy and y < my then
        return true
    else
        return false
    end
end




return l

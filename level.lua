local level={}
level.lanes={}
level.players={}
level.effects={}
level.activePlayer = nil
level.collider = HC.new()

function level.reset()
    level.lanes = {}
    level.players = {}
    level.effects = {}
end

function level.buildLanes()
    for i=1,LANES do
        table.insert(level.lanes,lane.new(i))
    end
    
    for i,v in ipairs(level.lanes) do
        table.insert(level.players,player.new(v,i))
        level.selectNewPlayer(math.ceil(LANES/2))
    end
    
end

function level.collide(dt, s1, s2, dx, dy)
    if s1.isCone and not s2.parent.isPlayer then
        s1.parent:look(s2)
    elseif s2.isCone and not s1.parent.isPlayer then
        s2.parent:look(s1)
    else
        local p
        local b
        if s1.parent.isPlayer ==s2.parent.isPlayer then 
            return false
        end
        
        if s1.parent.isPlayer == true then
            p = s1.parent
            b = s2.parent
        else
            p = s2.parent
            b = s1.parent
        end

        if p.isPunching and p.color == b.color then
            sfx.impact:rewind()
            sfx.impact:play()
            if love.system.getOS() == "Android" then
                --no explosions
            else
                local fx = ps.systems.explosion:clone()
                local c = COLORS[p.color]
                fx:setColors(c[1], c[2], c[3], 255, c[1], c[2], c[3], 0)
                fx:setPosition(p.ax, p.ay)
                fx:start()
                table.insert(level.effects, fx)
            end
            b:destroy()
            score:incrementKills()
        else
            if b.isPowerup then
                sfx.powerup:rewind()
                sfx.powerup:play()
                b:destroy()
                score:collectPowerup()
            else
                sfx.explosion:rewind()
                sfx.explosion:play()
                if love.system.getOS() == "Android" then
                    --no explosions
                else
                    local fx = ps.systems.explosion:clone()
                    local c = COLORS[p.color]
                    fx:setColors(c[1], c[2], c[3], 255, c[1], c[2], c[3], 0)
                    fx:setPosition(p.ax, p.ay)
                    fx:start()
                    table.insert(level.effects, fx)
                end

                if p.isControlled then
                    score:decrementLives()
                end

                p:deactivate()
                tc.line = "Collision"
            end
            --p.isColliding = true
            --b.isColliding = true
        end
    
    end
    
    
end

function level.endCollide(dt, s1, s2, dx, dy)
    s1.parent.isColliding = false
    s2.parent.isColliding = false
end




function level.selectNewPlayer(override)
    for i,v in ipairs(level.players) do
        v.isControlled=false
    end
    
    if override and level.players[override] then
        level.activePlayer = level.players[override]
        level.activePlayer.isControlled = true
    else
        local newPlayer = nil
        local deathtime = 99999
        for i,v in ipairs(level.players) do
            if v.isActive then
                newPlayer = v
            end
        end
        
        if not newPlayer then
            for i,v in ipairs(level.players) do
                if v.timers.deactive.val < deathtime then
                   deathtime = v.timers.deactive.val
                   newPlayer = v
                end
            end
        end
        
        level.activePlayer = newPlayer
        newPlayer.isControlled = true
        newPlayer.isActive = false
        newPlayer.timers.deactive.val = 2
        newPlayer.lane:clearLane()
    end
end

return level

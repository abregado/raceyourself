local ps = {}

function ps.load()

    local expPart = love.graphics.newImage("assets/particles/explosion_particle.png");

    ps.systems = {}
    ps.systems.explosion = love.graphics.newParticleSystem(expPart, 20)
    ps.systems.explosion = love.graphics.newParticleSystem(expPart, 674)
    ps.systems.explosion:setEmissionRate(674)
    ps.systems.explosion:setSpeed(242/2, 244/2)
    ps.systems.explosion:setLinearAcceleration(0, 1, 0, 1)
    ps.systems.explosion:setSizes(34/100, 14/100)
    ps.systems.explosion:setSizeVariation(1)
    ps.systems.explosion:setColors(255, 255, 255, 255, 255, 255, 255, 0)
    ps.systems.explosion:setEmitterLifetime(0.1)
    ps.systems.explosion:setParticleLifetime(0.75)
    ps.systems.explosion:setRadialAcceleration(0, 0)
    ps.systems.explosion:setDirection(0)
    ps.systems.explosion:setRelativeRotation(true)
    ps.systems.explosion:setSpread(6.28318)
    ps.systems.explosion:stop()

end

return ps

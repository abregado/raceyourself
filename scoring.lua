local s = {}

function s.new()
    o = {}

    o.powerups = 0

    s.setupMethods(o)

    return o    
end

function s.setupMethods(o)
    o.collectPowerup = s.collectPowerup
end

function s:collectPowerup()
    self.powerups = self.powerups + 1
    tc.line = "Powerups: " .. self.powerups
end

return s

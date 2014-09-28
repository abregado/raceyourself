local s = {}

function s.new()
    o = {}

    s.setupMethods(o)

    o:reset()

    return o    
end

function s.setupMethods(o)
    o.draw = s.draw
    o.reset = s.reset
    o.collectPowerup = s.collectPowerup
    o.incrementKills = s.incrementKills
    o.decrementLives = s.decrementLives
    o.isGameOver = s.isGameOver
end

function s:draw()
    lg.setColor(COLORS[#COLORS])
    lg.setFont(self.font)
    
    lg.line(self.microX, self.minY, self.microX, self.maxY, self.maxX, self.maxY, self.maxX, self.minY, self.microX, self.minY)
    lg.line(self.microX, self.midY, self.maxX, self.midY)
    lg.line(self.midX, self.minY, self.midX, self.maxY)
    lg.line(self.minX, self.minY, self.minX, self.maxY)

    local lW = self.font:getWidth(self.lives)
    local pW = self.font:getWidth(self.powerups)
    local kW = self.font:getWidth(self.kills)

    lg.print(self.lLine, self.microX + self.lWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.lives, self.microX + (self.lWidth * 1.2 - lW) / 2, self.maxY - self.fontHeight * 1.2)
    lg.print(self.pLine, self.minX + self.pWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.powerups, self.minX + (self.pWidth * 1.2 - pW) / 2, self.maxY - self.fontHeight * 1.2)
    lg.print(self.kLine, self.midX + self.kWidth * 0.1, self.minY + self.fontHeight * 0.2)
    lg.print(self.kills, self.midX + (self.kWidth * 1.2 - kW) / 2, self.maxY - self.fontHeight * 1.2)

    if self.gameOver then
        local msg = "GAME OVER"
        local f = lg.newFont(100)
        local fh = f:getHeight()
        local fw = f:getWidth(msg)
        lg.setFont(f)
        lg.print(msg, (lw.getWidth() - fw) / 2, (lw.getHeight() - fh) / 2)
    end
end

function s:reset()
    self.powerups = 0
    self.kills = 0
    self.gameOver = false
    self.lives = START_LIVES
    self.lLine = "SPACELIVES"
    self.pLine = "SPACECOINS"
    self.kLine = "SPACEKILLS"
    self.font = lg.newFont()
    self.lWidth = self.font:getWidth(self.lLine)
    self.pWidth = self.font:getWidth(self.pLine)
    self.kWidth = self.font:getWidth(self.kLine)
    self.fontHeight = self.font:getHeight()

    self.maxX = lw.getWidth() - edgeBuffer
    self.midX = self.maxX - self.kWidth * 1.2
    self.minX = self.midX - self.pWidth * 1.2
    self.microX = self.minX - self.lWidth * 1.2
    self.minY = edgeBuffer
    self.midY = self.minY + self.fontHeight * 1.4
    self.maxY = self.midY + self.fontHeight * 1.4
end

function s:collectPowerup()
    self.powerups = self.powerups + 1
end

function s:incrementKills()
    self.kills = self.kills + 1
end

function s:decrementLives()
    self.lives = self.lives - 1
    if self.lives == 0 then
        self.gameOver = true
    end
end

function s:isGameOver()
    return self.gameOver
end

return s

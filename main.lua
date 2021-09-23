function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180

    myFont = love.graphics.newFont(30)

    zombies = {}
    bullets = {}

    gameState = 1
    score = 0
    maxTime = 2
    timer = maxTime
end
-- dt updats every frame to be the amount of time in second between
-- the previous frame and the current one. If the game is running
-- at 60 frames per second, then dt will equal 1/60.
function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt -- when dt droped, the speed increase, but it 'looks' in same speed
        end
        if love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player.y + player.speed * dt
        end
    end
    -- zombie movement and it's nil
    for i,z in ipairs(zombies) do
        z.x = z.x + math.cos(zombiePlayerAngle(z)) * z.speed * dt -- 對radian做cos可以得到x
        z.y = z.y + math.sin(zombiePlayerAngle(z)) * z.speed * dt
        
        -- game over
        if distance(z.x,z.y,player.x,player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil 
            end
            player.x = love.graphics.getWidth() / 2
            player.y = love.graphics.getHeight() / 2
            gameState = 1
        end
    end

    -- bullet movement
    for i,b in ipairs(bullets) do 
        b.x = b.x + math.cos(b.direction) * b.speed * dt -- b.direction不能用playerMouseAngle()因為update是所以會一直更新方向
        b.y = b.y + math.sin(b.direction) * b.speed * dt
    end
    -- delete sprites
    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end
    -- collision zombie and bullet
    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distance(z.x,z.y,b.x,b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end
    -- delete zombie
    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies,i)
        end
    end
    -- delete bullet
    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets,i)
        end
    end
    -- spawn zombie base on timer
    if gameState == 2 then
        timer = timer - dt
        if timer <=0 then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background,0,0)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!",0,50,love.graphics.getWidth(),"center")
        love.graphics.printf("WASD to move, LEFT click to shoot!",0,100,love.graphics.getWidth(),"center")

    end
    love.graphics.printf("Score: "..score,0,love.graphics.getHeight()-100, love.graphics.getWidth(),"center")


    love.graphics.draw(sprites.player,player.x,player.y, playerMouseAngle(), nil,nil, sprites.player:getWidth()/2,sprites.player:getHeight()/2)

    -- zombie shawn and it's radian
    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y,zombiePlayerAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)
    end

    --bullet spawn
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil,0.5,nil,sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
end

function love.keypressed(key)
    if key=="space" then
        spawnZombie()
    end
end

function love.mousepressed(x,y,button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    -- game start
    elseif button == 1 and gameState == 1 then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function playerMouseAngle()
    return math.atan2(player.y-love.mouse.getY(), player.x-love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y-enemy.y, player.x-enemy.x)
end 
-- spawn zombie
function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 100
    zombie.dead = false
    -- make zombie come from one of four sides
    local side = math.random(1,4)
    if side==1 then
        zombie.x = -30
        zombie.y = math.random(0,love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0,love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0,love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0,love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end
-- spawn bullet
function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 600
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function distance(x1,y1,x2,y2)
    return math.sqrt((x1-x2)^2+(y1-y2)^2)
end
game_over_art = {
    ['PLAYER'] = love.graphics.newImage('/images/winner.png'),
    ['DEALER'] = love.graphics.newImage('/images/loser.png')
}

-- set card art
card_art = {
    [0] = love.graphics.newImage('/images/card_back.png'),
    [2] = love.graphics.newImage('/images/card_2.png'),
    [3] = love.graphics.newImage('/images/card_4.png'),
    [4] = love.graphics.newImage('/images/card_5.png'),
    [5] = love.graphics.newImage('/images/card_6.png'),
    [6] = love.graphics.newImage('/images/card_7.png'),
    [7] = love.graphics.newImage('/images/card_jack.png'),
    [8] = love.graphics.newImage('/images/card_queen.png'), 
    [9] = love.graphics.newImage('/images/card_king.png'),
    [10] = love.graphics.newImage('/images/card_3.png'),
    [11] = love.graphics.newImage('/images/card_ace.png')
}
card_width = card_art[0]:getWidth()

suit_colors = {
    club = {
        r = 0,
        g = 1,
        b = 0
    },
    sword = {
        r = 0,
        g = 1,
        b = 1
    },
    coin = {
        r = 1,
        g = 1,
        b = 0
    },
    cup = {
        r = 1,
        g = 0,
        b = 0
    }
}

scores = {
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 2,
    [8] = 3, 
    [9] = 4,
    [10] = 10,
    [11] = 11
}
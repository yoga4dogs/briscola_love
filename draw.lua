function love.draw()
    -- text display
    love.graphics.setColor(1,1,1)
    -- trump card
    love.graphics.print('<TRUMP> suit: '..trump.suit, 400, 16)
    -- player hand
    local player_output = {}
    table.insert(player_output, 'Player hand:')
    for cardIndex, card in ipairs(player.hand) do
        table.insert(player_output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    love.graphics.print(table.concat(player_output, '\n'), 16, 16)
    -- dealer hand
    local dealer_output = {}
    table.insert(dealer_output, 'Dealer hand:')
    for cardIndex, card in ipairs(dealer.hand) do
        table.insert(dealer_output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    love.graphics.print(table.concat(dealer_output, '\n'), 240, 16)
    -- played card
    if player.card_played then
        love.graphics.print('<PLAYER> suit: '..player.played_card.suit..', rank: '..player.played_card.rank, 400, 48)
    end
    if dealer.card_played then    
        love.graphics.print('<DEALER> suit: '..dealer.played_card.suit..', rank: '..dealer.played_card.rank, 400, 64)
    end
    -- hand winner
    if player.hand_score > dealer.hand_score then
        love.graphics.print('<PLAYER> wins hand.', 400, 96)
    elseif player.hand_score < dealer.hand_score then
        love.graphics.print('<DEALER> wins hand.', 400, 96)
    end
    if round.winner then
        love.graphics.print('<P>: '..player.round_score..' <D>: '..dealer.round_score, 400, 112)
        love.graphics.print('<'..round.winner..'> wins round!', 400, 128)
    end
    -- game score
    love.graphics.print('<P> '..player.game_score, 640, 16)
    love.graphics.print('<D> '..dealer.game_score, 640, 32)
    
    -- card graphics
    -- deck
    if #deck > 0 then
        local card = trump.card
        love.graphics.draw(card_art[0], trump.card.display.posX+32+card_width, trump.card.display.posY, 0, 1, 1, card_width/2, card_width)
    end
    -- set suit colors
    -- trump card
    if trump.card then
        local card = trump.card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.posX, card.display.posY, card.display.rot, 1, 1, card.display.offsetX, card.display.offsetY)
    end
    -- played cards
    if player.card_played then
        local card = player.played_card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.posX, card.display.posY, card.display.rot, 1, 1, card.display.offsetX, card.display.offsetY)
    end
    if dealer.card_played then
        local card = dealer.played_card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.posX, card.display.posY, card.display.rot, 1, 1, card.display.offsetX, card.display.offsetY)
    end
    -- player hand
    for cardIndex, card in ipairs(player.hand) do
        local hover_scale = 1
        if card.display.hover == true then
            hover_scale = 1.1
        end
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.posX+((cardIndex-1)*card_width), card.display.posY, card.display.rot, hover_scale, hover_scale, card.display.offsetX, card.display.offsetY)
    end
    
    -- game over
    if game_winner then
        local width, height = love.graphics.getDimensions( )
        love.graphics.setColor(1,1,1)
        love.graphics.draw(game_over_art[game_winner], width/2, height/2, 0, 2, 2, 256, 128)
    end
end
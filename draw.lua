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
    
-- graphics display
    -- deck
    if #deck.active > 0 then
        local card = trump.card
        love.graphics.draw(card_art[0], deck.anchor.x, deck.anchor.y, 0, 1, 1)
    end
    -- set suit colors
    -- trump card
    if trump.card then
        local card = trump.card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.x, card.display.y, card.display.rot)
    end
    -- player hand
    for cardIndex, card in ipairs(player.hand) do
        local hover_scale = 1
        if card.display.hover == true then
            hover_scale = 1.1
        end
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.x+((cardIndex-1)*card_width), card.display.y, card.display.rot, hover_scale, hover_scale)
    end
    -- played cards
    if player.card_played then
        local card = player.played_card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.x, card.display.y, card.display.rot)
    end
    if dealer.card_played then
        local card = dealer.played_card
        love.graphics.setColor(suit_colors[card.suit].r, suit_colors[card.suit].g, suit_colors[card.suit].b)
        love.graphics.draw(card_art[card.rank], card.display.x, card.display.y, card.display.rot)
    end
    
    -- game over
    if game_winner then
        local width, height = love.graphics.getDimensions( )
        love.graphics.setColor(1,1,1)
        love.graphics.draw(game_over_art[game_winner], width/2, height/2, 0, 2, 2, 256, 128)
    end

-- test graphics
    love.graphics.setColor(1,1,1)
    love.graphics.draw(test_man.sprite, test_man.x, test_man.y, 0, test_man.facing, 1, test_man.width/2, test_man.width/2)

end
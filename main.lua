function love.load()
    cardback = love.graphics.newImage('/images/cardback.png')
    card_art = {
        [11] = love.graphics.newImage('/images/temp_card.png'),
        [2] = love.graphics.newImage('/images/temp_card.png'),
        [3] = love.graphics.newImage('/images/temp_card.png'),
        [4] = love.graphics.newImage('/images/temp_card.png'),
        [5] = love.graphics.newImage('/images/temp_card.png'),
        [6] = love.graphics.newImage('/images/temp_card.png'),
        [7] = love.graphics.newImage('/images/temp_card.png'),
        [8] = love.graphics.newImage('/images/temp_card.png'),
        [9] = love.graphics.newImage('/images/temp_card.png'), 
        [10] = love.graphics.newImage('/images/temp_card.png')
    }
    card_width = cardback:getWidth()
    
    -- Tileset = love.graphics.newImage('/images/catscups.png')
    -- local tileW, tileH = 128, 256
    -- local tilesetW, tilesetH = Tileset:getWidth(), Tileset:getHeight()
    -- kingQuad = love.graphics.newQuad(0, 0, tileW, tileH, tilesetW, tilesetH)
    -- queenQuad = love.graphics.newQuad(tileW, 0, tileW, tileH, tilesetW, tilesetH)

    -- init hands and deck
    scores = {
        [11] = 11,
        [2] = 0,
        [3] = 10,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 2,
        [9] = 3, 
        [10] = 4
    }
    new_game()
end

-- check if val in array
function contains(list, x)
	for _, v in ipairs(list) do
		if v == x then return true end
	end
	return false
end

function new_game()
    wait_timer = 0
    
    trump = { hand = {}, card = {} }
    
    player = { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, scored_cards = {} }
    dealer = { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, scored_cards = {} }

    scoring = {}
    round = {
        ended = false,
        winner = ''
    } 
    
    if love.math.random(2) > 1 then
        active_player = player
    else
        active_player = dealer
    end

    init_deck()

    for i = 1, 7 do
        draw_card(dealer)
        draw_card(player)
    end

    draw_card(trump)
    trump.card =  trump.hand[1]
end

function init_deck()
    full_deck = {}
    for suitIndex, suit in ipairs({'club', 'sword', 'coin', 'cup'}) do
        for rank = 2, 11 do
            local temp_card = {
                suit = suit,
                rank = rank,
                display = {
                    hover = false,
                    posX = 0,
                    posY = 0,
                    offsetX = card_width / 2,
                    offsetY = card_width,
                    rot = love.math.random()/10.0-.05
                }
            }
            table.insert(full_deck, temp_card)
        end
    end
    replenish_deck()
end
function replenish_deck()
    deck = full_deck
end

function draw_card(target)
    local temp_card = table.remove(deck, love.math.random(#deck))
    if target == player then
        temp_card.display.posX = (15+card_width/2)+(#target.hand*card_width)
        temp_card.display.posY = 400
    end
    table.insert(target.hand, temp_card)
end

function play_card(target, card_index)
    if player.card_played == false and dealer.card_played == false then
        scoring = target
    end
    target.card_played = true
    target.played_card = table.remove(target.hand, card_index) 
end

function love.keypressed(key)
    -- draw card
    if key == 'd' and #player.hand < 7 then
        player.card_played = false
        draw_card(player.hand)
    -- new game
    elseif key == 'n' then
        new_game()
    -- play card
    elseif tonumber(key) then
        if active_player == player and wait_timer <= 0 and tonumber(key) > 0 and tonumber(key) <= #player.hand then
            play_card(player, tonumber(key))
            active_player = dealer
        end
    end
end

function love.mousemoved(x, y)
    for cardIndex, card in ipairs(player.hand) do
        if x > card.display.posX - card.display.offsetX and x < card.display.posX+card_width - card.display.offsetX and y > card.display.posY - card.display.offsetY and y < card.display.posY+card_width*2 - card.display.offsetY then
            card.display.hover = true
        else 
            card.display.hover = false
        end 
    end
end

function dealer_turn()
    play_card(dealer, love.math.random(#dealer.hand))
    active_player = player
end

function calc_hand_score(target1, target2)
    if target1.played_card.suit == trump.card.suit then
        target1.hand_score = target1.played_card.rank + 100
    else
        target1.hand_score = target1.played_card.rank
    end
    if target2.played_card.suit == trump.card.suit then
        target2.hand_score = target2.played_card.rank + 100
    elseif target2.played_card.suit == target1.played_card.suit then
        target2.hand_score = target2.played_card.rank
    end
end

function score_hand()
    if scoring == player then
        calc_hand_score(player, dealer)
    else
        calc_hand_score(dealer, player)
    end

    if player.hand_score > dealer.hand_score then
        table.insert(player.scored_cards, player.played_card)
        active_player = player
    else
        table.insert(dealer.scored_cards, player.played_card.suit)
        active_player = dealer
    end
    wait_timer = 1.5
end

function score_round()
    if #player.scored_cards > 0 then
        for cardIndex, card in ipairs(player.scored_cards) do
            if scores[card.rank] then
                player.round_score = player.round_score + scores[card.rank]
            end
        end
    end
    if #dealer.scored_cards > 0 then
        for cardIndex, card in ipairs(dealer.scored_cards) do
            if scores[card.rank] then
                dealer.round_score = dealer.round_score + scores[card.rank]
            end
        end
    end
    if player.round_score > dealer.round_score then
        round.winner = 'PLAYER'
    else
        round.winnder = 'DEALER'
    end
    round.ended = true
end

function reset_played_cards()
    player.card_played = false
    player.played_card = {}
    player.hand_score = 0
    dealer.card_played = false
    dealer.played_card = {}
    dealer.hand_score = 0
end

function love.update(dt)
    if wait_timer > 0 then 
        wait_timer = wait_timer - 1*dt 
        if wait_timer <= 0 and (#player.hand > 0 or #dealer.hand > 0) then
            reset_played_cards()
        end
    elseif #player.hand == 0 and #dealer.hand == 0 and (player.round_score == 0 and dealer.round_score == 0) then
        score_round()
    elseif player.card_played and dealer.card_played then
        score_hand()
    elseif active_player == dealer then
        dealer_turn()
    end
    

end

function love.draw()

    -- trump card
    love.graphics.print('<TRUMP> suit: '..trump.card.suit..', rank: '..trump.card.rank, 400, 15)
    
    -- player hand
    local player_output = {}
    table.insert(player_output, 'Player hand:')
    for cardIndex, card in ipairs(player.hand) do
        table.insert(player_output, cardIndex..'> suit: '..card.suit..', rank: '..card.rank)
    end
    love.graphics.print(table.concat(player_output, '\n'), 15, 15)

    -- dealer hand
    local dealer_output = {}
    table.insert(dealer_output, 'Dealer hand:')
    for cardIndex, card in ipairs(dealer.hand) do
        table.insert(dealer_output, 'suit: '..card.suit..', rank: '..card.rank)
    end
    love.graphics.print(table.concat(dealer_output, '\n'), 200, 15)

    -- played card
    if player.card_played then
        love.graphics.print('<PLAYER> suit: '..player.played_card.suit..', rank: '..player.played_card.rank, 400, 50)
    end
    if dealer.card_played then    
        love.graphics.print('<DEALER> suit: '..dealer.played_card.suit..', rank: '..dealer.played_card.rank, 400, 70)
    end
    if player.hand_score > dealer.hand_score then
        love.graphics.print('<PLAYER> wins hand.', 400, 90)
    elseif player.hand_score < dealer.hand_score then
        love.graphics.print('<DEALER> wins hand.', 400, 90)
    end
    if round.ended then
        love.graphics.print('<P>: '..player.round_score..' <D>: '..dealer.round_score, 400, 110)
        love.graphics.print('<'..round.winner..'> wins round!', 400, 130)
    end
    
    for cardIndex, card in ipairs(player.hand) do
        if card.display.hover == true then
            love.graphics.draw(card_art[card.rank], card.display.posX, card.display.posY, card.display.rot, 1, 1, card.display.offsetX, card.display.offsetY)
            print("HOVER"..card.rank.." "..card.suit)
        else
            love.graphics.draw(cardback, card.display.posX, card.display.posY, card.display.rot, 1, 1, card.display.offsetX, card.display.offsetY)
            print("NO")
        end
    end

end
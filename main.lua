function love.load()
    -- background color
    love.graphics.setBackgroundColor( 0.153, 0.467, 0.078 )

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

    -- init hands and deck
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
    init_game()
end

-- check if val in array
function contains(list, x)
	for _, v in ipairs(list) do
		if v == x then return true end
	end
	return false
end

function init_game()
    player = { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, game_score = 0, scored_cards = {} }
    dealer = { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, game_score = 0, scored_cards = {} }

    game_winner = ''
    
    if love.math.random(2) > 1 then
        active_player = player
    else
        active_player = dealer
    end
    
    new_round()
end

function new_round()
    wait_timer = 0

    trump = { hand = {}, card = {}, suit = '' }

    scoring = {}
    round = {
        ended = false,
        winner = '',
        wait_timer = 0
    } 
    player.round_score = 0
    player.scored_cards = {}
    dealer.round_score = 0
    dealer.scored_cards = {}

    init_deck()

    for i = 1, 3 do
        draw_card(dealer)
        draw_card(player)
    end

    draw_card(trump)
    trump.card =  trump.hand[1]
    trump.suit = trump.card.suit
    local posX = 680
    local posY = 300
    trump.card.display.posX = posX
    trump.card.display.posY = posY
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
    if #deck == 0 and trump.card then
        table.insert(deck, trump.card)
        trump.card = nil
    end 
    if (#deck > 0) then
        local temp_card = table.remove(deck, love.math.random(#deck))
        if target == player then
            temp_card.display.posX = temp_card.display.offsetX + 320
            temp_card.display.posY = 600
        end
        table.insert(target.hand, temp_card)
    end
end

function play_card(target, card_index)
    local posX = 220
    local posY = 300
    local temp_card = table.remove(target.hand, card_index)
    if target == player then
        temp_card.display.posX = posX
        temp_card.display.posY = posY
    else
        temp_card.display.posX = posX + card_width + 20
        temp_card.display.posY = posY
    end
    target.played_card = temp_card
    if player.card_played == false and dealer.card_played == false then
        scoring = target
    end
    target.card_played = true
    -- draw_card(target)
end

function play_card_mouse(x, y, target)
    for cardIndex, card in ipairs(target.hand) do
        if check_mouse_select(x, y, card, cardIndex) and target.card_played ~= true then
            play_card(target, cardIndex)
            active_player = dealer
            break
        end 
    end
end

function check_mouse_select(x, y, card, cardIndex)
    if x > card.display.posX - card.display.offsetX+((cardIndex-1)*card_width)+15 and x < card.display.posX+card_width - card.display.offsetX+((cardIndex-1)*card_width)+15 and y > card.display.posY - card.display.offsetY and y < card.display.posY+card_width*2 - card.display.offsetY then
        return true
    end 
end

function love.keypressed(key)
    -- new game
    if key == 'n' then
        init_game()
    end
end

function love.mousepressed(x, y)
    if active_player == player then
        play_card_mouse(x, y, player)
    end
end

function love.mousemoved(x, y)
    -- flip cards hover
    for cardIndex, card in ipairs(player.hand) do
        if check_mouse_select(x, y, card, cardIndex) then
            card.display.hover = true
        else 
            card.display.hover = false
        end 
    end
end

function dealer_turn()
    local temp_card = { 
        card = { rank = 0 },
        index = 0
    }
    -- dealer plays second to player
    if player.card_played then
        local temp_index = 0
        -- try to match suit off trump 
        for cardIndex, card in ipairs(dealer.hand) do
            -- match suit and beat rank
            if card.suit == player.played_card.suit and card.rank >= player.played_card.rank then
                if temp_card.card.rank == 0 then
                    temp_card.card = card
                    temp_card.index = cardIndex
                -- select lowest rank card that beats player
                elseif card.rank < temp_card.card.rank then
                    temp_card.card = card
                    temp_card.index = cardIndex
                end
            end
        end
        -- second pass for trump cards
        if temp_card.card.rank <= 0 then
            for cardIndex, card in ipairs(dealer.hand) do
                if card.suit == trump.suit then
                    -- player doesnt have trump
                    if card.suit ~= player.played_card.suit then
                        if temp_card.card.rank == 0 then
                            temp_card.card = card
                            temp_card.index = cardIndex
                        -- select lowest rank card
                        elseif card.rank < temp_card.card.rank then
                            temp_card.card = card
                            temp_card.index = cardIndex
                        end
                    else
                    -- player has trump
                        if card.rank >= player.played_card.rank then
                            if card.rank > temp_card.card.rank then
                                temp_card.card = card
                                temp_card.index = cardIndex
                            end
                        end
                    end
                end
            end
        end
        -- dealer doesnt have anything that beats
        if temp_card.card.rank <= 0 then
            for cardIndex, card in ipairs(dealer.hand) do
                if temp_card.card.rank == 0 then
                    temp_card.card = card
                    temp_card.index = cardIndex
                -- select lowest rank card
                elseif card.rank < temp_card.card.rank then
                    temp_card.card = card
                    temp_card.index = cardIndex
                end
            end
        end
    else
    -- dealer play first, just throwing highest rank card
        for cardIndex, card in ipairs(dealer.hand) do
            if card.rank > temp_card.card.rank then
                temp_card.card = card
                temp_card.index = cardIndex
            end
        end
    end
    play_card(dealer, temp_card.index)
    active_player = player
end

function score_hand()
    if scoring == player then
        calc_hand_score(player, dealer)
    else
        calc_hand_score(dealer, player)
    end
    
    if player.hand_score > dealer.hand_score then
        table.insert(player.scored_cards, player.played_card)
        table.insert(player.scored_cards, dealer.played_card)
        active_player = player
        draw_card(player)
        draw_card(dealer)
    else
        table.insert(dealer.scored_cards, player.played_card)
        table.insert(dealer.scored_cards, dealer.played_card)
        active_player = dealer
        draw_card(dealer)
        draw_card(player)
    end
    wait_timer = 1
end

function calc_hand_score(target1, target2)
    if target1.played_card.suit == trump.suit then
        target1.hand_score = target1.played_card.rank + 100
    else
        target1.hand_score = target1.played_card.rank
    end
    if target2.played_card.suit == trump.suit then
        target2.hand_score = target2.played_card.rank + 100
    elseif target2.played_card.suit == target1.played_card.suit then
        target2.hand_score = target2.played_card.rank
    else
        target2.hand_score = 0
    end
end

function score_round()
    print(#player.scored_cards..' '..#dealer.scored_cards)
    if #player.scored_cards > 0 then
        print('PLAYER')
        for cardIndex, card in ipairs(player.scored_cards) do
            print(card.suit..' '..card.rank)
            if scores[card.rank] then
                print(card.suit..' '..card.rank..' - '.. scores[card.rank])
                player.round_score = player.round_score + scores[card.rank]
            end
        end
        print('score: '..player.round_score)
    end
    if #dealer.scored_cards > 0 then
        print('DEALER')
        for cardIndex, card in ipairs(dealer.scored_cards) do
            print(card.suit..' '..card.rank)
            if scores[card.rank] then
                print(card.suit..' '..card.rank..' - '.. scores[card.rank])
                dealer.round_score = dealer.round_score + scores[card.rank]
            end
        end
        print('score: '..dealer.round_score)
    end
    if player.round_score > dealer.round_score then
        round.winner = 'PLAYER'
        player.game_score = player.game_score + 1
    else
        dealer.game_score = dealer.game_score + 1
        round.winner = 'DEALER'
    end
    print(player.game_score..'/'..dealer.game_score)
    round.ended = true
    round.wait_timer = 3
end

function reset_played_cards()
    player.card_played = false
    player.played_card = {}
    player.hand_score = 0
    player.round_score = 0
    dealer.card_played = false
    dealer.played_card = {}
    dealer.hand_score = 0
    dealer.round_score = 0
end

function game_over(winner)
    print('GAME OVER - <'..winner..'> wins!')
end

function love.update(dt)
    if player.game_score >= 3 then
        game_winner = 'PLAYER'
    elseif dealer.game_score >= 3 then
        game_winner = 'DEALER'
    end
    if wait_timer > 0 then 
        wait_timer = wait_timer - 1*dt 
        if wait_timer <= 0 and (#player.hand > 0 or #dealer.hand > 0) then
            reset_played_cards()
        elseif round.wait_timer > 0 then 
            round.wait_timer = round.wait_timer - 1*dt
            if round.wait_timer <= 0 and round.ended then 
                reset_played_cards()
                new_round()
            end
        end
    elseif #player.hand == 0 and #dealer.hand == 0 and (player.round_score == 0 and dealer.round_score == 0) then
        score_hand()
        score_round()
    elseif player.card_played and dealer.card_played then
        score_hand()
    elseif active_player == dealer then
        dealer_turn()
    end
end

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
    love.graphics.print(table.concat(dealer_output, '\n'), 240, 15)
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
    if round.ended then
        love.graphics.print('<P>: '..player.round_score..' <D>: '..dealer.round_score, 400, 112)
        love.graphics.print('<'..round.winner..'> wins round!', 400, 128)
    end
    
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
    if #game_winner > 0 then
        local width, height = love.graphics.getDimensions( )
        love.graphics.setColor(1,1,1)
        love.graphics.draw(game_over_art[game_winner], width/2, height/2, 0, 2, 2, 256, 128)
    end
end
function love.load()
    -- background color
    love.graphics.setBackgroundColor( 0.153, 0.467, 0.078 )

    -- card art, scores, ranks, etc
    require('card_data')

    -- key and mouse controls
    require('controls')
    
    -- love.draw()
    require('draw')

    init_game()
end

-- check if val in array
function contains(list, x)
	for _, v in ipairs(list) do
		if v == x then return true end
	end
	return false
end

function new_player()
    return { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, game_score = 0, scored_cards = {} }
end

function init_game()
    player = new_player()
    dealer = new_player()

    if love.math.random(2) > 1 then
        active_player = player
    else
        active_player = dealer
    end
    
    game_winner = nil
    new_round()
end

function new_round()
    hand_wait_timer = 0
    scoring = {}

    round = {
        winner = nil,
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
    
    trump = { hand = {}, card = {}, suit = '' }
    draw_card(trump)
    -- .hand is jsut some hacky bs to get draw_card working with trump
    trump.card =  trump.hand[1]
    trump.suit = trump.card.suit
    trump.card.display.posX = 680
    trump.card.display.posY = 300
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
    -- dealer plays first, just throwing highest rank card
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
    hand_wait_timer = 1
end

function score_round()
    -- score player cards
    if #player.scored_cards > 0 then
        for cardIndex, card in ipairs(player.scored_cards) do
            if scores[card.rank] then
                player.round_score = player.round_score + scores[card.rank]
            end
        end
    end
    -- score dealer cards
    if #dealer.scored_cards > 0 then
        for cardIndex, card in ipairs(dealer.scored_cards) do
            if scores[card.rank] then
                dealer.round_score = dealer.round_score + scores[card.rank]
            end
        end
    end
    -- assign winner
    if player.round_score > dealer.round_score then
        round.winner = 'PLAYER'
        player.game_score = player.game_score + 1
    else
        dealer.game_score = dealer.game_score + 1
        round.winner = 'DEALER'
    end
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

function love.update(dt)
    -- game end
    if player.game_score >= 3 then
        game_winner = 'PLAYER'
    elseif dealer.game_score >= 3 then
        game_winner = 'DEALER'
    else
        -- hand score timer
        if hand_wait_timer > 0 then 
            hand_wait_timer = hand_wait_timer - 1*dt 
            if hand_wait_timer <= 0 and (#player.hand > 0 or #dealer.hand > 0) then
                reset_played_cards()
            elseif round.wait_timer > 0 then 
                round.wait_timer = round.wait_timer - 1*dt
                if round.wait_timer <= 0 and round.winner then 
                    reset_played_cards()
                    new_round()
                end
            end
        -- round end
        elseif #player.hand == 0 and #dealer.hand == 0 and (player.round_score == 0 and dealer.round_score == 0) then
            score_hand()
            score_round()
        -- hand end
        elseif player.card_played and dealer.card_played then
            score_hand()
        -- dealer turn
        elseif active_player == dealer then
            dealer_turn()
        end
    end
end
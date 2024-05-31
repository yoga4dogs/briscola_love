function love.load()
    -- background color
    love.graphics.setBackgroundColor( 0.153, 0.467, 0.078 )

    -- card art, scores, ranks, etc
    require('card_data')
    -- key and mouse controls
    require('controls')
    -- love.draw()
    require('draw')
    -- anim and events()
    require('events')
    -- dealer instructions
    require('dealer_logic')

    playX = 220
    playY = 100

    test_man = {
        sprite = love.graphics.newImage('/images/dogman.png'),
        width = 0,
        x = 0,
        y = 0,
        target = {
            x = 0, y = 0
        },
        facing = 1,
        speed = 250
    }
    test_man.width = test_man.sprite:getWidth()

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
    return { hand = {}, played_card = {}, card_played = false, hand_score = 0, round_score = 0, game_score = 0, scored_cards = {}, anchor = {x = 0, y = 0} }
end

function init_game()
    player = new_player()
    player.anchor.x = card_width / 2 + 256
    player.anchor.y = card_width + 350
    dealer = new_player()
    dealer.anchor.x = card_width / 2 + 256
    dealer.anchor.y = -card_width*2

    if love.math.random(2) > 1 then
        active_player = player
    else
        active_player = dealer
    end
    
    game_winner = nil
    new_round()
end

function new_round()
    hand = {
        scoring_player = {},
        wait_timer = 0
    }
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
    
    trump = { hand = {}, card = {}, suit = '', anchor = {x = deck.anchor.x - 32 - card_width, y = deck.anchor.y - 8} }
    draw_card(trump)
    -- .hand is jsut some hacky bs to get draw_card working with trump
    trump.card =  trump.hand[1]
    trump.suit = trump.card.suit
end

function init_deck()
    deck = {
        full_deck = {},
        active = {},
        anchor = { x = 768, y = 128 }
    }
    for suitIndex, suit in ipairs({'club', 'sword', 'coin', 'cup'}) do
        for rank = 2, 11 do
            local temp_card = {
                suit = suit,
                rank = rank,
                display = {
                    hover = false,
                    x = deck.anchor.x,
                    y = deck.anchor.y,
                    rot = love.math.random()/10.0-.05
                }
            }
            table.insert(deck.full_deck, temp_card)
        end
    end
    replenish_deck()
end
function replenish_deck()
    deck.active = deck.full_deck
end

function draw_card(target)
    if #deck.active == 0 and trump.card then
        table.insert(deck, trump.card)
        trump.card = nil
    end 
    if (#deck.active > 0) then
        local temp_card = table.remove(deck.active, love.math.random(#deck.active))
        temp_card.display.x = deck.anchor.x
        temp_card.display.y = deck.anchor.y
        
        table.insert(target.hand, temp_card)

        local hand_pos = {}
        hand_pos.x = target.anchor.x
        hand_pos.y = target.anchor.y
        if target ~= dealer then
            create_slide_event(temp_card.display, hand_pos, action)
        else
            temp_card.display.x = target.anchor.x
            temp_card.display.y = target.anchor.y
        end
    end
end

function play_card(target, card_index, next_player)
    target.played_card = table.remove(target.hand, card_index)
    
    local play_pos = {}
    play_pos.y = deck.anchor.y
    if target == player then
        target.played_card.display.x = target.anchor.x + (card_index-1)*card_width
        play_pos.x = deck.anchor.x - 512
    else
        play_pos.x = deck.anchor.x - 512 + card_width + 20
    end
    
    if player.card_played == false and dealer.card_played == false then
        hand.scoring_player = target
    end
    target.card_played = true 
    create_slide_event(target.played_card.display, play_pos, action)
    active_player = next_player
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
    if hand.scoring_player == player then
        print("player")
    else
        print("dealer")
    end
    if hand.scoring_player == player then
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
    hand.wait_timer = 2
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
    round.wait_timer = 4
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
    slide_handler(dt)

    -- game end
    if player.game_score >= 3 then
        game_winner = 'PLAYER'
    elseif dealer.game_score >= 3 then
        game_winner = 'DEALER'
    else
        -- hand end, new hand/round timer expired
        if hand.wait_timer > 0 then 
            hand.wait_timer = hand.wait_timer - 1*dt 
            if hand.wait_timer <= 0 and (#player.hand > 0 or #dealer.hand > 0) then
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
        elseif active_player == dealer and not dealer.card_played then
            dealer_turn()
        end
    end
end
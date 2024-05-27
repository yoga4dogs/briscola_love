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
    if x > card.display.posX - card.display.offsetX+((cardIndex-1)*card_width)+16 
        and x < card.display.posX+card_width - card.display.offsetX+((cardIndex-1)*card_width)+16 
        and y > card.display.posY - card.display.offsetY 
        and y < card.display.posY+card_width*2 - card.display.offsetY then
        return true
    end 
end
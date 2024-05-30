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
    local mouse = {}
    mouse.x = x
    mouse.y = y
    for eventIndex, event in ipairs(slide_events) do
        if(event.mover == test_man) then
            table.remove(slide_events, eventIndex)
        end
    end
    create_slide_event(test_man, mouse)

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
    if x > card.display.x - card.display.offsetX+((cardIndex-1)*card_width)+16 
        and x < card.display.x+card_width - card.display.offsetX+((cardIndex-1)*card_width)+16 
        and y > card.display.y - card.display.offsetY 
        and y < card.display.y+card_width*2 - card.display.offsetY then
        return true
    end 
end
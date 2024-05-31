function love.keypressed(key)
    -- new game
    if key == 'n' then
        love.load()
    end
end

function love.mousepressed(x, y)
    local mouse = {}
    mouse.x = x
    mouse.y = y

    for eventIndex, event in ipairs(slide_events) do
        if(event.mover == test_man) then
            table.remove(slide_events, eventIndex)
        end
    end
    
    local action = nil
    if active_player == player then
        action = function() play_card_mouse(mouse, player) end
    end
    create_slide_event(test_man, mouse, action)

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

function play_card_mouse(mouse, target)
    for cardIndex, card in ipairs(target.hand) do
        if check_mouse_select(mouse.x, mouse.y, card, cardIndex) and not target.card_played then
            -- create_slide_event(test_man, mouse, action)
            play_card(target, cardIndex, dealer)
            break
        end 
    end
end

function check_mouse_select(x, y, card, cardIndex)
    if x > card.display.x+((cardIndex-1)*card_width)+16 
        and x < card.display.x+card_width+((cardIndex-1)*card_width)+16 
        and y > card.display.y
        and y < card.display.y+card_width*2 then
        return true
    end 
end
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
    if #dealer.hand > 0 then
        play_card(dealer, temp_card.index, player)
    end
end
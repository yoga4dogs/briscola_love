-- animations
-- this is all so jank

slide_events = {}

function create_slide_event(_mover, _target, _action)
    local slide_event = {
        mover = _mover,
        target = _target,
        action = _action or nil
    }
    table.insert(slide_events, slide_event)
end

function slide_handler(d_t)
    local check_unique = {}
    for eventIndex, event in ipairs(slide_events) do
        -- only do one event person mover until previous event is cleared
            -- check for final pos is ugly i dont like it, also doesnt work, shit twitches before settling in
        if(not contains(check_unique, event.mover)) then
            table.insert(check_unique, event.mover)
            slide_to(event.mover, event.target, event.mover.speed, d_t)
            if(math.floor(event.mover.x) == math.floor(event.target.x) and math.floor(event.mover.y) == math.floor(event.target.y)) then
                if event.action then
                    event.action()
                end
                table.remove(slide_events, eventIndex)
            end
        end
    end
end

function slide_to(mover, target, speed, delta)
    local direction = math.atan2(target.y-mover.y,target.x-mover.x)
    local speed = speed or 750

    if mover.facing then
        if(math.floor(target.x) > math.floor(mover.x)) then
            mover.facing = 1
        else
            mover.facing = -1
        end
    end

    local vx = math.cos(direction)*speed
    local vy = math.sin(direction)*speed

    mover.x = mover.x + vx * delta
    mover.y = mover.y + vy * delta
end

-- events
-- not implemented, probably need to rethink entirely

event_queue = {}

function create_event(_target, _action, _trigger)
    local event = {
        target = _target,
        action = _action,
        trigger = _trigger or 0
    }
    table.insert(event_queue, event)
end

function event_handler()
    for eventIndex, event in ipairs(event_queue) do
        if(event.trigger == 1) then
            event.action()
        end
    end
end
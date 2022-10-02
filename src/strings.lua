local S = {}
S.__index = S

-- creates a new convo entry
local function c(name, text)
    return { name = name, text = text }
end

-- nil entry is where the customer's request goes
local conversations = {
    {c("Gorbo", "Sure hot today"), c("Gobby", "Here comes a customer"), nil, c("Gorbo", "We can do that")},
    {c("Gorbo", "Wonder if we'll get any customers"), nil, c("Gorbo", "Most certainly!"), c("Gobby", "Wow, do that again")},
}

local responses = {
    A = {"test A1", "test A2"},
    B = {"test B1", "test B2"},
    C = {"test C1", "test C2"},
    D = {"test D1", "test D2"},
    F = {"test F1", "test F2"}
}

local requests = {
    {
        "test kettle 1",
        "test kettle 2",
    },
    {
        "test flask 1",
        "test flask 2",
    },
    {
        "test dagger 2",
        "test dagger 1",
    },
    {
        "test purse 1",
        "test purse 2",
    },
    {
        "test lute 1",
        "test lute 2",
    },
    {
        "test scroll 1",
        "test scroll 2",
    },
    {
        "test hat 1",
        "test hat 2",
    },
    {
        "test goblet 1",
        "test goblet 2",
    },
    {
        "test candle 1",
        "test candle 2",
    },
    {
        "test dolly 1",
        "test dolly 2",
    },
    {
        "test frog 1",
        "test frog 2",
    },
    {
        "test duck 1",
        "test duck 2",
    },
    {
        "test hatchet 1",
        "test hatchet 2",
    },
    {
        "test hourglass 1",
        "test hourglass 2",
    },
    {
        "test glasses 1",
        "test glasses 2",
    },
    {
        "test boots 1",
        "test boots 2",
    },
    {
        "test anvil 1",
        "test anvil 2",
    },
    {
        "test crab 1",
        "test crab 2",
    },
    {
        "test squid 1",
        "test squid 2",
    },
    {
        "test cactus 1",
        "test cactus 2",
    },
    {
        "test boat 1",
        "test boat 2",
    },
    {
        "test drumstick 1",
        "test drumstick 2",
    },
    {
        "test umbrella 1",
        "test umbrella 2",
    },
    {
        "test cat 1",
        "test cat 2",
    },
}

local function getRandomEntry(arr)
    local idx = love.math.random(1, #arr)
    return arr[idx]
end

function S.getRandomConversation(itemIdx)
    local convo = getRandomEntry(conversations)
    local request = getRandomEntry(requests[itemIdx])

    for i=1,#convo do
        if convo[i] == nil then
            convo[i] = c("Customer", request)
        end
    end

    return convo
end

function S.getRandomScoreResponse(score)
    local tab

    -- TODO reuse same scoring structure as algo
    if score > 0.9 then
        tab = responses.A
    elseif score > 0.8 then
        tab = responses.B
    elseif score > 0.7 then
        tab = responses.C
    elseif score > 0.6 then
        tab = responses.D
    else
        tab = responses.F
    end

    return getRandomEntry(tab)
end

return S

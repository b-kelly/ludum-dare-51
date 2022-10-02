local S = {}
S.__index = S

-- creates a new convo entry
local function c(name, text)
    return { name, text }
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
    "I'd like this copied",
    "I want another of these",
    "Copy this please",
}

local function getRandomEntry(arr)
    local idx = love.math.random(#arr)
    return arr[idx]
end

function S.getRandomRequest()
    return getRandomEntry(requests)
end

function S.getRandomConversation()
    return getRandomEntry(conversations)
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

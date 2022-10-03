local utils = require "utils"
local S = {}
S.__index = S

-- bg is hard-coded for "Gorbo" -> "Gobby" -> "Customer" -> "Gorbo"
-- nil entry will be replaced by the customer's request text
local conversations = {
    {"Sure is hot today.", "Here comes a customer.", nil, "We can do that."},
    {"Wonder if we'll get any customers.", "If only it were that easy.", nil, "Man, I'm good."},
}

local responses = {
    [ScoreRank.AA] = {"test AA1", "test AA2"},
    [ScoreRank.B] = {"test B1", "test B2"},
    [ScoreRank.C] = {"test C1", "test C2"},
    [ScoreRank.D] = {"test D1", "test D2"},
    [ScoreRank.F] = {"test F1", "test F2"},
    [ScoreRank.FF] = {"test FF1", "test FF2"},
    [ScoreRank.CHEATER] = {"test CHEATER1", "test CHEATER2"}
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
            convo[i] = request
        end
    end

    return convo
end

function S.getRandomScoreResponse(score)
    local rank = utils.getScoreRank(score)
    local tab = responses[rank]

    return getRandomEntry(tab)
end

return S

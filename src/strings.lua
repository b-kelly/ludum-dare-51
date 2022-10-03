local utils = require "utils"
local S = {}
S.__index = S

-- bg is hard-coded for "Gorbo" -> "Gobby" -> "Customer" -> "Gorbo"
-- nil entry will be replaced by the customer's request text
local conversations = {
    {"Gobby, how're you doing in there?", "It's a bit hot, and these carrots are starting to smell a little funny. Oh, a customer!", nil, "That sounds like a lovely plan, and our contraption can gladly accomplish it. (Gobby, shhhh in there, they'll hear you!)"},
    {"Wonder if we'll get any customers.", "If only it were that easy.", nil, "Man, I'm good."},
}

--I copied some of these twice across ratings because they apply to more than one.
local responses = {
    [ScoreRank.AA] = {"Wow, we got a miracle worker over here! What an achievement!", "Do my eyes deceive me?! This looks just like the real thing!"},
    [ScoreRank.B] = {"I can definitely tell what you were going for, here. Wholly adequate. Thank you!", "This looks almost like what I thought I'd get when I showed up here!"},
    [ScoreRank.C] = {"Well, I suppose it could have been worse! Thank you for this nearly-identifiable object!", "This was definitely almost somewhat correct, so I will give you a definitely almost somewhat tip."},
    [ScoreRank.D] = {"Oh! Um... how... nice! I will treasure this... thing... forever.", "Wow, cool! When do I get the item I actually ordered? Oh, wait, what? Ah. Er, thank you?"},
    [ScoreRank.F] = {"Thank you SO much for this BLOB.", "I... do I really have to pay for this?", "It's almost like you threw random objects together in a random pattern...", "Hey, Gorbo? I think your machine is broken..."},
    [ScoreRank.FF] = {"It's almost like you threw random objects together in a random pattern...", "Hey, Gorbo? I think your machine is broken...", "Thank you SO much for this BLOB.", "I... do I really have to pay for this?"},
    [ScoreRank.CHEATER] = {"Dang, did you cheat? Because it's effectively impossible to get a perfect score. You can do better.", "Tsk tsk. Cheating, are we? What a shame."}
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

local customerNames = {
  "Esmerelda",
  "Jiminy",
  "Rogerette",
  "Felicity",
  "Robin",
  "Genevieve",
  "Bobbert",
  "Grinny",
  "Alastair",
  "Elrica",
  "Griffin",
  "Edith",
  "Lance",
  "Arturo",
  "Percy",
  "Riverine",
  "Vivian",
  "Willow",
  "Twig-eater",
  "Stompy",
  "Rhiannon",
  "Toad-hopper",
  "Mush-goom",
  "Isolde",
  "Hammer-heart",
  "Crickets-bane",
  "Feather-hat",
  "Gonzor",
  "Groggle"
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

local utils = require "utils"
local S = {}
S.__index = S

-- bg is hard-coded for "Gorbo" -> "Gobby" -> "Customer" -> "Gorbo"
-- nil entry will be replaced by the customer's request text
local conversations = {
    {"Gobby, how're you doing in there?", "It's a bit hot, and these carrots are starting to smell a little funny. Oh, a customer!", nil, "That sounds like a lovely plan, and our contraption can gladly accomplish it. (Gobby, shhhh in there, they'll hear you!)"},
    {"Wonder if we'll get any customers.", "If only it were that easy.", nil, "Man, look at that customer! I'm good."},
    {"Sometimes I feel as if Gorbo the Great's genius is wasted on these kinds of projects.", "Sometimes *I* feel as if Gobby's genius is perfectly suited to these kinds of projects!", nil, "Certainly. Well, let's see just how suited your genius is."},
    {"Ah, what a nice breeze we're having today, eh, Gobby?.", "Gobby wouldn't know... Gobby's in a stump.", nil, "Yup! Okay, magical contraption, do your thing!"},
    {"Step right up, step right up! Get your objects made here!", "But please don't step on my stump!", nil, "It'll be ready in a jiffy! Smart folks choose Gorbo and Gobby's!"},
    {"Hey Gobby, ever wonder what's outside this forest?", "Sometimes I wonder what's outside this stump... I used to remember...", nil, "Yes yes yes! Keep going, contraption! You can do it!"},
    {"Hey, wanna switch spots for a bit?", "Would I ever! Wow, Gorbo, thanks, I'm getting a bit cramped in here.", nil, "Coming right up! Er, maybe next time, Gobby."},
    {"Get your objects here! Ready in 10 or it's free!", "You know, 10 seconds isn't a very long time to get this done. Can't I have 30?", nil, "Can do, can do. This contraption is SO fast, just you watch!"},
    {"Gorbo.", "Gobby.", nil, "Our contraption can do that!."},
    {"Gorbo.", "Gobby.", nil, "We'll get on that right away."},
    {"Gorbo.", "Gobby.", nil, "Absolutely!."},
    {"Gorbo.", "Gobby.", nil, "Yes, I think we can manage that."},
    {"Gorbo.", "Gobby.", nil, "Of course."},
    {"Gorbo.", "Gobby.", nil, "Sure can."},
    {"Gorbo.", "Gobby.", nil, "It'll be ready in two shakes of a goblin's ears."},
    {"Gorbo.", "Gobby.", nil, "Yep, it'll be ready in 10 or my name ain't Gorbo."}
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
        "Hello there, I seem to have misplaced my tea kettle. I can't heat up water for my magic potions anymore! Can you help?",
        "Hi! I heard of this thing called a ... kettle? It magically makes anything hot? Incredible! Can you make those here?",
    },
    {
        "Ahem... hello. I need a love potion. Don't ask questions, and also don't tell Gorzoo about it. Can you do it?",
        "Oh, cool! You can make anything?? I need a potion! It doesn't have to do anything, I just want it to look cool on my shelf. How about it?",
    },
    {
        "Greetings! Can magically created daggers be traced back to their owners? Asking for a friend. Also can you make me one? I mean, my friend.",
        "Hullo. I would like to stab things please. Meat, the floor, an apple, et cetera. Can you help me with, say, a large knife of some kind?",
    },
    {
        "Hey, are you able to get coins outta that contraption? Is that like wishing for more wishes from a genie? Don't think about it too much, can you make me a coinpurse?",
        "Good morrow! One coinpurse please. With coins included, if you please. Else, why bother?",
    },
    {
        "Hello! I need to impress Gorinthia with my lute-playing skills. Unfortunately I do not have a lute. Can you help?",
        "Good day, Gorbo! Does having a lute automatically make me a world-class bard superstar? Probably! Can you make me one?",
    },
    {
        "Err, hi Gorbo. Where's Gobby? No matter. Anyway, I forgot to do my homework. I mean, my dog ate it. Can you make me a scroll that has a book report on it? Any book.",
        "Hiya! I need a scroll I can read in the local potion shop so I look smart and cool. Can I get a really smart one? Like philosophy or something.",
    },
    {
        "Oh, hey, Gorbo! Your hat is SO cool. I would like one just like it. Not for impersonation reasons, for Looking Cool reasons. How about it?",
        "Hello, is this the amazing machine thing? Can I have something made? Maybe like... a hat?",
    },
    {
        "Muah-ha-ha. Gorbo, my friend! I need a goblet. Ideally, it will be a beautiful and fancy goblet that nobody would EVER suspect could possibly contain poison. What do you think?",
        "Hey, Gorbo? I may have accidentally broken my mom's favorite goblet and I really need a new one. Like, really fast. Can you do that?",
    },
    {
        "Good day! It is so dark in my cave and I keep tripping on Stalactites. Stalagmites? Anyway I keep tripping on them. Could you make me a candlestick?",
        "Hello! I would like to order one candlestick, please. With a candle on it. Ooh, can it even already be lit up? I ran out of matches.",
    },
    {
        "Oh Gorbo I'm so glad to see you. I forgot to buy my daughter a gift for Solstice and she REALLY wanted this one doll, and it's all sold out at the toymaker's! Is there any way you could make one just like it?",
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

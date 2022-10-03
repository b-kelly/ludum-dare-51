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
    {"You know, I think business is starting to pick up.", "That's good news! Maybe we can upgrade to an actual contraption someday, instead of just me in a stump.", nil, "Yeah yeah, later, Gobby. Our contraption can do that!"},
    {"Treat yourself to a freshly copied object, any object you'd like!", "Hopefully one that won't like, bite me or poison me or something.", nil, "We'll get on that right away. Gobby, you'll be fine."},
    {"Objects copied faster than any incredible copying contraption in the forest, guaranteed!", "...are there really other copying contraptions out there? Maybe I could compare notes with them.", nil, "Absolutely! And Gobby, no, they can't learn our secrets!"},
    {"I'm tired of standing here all day, ugh.", "I mean, we could switch spots...", nil, "Yes, I think we can manage that. What, no Gobby, not switching. We can manage making that."},
    {"You know what would be SO cool to copy? A pony.", "Well, Gorbo, I don't know if a pony would fit in here with me...", nil, "Of course. ...perhaps you'd like a pony as well? No? No matter."},
    {"Hey Gobby? Why do we call this copying? It's more like 'conjuring' or 'creating'.", "Well, I think copying is probably a bit catchier, right?", nil, "Sure can. Let's copy away!"},
    {"Boooored. Getcha things here, objects of whatever kind, get 'em here...", "You gotta be more enthusiastic than that!", nil, "It'll be ready in two shakes of a goblin's ears."},
    {"Hey Gobby, what's your favorite puppet show?", "I like spooky puppet shows like 'Autumn Ghost' and 'I Know What You Did Last Solstice In The Apothecary'.", nil, "Yep, it'll be ready in 10 or my name ain't Gorbo. Gobby, I haven't seen either of those!"}
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
        "Hey Gorbo, I was actually looking for Gobby? Because he forgot that today is his daughter's birthday? And he better make a doll for little Gobbina ASAP?",
    },
    {
        "Hi! I was working on a quick little potion and realized I am ALL out of frogs. Got any frogs in there? Can you make me one?",
        "Hi there. I need a new best friend. And I would like that friend to be a frog. Can I have a frog please? Like, a really nice one who likes to play board games?",
    },
    {
        "Hello. My pond back home is sorely lacking something and I *think* what it's lacking is a duck. Can you make me a duck?",
        "Ooooh, you can make anything? Ha-ha, what about a duck? That would be funny. A duck! Quack quack! Ha-ha-ha. A duck. A duck?",
    },
    {
        "Greetings! I need a tool that is good for chopping trees, I'm looking to get into lumberjacking. Maybe like... a tree-chopper? Is that what it's called? Is that possible?",
        "Hullo. I was chopping things and accidentally tried to chop a rock, and it didn't work, and now my axe is broken. Could you make me a new one?",
    },
    {
        "Oh, I'm so glad you're open! I keep trying to bake cookies and keep burning them because I don't have a way to time them! Could you make me an hourglass?",
        "Hi there. I'm trying to cultivate a sort of mysterious, vaguely menacing vibe. I think having an hourglass would help. What do you think? You got an hourglass in there?",
    },
    {
        "Gorbo, is that you? I can't quite see. My old glasses broke. Can you make me new glasses? If that IS you, Gorbo. If not, hello stranger, could YOU make me glasses?",
        "Hello! I hear glasses are very 'in' right now. I need the 'in'-nest glasses possible, can you accommodate me?",
    },
    {
        "Hi Gorbo! I am SO tired of walking everywhere. I mean, one step, then another one, then another one... who has the time?! How about some winged boots?",
        "Greetings and salutations. I'm running a race soon and would REALLY like to win, so can you make some winged boots? I'm pretty sure that's not cheating.",
    },
    {
        "Ugh, Gorbo, you won't believe what happened. Garbonzo decided he'd use my forge and he split my anvil in two! Can you believe the nerve of that guy? Now I need a new Anvil. Perhaps you could make me one?",
        "Oh, hi, is this the amazing copier? I wanted to get into blacksmithing and *apparently* just smashing metal on the floor doesn't work. I need to smash it on an *anvil*. Do you make those here?",
    },
    {
        "Hello Gorbo. I am tired of using scissors like some sort of boring ...person. I want to start a new trend. Wait for it... A CRAB! How interesting will it be to use a crab to cut things?! I can't wait. Can you make one?",
        "Ooooh, Gorbo! Crabs are SO CUTE. Can you make me the CUTEST crab?",
    },
    {
        "Beautiful morning, eh Gorbo? I keep running out of ink and I heard from Penelope that she uses a SQUID to get her ink. That sounds way easier than making it from berry juice every day. Can you copy me a squid?",
        "Hi there. My aquarium is not complete without a squid. Do you do squids here?",
    },
    {
        "Hi! These pesky birds won't stop eating my plants. The scarecrow I made isn't working, so I thought I'd show them by planting a cactus. So spiky! Can you copy a cactus for me?",
        "Gorbo! Can't talk, I'm training for a marathon in the desert. I need to learn how to get water from a cactus so I need a cactus to practice. Can you make me one?",
    },
    {
        "Siiiigh, hey Gorb. My nephew won't shut up about a pirate boat. Pirate boat, pirate boat, that's all he talks about. Could you make me a toy boat with that contraption of yours so maybe he'll stop talking about it?",
        "Hello! My pet mice want to go on a seafaring adventure, I just know it. The first thing they need, aside from sailing knowledge, is a cool little boat. Could you make one of those?",
    },
    {
        "Hi! Oh GOODNESS I'm so happy you're here. I'm so hungry, can you copy me some food? Anything, as long as it's a LOT. Maybe a drumstick or something?",
        "Hey Gorbo! So, my husband wants to be a 'drummer', and he said that means he needs 'drumsticks'. I don't know why meat is so important for banging on a piece of wood but whatever. Can I have a turkey drumstick please?",
    },
    {
        "Gorbo, what are you doing standing out in the rain?! Can you make me an umbrella? You might want to make yourself one too, if we're being honest.",
        "Morning! I heard from my friend Goobily that if you have an umbrella, you can fly! Like, you can at LEAST fall really slowly. Could you copy one?",
    },
    {
        "Ooooh, Gorbo, could I please have a kitty? Pretty please, I want a kitty so bad, I will name her Purrcilla and I will take SUCH good care of her!",
        "Is this the copy place? I have such a mouse problem in my house, and I really need a cat to handle it. Maybe a cute one, please.",
    }
}

customerNames = {
  "Esmeralda",
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
  "Gorbalina",
  "Stompy",
  "Rhiannon",
  "Hooper",
  "Franto",
  "Isolde",
  "Gertilda",
  "Banfalda",
  "Kartina",
  "Gonzor",
  "Groggle"
}



function S.getRandomConversation(itemIdx)
    local convo = utils.getRandomEntry(conversations)
    local request = utils.getRandomEntry(requests[itemIdx])

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

    return utils.getRandomEntry(tab)
end

return S

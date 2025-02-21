//
//  DefaultData.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/19/25.
//





var quotesList = {
    var list = OTDListItems()
    for q in quotes {
        list.addItem(q)
    }
    list.sortAlphabeticallyByHeader()
    return list
}

var poemsList = {
    var list = OTDListItems()
    for p in poems {
        list.addItem(p)
    }
    return list
}

var insightsList = {
    var list = OTDListItems()
    for i in insights {
        list.addItem(i)
    }
    return list
}


let quotes: [OTDItem] = [
    OTDItem(header: "Jordan Peterson", body: "There are cathedrals everywhere for those with the eyes to see."),
    OTDItem(header: "Carl Sagan", body: "We are like butterflies who flutter for a day and think it is forever."),
    OTDItem(header: "Man’s Search for Meaning", body: "No man should judge unless he asks himself an absolute honesty whether, in a similar situation, he might not have done the same."),
    OTDItem(header: "Fyodor Dostoevsky", body: "There is only one thing that I dread: not to be worthy of my sufferings."),
    OTDItem(header: "Spinoza’s Ethics", body: "Emotion, which is suffering, ceases to be suffering as soon as we form a clear and precise picture of it."),
    OTDItem(header: "Richard Feynman", body: "Study hard what interests you the most in the most undisciplined, irreverent, and original manner."),
    OTDItem(header: "Dumbledore", body: "Words are, in my not-so-humble opinion, our most inexhaustible source of magic. Capable of both inflicting injury and remedying it.")
]

let poems: [OTDItem] = [
    OTDItem(header: nil, body: "I would give anything for your friendship\nYou have no idea\n I would take a bullet just to let you live\nYou’re worth it\nThe countless drinks and times we had\nThey’ll lift me up to Heaven\nAnd when I’m gone I’ll bless you all the way\nYour guardian all the way\nAll the way until our next lives\nAll the way\nYou brought me more than could fit into one life\nMemories I wish I could sink into forever\nYou marks on my soul age like leather\nI’ll love you forever"),
    OTDItem(header: nil, body: "Sneaking out into the hills\nTipsy nights and teenage thrills\nLustful whispers give you chills\nYou taunt me cause you know I will\n\nToo many feelings that I haven’t felt\nMy bucket list takes two\nI hope that makes sense\nMy dear let me make you feel like yourself\nRelax and I’ll take care of everything else\n\nThings you say stay with me\nCareful what you wish for\n\nBite your lip because you’re speechless\nI’ll bite your neck just like the leeches\nOver under that we fall asleep\nOver under sounding good to me "),
]

let insights: [OTDItem] = [
    OTDItem(header: "Tune into the absurd.", body: nil),
    OTDItem(header: "Curiosity is the first victim of overstimulation.", body: nil),
    OTDItem(header: "Worry not about the language of your visions, but rather the connection of your visions to present sensations.", body: nil),
    OTDItem(header: "All I do is sit and dream about who I could be.", body: nil),
    OTDItem(header: "Your love is given in the shape of your personality.", body: nil),
]


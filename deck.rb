require 'squib'
require 'pp'

deck = Squib.xlsx file: 'junk.xlsx'
junk = deck['Type'].select {|t| %w{item blueprint victory}.include? t }
img = 'color'

#TODO put this into excel
bgimage = {
  'item' => "#{img}/item-background.png",
  'blueprint' => "#{img}/blueprint-background.png",
  'victory' => "#{img}/blueprint-background.png"
}

# Make a hash of map to the range id
id = {} ; deck['Name'].each_with_index{ |name,i| id[name] = i}

# Items and Blueprints decks
Squib::Deck.new(cards: junk.size, config: 'config.yml', layout: 'layout.yml') do 

  png file: junk.collect {|j| bgimage[j] }

  # can = id['Pile of Handwashed Soup Cans']
  # text range: can, str: "Pile of Handwashed Soup Cans", layout: :title
  # save range: can, format: :png

  text str: deck['Name'], layout: :title
  #png file: 'tgc-proof-overlay.png', alpha: 0.5
  save format: :png
end
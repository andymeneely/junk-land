require 'squib'
require 'pp'

deck = Squib.xlsx file: 'junk.xlsx'
junk = deck['Type'].select {|t| %w{item blueprint victory}.include? t }
img = 'color'

#TODO put this into excel
bgimage = {
  'item' => "#{img}/item-background.png",
  'blueprint' => "#{img}/blueprint-background.png"
}

# Items and Blueprints decks
Squib::Deck.new(cards: junk.size, config: 'config.yml') do 
  
  png file: junk.collect {|j| bgimage[j] }

  save format: :png
end
require 'squib'
require 'pp'

deck = Squib.xlsx file: 'deck.xlsx'
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
Squib::Deck.new(cards: junk.size, config: 'config.yml', layout: 'junk.yml') do 

  png file: junk.collect {|j| bgimage[j] }
  text str: deck['Name'], layout: :title

  knobs = id['Sack of Door Knobs']
  %w(string wood metal glass duct_tape).each do |resource|
    svg range: knobs, file: 'resources.svg', id: resource, layout: resource
  end

  png file: 'tgc-proof-overlay.png', alpha: 0.5
  save range: knobs, format: :png

  
  # save format: :png
end
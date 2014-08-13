require 'squib'
require 'pp'
require_relative 'squib_helpers.rb'

deck = Squib.xlsx file: 'deck.xlsx'
junk = deck['Type'].select {|t| %w{item blueprint victory}.include? t }
img = 'color'

# Replace spaces with programmer-friendly underscores
%w(Bonus1Type Bonus2Type).each { |b| underscorify(deck[b]) }

bgimage = {
  'item' => "#{img}/item-background.png",
  'blueprint' => "#{img}/blueprint-background.png",
  'victory' => "#{img}/blueprint-background.png"
}

# Make a hash of name to the range id
id = {} ; deck['Name'].each_with_index{ |name,i| id[name] = i}

# Junk = Items and Blueprints decks
Squib::Deck.new(cards: junk.size, config: 'config.yml', layout: 'junk.yml') do 

  png file: junk.collect {|j| bgimage[j] }
  text str: deck['Name'], layout: :title

  %w(string wood metal glass duct_tape).each do |resource|
    range = [] # only put svgs out on places with non-nil texts
    deck[resource].each_with_index { |n, i| range << i unless n.nil? }
    svg range: range, file: 'resources.svg', id: resource, layout: resource 
    text range: range, str: deck[resource], layout: "#{resource}_text"
  end

  svg file: 'junk-bonuses.svg', id: deck['Bonus1Type'], layout: :bonus1, force_id: true
  text str: deck['Bonus1Num'], layout: :bonus1_text, color: :black

  svg file: 'junk-bonuses.svg', id: deck['Bonus2Type'], layout: :bonus2, force_id: true
  text str: deck['Bonus2Num'], layout: :bonus2_text, color: :black

  png file: 'tgc-proof-overlay.png', alpha: 0.5
  save range: id['Saggy Park Bench'], 
      format: :png
  
  # save format: :png
end
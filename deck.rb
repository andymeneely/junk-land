require 'squib'
require 'pp'
require_relative 'squib_helpers.rb'

deck = Squib.xlsx file: 'deck.xlsx'
junk = deck['Type'].select {|t| %w{item blueprint victory}.include? t }
img = 'color'

# Replace spaces with programmer-friendly underscores
%w(Bonus1Type Bonus2Type ConvType Conv2Type).each { |b| underscorify(deck[b]) }

#Layout Bonus1 to the left if there's two bonuses, middle otherwise
bonus1_layout = deck['Bonus2Type'].collect {|t| t.to_s.empty? ? :bonus1_middle : :bonus1_left }
bonus1_layout_text = bonus1_layout.collect {|l| "#{l}_text"}

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

  svg file: 'junk-bonuses.svg', id: deck['Bonus1Type'], layout: bonus1_layout, force_id: true
  text str: deck['Bonus1Num'], layout: bonus1_layout_text

  svg file: 'junk-bonuses.svg', id: deck['Bonus2Type'], layout: :bonus2, force_id: true
  text str: deck['Bonus2Num'], layout: :bonus2_text

  svg file: 'junk-bonuses.svg', id: deck['Convert'], layout: :convert, force_id: true
  svg file: 'resources.svg', id: deck['ConvType'], layout: :convert_type_from, force_id: true
  svg file: 'resources.svg', id: deck['Conv2Type'], layout: :convert_type_to, force_id: true
  text str: deck['ConvNum'], layout: :convert_text_from
  text str: deck['Conv2Num'], layout: :convert_text_to

  #png file: 'tgc-proof-overlay.png', alpha: 0.5
  #save range: id['Portable Flea Market'], format: :png
  
  save format: :png
end
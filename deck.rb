require 'squib'
require_relative 'squib_helpers.rb'

dims = {
  'junk' => {width: 825, height: 1125, rotate: false},
  'friends' => {width: 1125, height: 825, rotate: false},
}

# %w(junk friends).each_with_index do |type, i|
  type = 'junk' ; i = 0
  deck = Squib.xlsx file: 'data/deck.xlsx', sheet: i

  # Convert spaces to programmer-friendly underscores for "type" columns
  deck.keys.each { |k| underscorify(deck[k]) if k.downcase.end_with? 'type' }

  # Make a hash of name to the range id
  at = {} ; deck['Name'].each_with_index{ |name,i| at[name] = i}

  Squib::Deck.new(cards: deck['Name'].size, layout: "#{type}.yml",
                  width: dims[type][:width], height: dims[type][:height]) do 
    png file: deck['Type'].collect {|t| "#{t}-background.png" }
    text str: deck['Name'], layout: :title
    text str: deck['snark'], layout: :snark

    # Each resource gets its own layout entry
    %w(string wood metal glass duct_tape).each do |resource|
      unless deck[resource].nil?
        range = [] # only put svgs out on places with non-nil texts
        deck[resource].each_with_index { |n, i| range << i unless n.nil? }
        svg range: range, file: 'resources.svg', id: resource, layout: resource 
        text range: range, str: deck[resource], layout: "#{resource}_text"
      end
    end

    # Layout bonus1 to the left if there's two bonuses, middle otherwise
    deck["bonus1_layout"] = deck['bonus2_type'].collect do |t| 
      t.to_s.empty? ? :bonus1_middle : :bonus1_left
    end
    deck["bonus1_text_layout"] = deck["bonus1_layout"].collect {|l| "#{l}_text"}

    # Add the convert bonus base where appropriate
    svg file: "#{type}-bonuses.svg", id: deck['convert'], force_id: true, 
        layout: :convert_base

    # Bonuses are all different, but share a layout style
    %w(bonus1 bonus2 convert convert2 friendreq1 friendreq2).each do |bonus|
      unless deck["#{bonus}_type"].nil?
        svg file: (bonus.start_with?('bonus') ? "#{type}-bonuses.svg" : 'resources.svg'),
            id: deck["#{bonus}_type"], force_id: true, 
            layout: deck["#{bonus}_layout"] || bonus
        text str: deck["#{bonus}_num"], 
             layout: deck["#{bonus}_text_layout"] || "#{bonus}_text"
      end             
    end
    png file: 'tgc-proof-overlay.png', alpha: 0.5
    save_json cards: @cards.size, deck: deck, file: "data/#{type}.json"
    save_png format: :png, prefix: "#{type}_", rotate: dims[type][:rotate], range: at['Duct Tape Wallet']

   end
# end
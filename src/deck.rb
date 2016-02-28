require 'squib'
require_relative 'squib_helpers'
require_relative 'build_groups'

dims = {
  'junk'    => { width: 825, height: 1125, rotate: false },
  'friends' => { width: 1125, height: 825, rotate: false },
}

pallete = get_pallete_from_env

%w(junk friends).each_with_index do |type, i|
  deck = Squib.xlsx file: 'data/deck.xlsx', sheet: i

  # Convert spaces to programmer-friendly underscores for "type" columns
  deck.keys.each { |k| underscorify(deck[k]) if k.downcase.end_with? 'type' }

  # Make a hash of name to the range id
  at = {} ; deck['Name'].each_with_index{ |name,i| at[name] = i}

  puts "-- #{type} --"
  Squib::Deck.new(cards: deck['Name'].size,
                  layout: "#{type}.yml",
                  width: dims[type][:width], height: dims[type][:height]) do
    enable_groups_from_env!

    group :color, msg: 'Background artwork' do
      png file: deck['Type'].collect {|t| "#{t}-background.png" }
    end

    group :bw do
      background color: :white
    end

    text str: deck['Name'], layout: "title_#{pallete}"
    text str: deck['snark'], layout: :snark

    # Each resource gets its own layout entry
    %w(string wood metal glass duct_tape).each do |resource|
      unless deck[resource].nil?
        range = [] # only put svgs out on places with non-nil texts
        deck[resource].each_with_index { |n, i| range << i unless n.nil? }
        svg range: range, id: resource, layout: resource,
            data: recolor_svg('resources.svg', pallete)
        text range: range, str: deck[resource], layout: "#{resource}_text"
      end
    end

    # Layout bonus1 to the left if there's two bonuses, middle otherwise
    deck["bonus1_layout"] = deck['bonus2_type'].collect do |t|
      t.to_s.empty? ? :bonus1_middle : :bonus1_left
    end
    deck["bonus1_text_layout"] = deck["bonus1_layout"].collect {|l| "#{l}_text"}

    # Add the convert bonus base where appropriate
    svg id: deck['convert'], force_id: true, layout: :convert_base,
        data: recolor_svg("#{type}-bonuses.svg", pallete)

    # Bonuses are all different, but share a layout style
    %w(bonus1 bonus2 convert convert2 friendreq1 friendreq2).each do |bonus|
      unless deck["#{bonus}_type"].nil?
        svg id: deck["#{bonus}_type"], force_id: true,
            layout: deck["#{bonus}_layout"] || bonus,
            data: (bonus.start_with?('bonus') ?
                    recolor_svg("#{type}-bonuses.svg", pallete) :
                    recolor_svg('resources.svg', pallete) )
        text str: deck["#{bonus}_num"],
             layout: deck["#{bonus}_text_layout"] || "#{bonus}_text"
      end
    end

    enable_group :full
    group :full do
      save_json cards: @cards.size, deck: deck, file: "data/#{type}.json"
      save_png format: :png, prefix: "#{type}_", rotate: dims[type][:rotate]
    end

    enable_group :dev
    group :dev do
      save_png range: 0, prefix: "#{type}_"
      save_png range: 38, prefix: "#{type}_" if type == 'junk'
    end

    # enable_group :sheets
    group :sheets do
      save_sheet prefix: "#{type}_"
    end

    # enable_group :showoff
    group :showoff do
      showcase file: "#{type}_showcase.png", range: 0..5
      hand file: "#{type}_hand.png", range: 0..5, trim_radius: 37.5
    end
   end
end

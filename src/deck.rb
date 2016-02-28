require 'squib'
require_relative 'squib_helpers'
require_relative 'build_groups'

dims = {
  'junk'    => { width: 825, height: 1125, rotate: false },
  'friends' => { width: 1125, height: 825, rotate: false },
}

pallete = get_pallete_from_env

%w(junk friends).each_with_index do |type, i|
  data = Squib.xlsx file: 'data/deck.xlsx', sheet: i

  # Convert spaces to programmer-friendly underscores for "type" columns
  data.keys.each { |k| underscorify(data[k]) if k.downcase.end_with? 'type' }

  # Make a hash of name to the range id
  at = {} ; data['Name'].each_with_index{ |name,i| at[name] = i}

  puts "-- #{type} --"
  Squib::Deck.new(cards: data['Name'].size,
                  layout: "#{type}.yml",
                  width: dims[type][:width], height: dims[type][:height]) do
    enable_groups_from_env!

    group :color, msg: 'Background artwork' do
      png file: data['Type'].collect {|t| "#{t}-background.png" }
    end

    group :bw do
      background color: :white
      rect layout: :cut
    end

    text str: data['Name'], layout: "title_#{pallete}"
    text str: data['snark'], layout: :snark
    text str: "Built #{Date.today}", layout: :version

    # Each resource gets its own layout entry
    %w(string wood metal glass duct_tape).each do |resource|
      unless data[resource].nil?
        range = [] # only put svgs out on places with non-nil texts
        data[resource].each_with_index { |n, i| range << i unless n.nil? }
        svg range: range, id: resource, layout: resource,
            data: recolor_svg('resources.svg', pallete)
        text range: range, str: data[resource], layout: "#{resource}_text"
      end
    end

    # Layout bonus1 to the left if there's two bonuses, middle otherwise
    data["bonus1_layout"] = data['bonus2_type'].collect do |t|
      t.to_s.empty? ? :bonus1_middle : :bonus1_left
    end
    data["bonus1_text_layout"] = data["bonus1_layout"].collect {|l| "#{l}_text"}

    # Add the convert bonus base where appropriate
    svg id: data['convert'], force_id: true, layout: :convert_base,
        data: recolor_svg("#{type}-bonuses.svg", pallete)

    # Bonuses are all different, but share a layout style
    %w(bonus1 bonus2 convert convert2 friendreq1 friendreq2).each do |bonus|
      unless data["#{bonus}_type"].nil?
        svg id: data["#{bonus}_type"], force_id: true,
            layout: data["#{bonus}_layout"] || bonus,
            data: (bonus.start_with?('bonus') ?
                    recolor_svg("#{type}-bonuses.svg", pallete) :
                    recolor_svg('resources.svg', pallete) )
        text str: data["#{bonus}_num"],
             layout: data["#{bonus}_text_layout"] || "#{bonus}_text"
      end
    end

    save_json cards: @cards.size, deck: data, file: "data/#{type}.json"

    # enable_group :proof
    group :proof do
      png file: 'tgc-proof-overlay.png'
    end

    # enable_group :full
    group :full do
      save_png format: :png, prefix: "#{type}_", rotate: dims[type][:rotate]
      save_pdf file: "#{type}.pdf", trim: 37.5
    end

    enable_group :dev
    group :dev do
      save_png range: 0..1, prefix: "#{type}_"
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

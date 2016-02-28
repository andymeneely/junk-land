require 'pp'
require 'json'

# Replace spaces with programmer-friendly underscores
def underscorify(bonus_col)
  bonus_col.each do |type|
    type.gsub!(' ', '_') unless type.nil?
  end
end

# Generates a JSON output from deck for easy Git tracking.
def save_json(cards: 1, deck: {}, file: 'deck.json')
  h = {}
  (0..cards-1).each do |i|
    h[i] ||= {}
    deck.each_pair do |key, value|
      h[i][key] = value[i]
    end
  end
  File.open(file,"w") do |f|
    f.write(JSON.pretty_generate(h))
  end
end

def get_pallete_from_env
  ENV['SQUIB_BUILD_GROUPS']['bw'].nil? ? 'color' : 'bw'
end

def version_string
  Time.now.strftime('%Y-%m-%d')
end

def dropbox_dir
  "#{ENV['DROPBOX_DIR']}/JunkLandBuilds/#{version_string}"
end

def recolor_svg(file, pallete)
  svg = File.read("img-color/#{file}")
  return svg unless pallete == 'bw'
  return svg.gsub(':#ffffff', 'snarfblat')
            .gsub(/:#[0-9a-f]{6}/, ':#000000' )
            .gsub('snarfblat'   , ':#ffffff')

end

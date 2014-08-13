# Replace spaces with programmer-friendly underscores
def underscorify(bonus_col)
  bonus_col.each do |type|
    type.gsub!(' ', '_') unless type.nil?
  end
end
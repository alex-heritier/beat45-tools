#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

# Remove extra config info
def remove_extra_info lines
  new_lines = []

  is_in_insert_block = false
  lines.each do |line|
    if is_in_insert_block
      if (/^$/.match(line) != nil) then return new_lines end
      new_lines.push(line)
    elsif
      if (/^.*INSERT.*$/.match(line) != nil) then is_in_insert_block = true end # Check for INSERT line
    end
  end

  return new_lines
end

# Format data
def format_data lines
  new_lines = []

  lines.each do |line|
    line.gsub!(/\('?/, "")
    line.gsub!(/'?\),?;?/, "")

    components = line.split(/'?, '?/)
    video_id = components[0]
    raw_songs = components[1]

    songlist = raw_songs.split("\\n")
    songlist.each do |song|
      formatted_song = "#{video_id} % #{song}"
      new_lines.push(formatted_song)
    end
  end

  return new_lines
end

input_lines = []
File.foreach(ARGV[0], sep: "\n") {|line| input_lines.push(line)}

formatted_lines = remove_extra_info(input_lines)
formatted_lines = format_data(formatted_lines)

puts formatted_lines

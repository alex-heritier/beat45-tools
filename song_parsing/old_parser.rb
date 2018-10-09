#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

current_id = -1
is_valid = true
video_songs = []

def get_line_status entry
  is_valid = true
  reason = ''

  if (entry.scan(/ -[\n\ ]/).size == 0) # Check for missing hyphen
    is_valid = false
    reason = 'Missing hyphen'
  elsif (entry.scan(/ - /).size > 1) # Check for multiple hyphens surrounded by whitespace
    is_valid = false
    reason = 'Multiple hyphens used for formatting'
  elsif (/-(?!.)/ =~ entry) # Check for missing right value
    is_valid = false
    reason = 'Missing right value'
  elsif (/[\[\]]/ =~ entry) # Check for brackets
    is_valid = false
    reason = 'Invalid characters [ ]'
  elsif (/[\(\)]/ =~ entry) # Check for parens
    is_valid = false
    reason = 'Invalid characters ( )'
  elsif (/[\t]/ =~ entry) # Check for tabs
    is_valid = false
    reason = 'Invalid character TAB'
  end

  return {
    :is_valid => is_valid,
    :reason   => reason
  }
end

broken_songs = "broken_songs.txt"
maybe_better = "songs_no_parens_brackets_no_clean_hd_maybe_better.txt"

File.foreach(maybe_better, sep: "\n") do |line|
  /^(?<video_id>\d+) % (?<rest_of_line>.*$)/ =~ line

  if (video_id != current_id)
    if (current_id != -1 and !is_valid)
      video_songs.each do |entry|
        display_text = "#{entry[:value]}"
        if (!entry[:is_valid]) then display_text += "\t\t### #{entry[:reason]}" end
        puts display_text
      end
    end

    current_id = video_id
    is_valid = true
    video_songs = []
  end

  line_status = get_line_status(line)
  if (!line_status[:is_valid])
    is_valid = false
  end

  line_status[:value] = line.tr("\n", '')
  video_songs.push(line_status)
end

# Print out last block
video_songs.each do |entry|
  display_text = "#{entry[:value]}"
  if (!entry[:is_valid]) then display_text += "\t\t### #{entry[:reason]}" end
  puts display_text
end

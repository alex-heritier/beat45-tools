#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

def get_line_status entry
  is_valid = true
  reason = ''

  if (/[\[\]]/ =~ entry) # Check for brackets
    is_valid = false
    reason = 'Invalid characters [ ]'
  elsif (/^\d+\. / =~ entry) # Check for unnecessary numbering
    is_valid = false
    reason = 'Unnecessary numbering (ex. "1. ...", "2. ...")'
  elsif (entry.scan(/ -[\n\ ]/).size == 0) # Check for missing separator hyphen
    is_valid = false
    if (entry.scan(/ -\t/).size > 0) # Check for tab after hyphen
      reason = 'Separator hyphen has a TAB after it'
    elsif (entry.scan(/\t- /).size > 0) # Check for tab before hyphen
      reason = 'Separator hyphen has a TAB before it'
    else
      reason = 'Missing separator hyphen'
    end
  elsif (/[\t]/ =~ entry) # Check for tabs
    is_valid = false
    reason = 'Invalid character TAB'
  elsif (entry.scan(/ - /).size > 1) # Check for multiple hyphens surrounded by whitespace
    is_valid = false
    reason = 'Multiple separator hyphens found'
  elsif (/-(?!.)/ =~ entry) # Check for missing right value
    is_valid = false
    reason = 'Missing right value'
  end

  return {
    :is_valid => is_valid,
    :reason   => reason
  }
end

bad_file = File.open("bad.txt", "w")
good_file = File.open("good.txt", "w")

current_video_id = -1
current_mix_songs = []
is_valid_mix = true

File.foreach(ARGV[0], sep: "\n") do |line|
  # Input validation
  if (line == "" || line == nil) then next end

  /^(?<video_id>\d+) % (?<song>.*$)/ =~ line
  if (song == "" || song == nil) then next end

  if current_video_id == -1 then current_video_id = video_id end
  if video_id != current_video_id
    #puts video_id
    if !is_valid_mix
      #puts "INVALID MIX"
      current_mix_songs.each do |current_song|
        bad_file.write("#{current_song[:value]}\n")
      end
    elsif
      current_mix_songs.each do |current_song|
        # puts "#{current_song[:value]}\n"
        good_file.write("#{current_song[:value]}\n")
      end
    end

    current_video_id = video_id
    current_mix_songs = []
    is_valid_mix = true
  end

  song_status = get_line_status(song)
  is_valid_mix &= song_status[:is_valid]
  formatted_song = "#{video_id} % #{song}"

  if song_status[:is_valid]
    formatted_song = "#{formatted_song}"
  else
    formatted_song = "#{formatted_song.strip}\t\t### #{song_status[:reason]}"
  end

  song_status[:value] = formatted_song
  current_mix_songs.push(song_status)
end

if (!is_valid_mix)
  current_mix_songs.each do |current_song|
    bad_file.write("#{current_song[:value]}\n")
  end
elsif
  current_mix_songs.each do |current_song|
    # puts "#{current_song[:value]}\n"
    good_file.write("#{current_song[:value]}\n")
  end
end

bad_file.close
good_file.close

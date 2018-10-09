#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

sql_file = "video_mix.sql"

def is_valid_song song
  if (song.scan(/ -[\n\ ]/).size == 0) # Check for missing hyphen
    false
  elsif (song.scan(/ - /).size > 1) # Check for multiple hyphens surrounded by whitespace
    false
  elsif (/-(?!.)/ =~ song) # Check for missing right value
    false
  elsif (/[\[\]]/ =~ song) # Check for brackets
    false
  elsif (/[\(\)]/ =~ song) # Check for parens
    false
  elsif (/[\t]/ =~ song) # Check for tabs
    false
  end

  true
end

def clean_song song
  song = song.split(/(?!<\s)- /)

  return {
    :artist => song[1],
    :title  => song[0]
  }
end

def process_songs raw_songs
  raw_songs.sub!(/^'/, "")
  raw_songs.sub!(/'$/, "")
  songs = raw_songs.split("\\n")

  valid_songs = []
  songs.each do |song|
    if is_valid_song song
      cleaned_song = clean_song(song)
      valid_songs.push(cleaned_song)
    end
  end

  return valid_songs
end

File.foreach(sql_file, sep: "\n") do |line|
  if (line == "\n") then next end

  # Clean up line
  line.sub!(/^\(/, "")
  line.sub!(/\);?,?$/, "")

  # Split line into tokens
  tokens = line.split(/(?<=\d|'), (?=\d|')/)
  
  if (tokens.size <= 4) then next end

  raw_songlist = tokens[4]
  songlist = process_songs(raw_songlist)

  video_id = tokens[0]

  songlist.each do |song|
    puts "('#{song[:artist]}', '#{song[:title]}', #{video_id}),"
  end
end

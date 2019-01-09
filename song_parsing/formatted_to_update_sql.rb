#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

def create_update_sql(video_id, video_mixes)
  flat_songlist = ""

  video_mixes.each do |mix|
    mix.gsub!(/\t\t###.*$/, "")
    mix.gsub!(/(?!=\ )-/, " -")
    mix.gsub!(/-(?!>\ )/, "- ")
    mix.gsub!(/\t/, " ")
    mix.gsub!(/\ \ +/, " ")
    mix.gsub!("â€“", "-")
    mix.gsub!(/^([A-Z\ ]+)$/, "_COMMENT_ - \\1")
    flat_songlist += "#{mix}\n"
  end

  return "UPDATE `video_mix` SET `song_list`=\"#{flat_songlist}\" WHERE `video_id`=#{video_id};"
end


current_id = -1
current_video_mixes = []

puts "START TRANSACTION;"
File.foreach(ARGV[0], sep: "\n") do |line|
  if (line == "" or line == nil) then next end

  /^(?<video_id>\d+) % (?<song>.*$)/ =~ line

  if video_id != current_id
    if current_video_mixes.size > 0
      puts create_update_sql(current_id, current_video_mixes)
    end

    current_id = video_id
    current_video_mixes = []
  end

  current_video_mixes.push(song)
end

if current_video_mixes.size > 0
  puts create_update_sql(current_id, current_video_mixes)
end

puts "COMMIT;"

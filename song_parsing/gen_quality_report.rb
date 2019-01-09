#!/usr/bin/ruby

def perform_query(query)
  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db -e \"#{query};\""
  `#{cmd}`
end


# Download SQL
result = perform_query("SELECT video_id, song_list FROM video_mix")

# Format SQL
formatted_songs_filename = "formatted_songs.txt"
formatted = File.open(formatted_songs_filename, "w")
result.each_line do |line|
  if /^\d+\t.*$/.match(line)
    video_id = line[/^(\d+)\t/, 1]
    raw_songs = line[/^\d+\t(.*)$/, 1]

    while raw_songs.include?("\\n")
      song = raw_songs[/^(.*?)\\n/, 1]
      raw_songs = raw_songs[/^.*?\\n(.*)$/, 1]

      formatted.write("#{video_id} % #{song}\n") unless song.strip.empty?
    end
  end
end

# Generate bad.txt
cmd = "./sorter.rb #{formatted_songs_filename}"
`#{cmd}`

# Slack bad.txt to Jay
cmd = "slack file upload bad.txt '#data-quality-reports'"
`#{cmd}`


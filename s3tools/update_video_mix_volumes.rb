#!/usr/bin/ruby

filename = ARGV[0]

# Process videoID / videoURL .csv file
puts "Processing input file..."

videos = []
File.foreach(filename) do |line|
  tokens = line.gsub('"', '').split(',')
  video_id = tokens[0].strip
  video_url = tokens[1].strip

  videos.push({ id: video_id, url: video_url })
end

# Loop over video mix .mp4's
tmp_filename = '/tmp/_mix_calc_volumes.mp4'
sql_filename = '/tmp/_update_mix_volumes.sql'

## Clear old .sql file
sql_file = File.open(sql_filename, 'w+')
sql_file.truncate(0)

videos.each do |video|
  # Download file locally
  puts "Downloading #{video[:url]}..."
  puts `curl -g "#{video[:url]}" > #{tmp_filename}`

  # Calculate volume data
  result = `./calculate_volume.rb #{tmp_filename}`
  avg_volume = result[/^.*?: (-?\d+\.\d+)/, 1]
  puts "Calculated average volume: #{avg_volume}"

  # Create UPDATE command
  unless avg_volume == nil or avg_volume.empty?
    puts "Adding update line"
    sql_file.write("UPDATE video_mix SET avg_volume='#{avg_volume}' WHERE video_id='#{video[:id]}';\n")
    sql_file.flush
  end
end

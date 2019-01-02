#!/usr/bin/ruby

filename = ARGV[0]
csv_filename = "/tmp/#{File.basename(filename, ".*")}.csv"

# Extract volume data
puts "Extracting volume data to #{csv_filename}..."
result = `ffprobe -f lavfi -i amovie=#{filename},astats=metadata=1:reset=1 -show_entries frame=pkt_pts_time:frame_tags=lavfi.astats.Overall.RMS_level -of csv=p=0 2> /dev/null 1> #{csv_filename}`

# Calculate volume data
volume_avg = 0
frames = 0

puts "Calculating average volume..."
File.foreach(csv_filename) do |line|
  tokens = line.split(",")
  timestamp = tokens[0].strip.to_f
  rms = tokens[1].strip.to_f

  volume_avg += rms
  frames += 1
end
volume_avg /= frames unless frames == 0

puts "Done!\n\n"
puts "Average RMS level in dBFS: #{volume_avg}"

#!/Users/alex/.rvm/rubies/ruby-2.5.3/bin/ruby

filename = ARGV[0]
simple_output = ARGV[1] != nil

cmd_input_filename = filename
  .gsub(" ", "\\ ")
  .gsub("'", "_SLASH_\\\\'")
  .gsub("_SLASH_", '\\\\\\\\\\\\\\\\\\\\\\\\')
cmd_output_filename = "/tmp/#{File.basename(filename, ".*")}.csv"
  .gsub(" ", "\\ ")
  .gsub("'", "\\\\'")

output_filename = "/tmp/#{File.basename(filename, ".*")}.csv"

# Extract volume data
puts "Extracting volume data to #{output_filename}..." unless simple_output
cmd = "ffprobe -f lavfi -i amovie=#{cmd_input_filename},astats=metadata=1:reset=1 -show_entries frame=pkt_pts_time:frame_tags=lavfi.astats.Overall.RMS_level -of csv=p=0 2> /dev/null 1> #{cmd_output_filename}"
result = `#{cmd}`

# Calculate volume data
volume_avg = 0
frames = 0

puts "Calculating average volume..." unless simple_output
File.foreach(output_filename) do |line|
  tokens = line.split(",")
  timestamp = tokens[0].strip.to_f
  rms = tokens[1].strip.to_f

  volume_avg += rms
  frames += 1
end
volume_avg /= frames unless frames == 0

if simple_output
  puts "#{File.basename(filename)}\n#{volume_avg}"
else
  puts "Done!\n\n"
  puts "Average RMS level in dBFS: #{volume_avg}"
end

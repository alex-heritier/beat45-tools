#!/Users/alex/.rvm/rubies/ruby-2.5.3/bin/ruby

filename = ARGV[0]

# Process videoID / videoURL .csv file
puts "Processing input file..."

videos = []
File.foreach(filename) do |line|
  tokens = line.gsub('"', '').split(',')
  video_id = tokens[0].strip
  video_url = tokens[1].strip

  videos.push({ id: video_url, url: video_url })
end

# Loop over video mix .mp4's
tmp_filename = '/tmp/_mix.mp4'

videos.each do |video|
  # Download file locally
  puts "Downloading #{video[:url]}..."
  result = `curl #{video[:url]} > #{tmp_filename}`

  # Calculate volume data
  result = `./calculate_volume.rb #{tmp_filename}`

  # Create UPDATE command
end

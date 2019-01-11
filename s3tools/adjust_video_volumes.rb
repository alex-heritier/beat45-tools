#!/usr/bin/ruby

filename = ARGV[0]

def perform_query(query)
  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db -e \"#{query};\""
  `#{cmd}`
end

def change_video_volume(in_file, out_file, amount)
	cmd = "ffmpeg -y -i \"#{in_file}\" -vcodec copy -b:a 314k -af \"volume=#{amount}dB\" \"#{out_file}\""
	`#{cmd}`
end

# Get all mix URLs
mix_infos = []

#=begin
File.foreach(filename) do |line|
  tokens = line.split(/\ *,\ */)
  video_id = tokens[0]

  puts "Getting video URL for #{video_id}..."
  query = "SELECT mix_path FROM video_mix WHERE video_id=#{video_id}"
  result = perform_query(query)
  abort "ERROR: Failed to load URL" if result.empty?

  mix_infos.push({
    video_id: video_id,
    volume_offset: tokens[1],
    url: result
  })
end

tmp_filename = "/tmp/_mix_adjust.mp4"
tmp_filename2 = "/tmp/__mix_adjust.mp4"

# Loop over mix URLs
mix_infos.each do |mix_info|
  # 	s3 download mix
  bucket_path = mix_info[:url][/^http.*?\.com\/(.*)$/, 1]
  puts "Downloading s3://#{bucket_path}..."
  cmd = "aws s3 cp \"s3://#{bucket_path}\" \"#{tmp_filename2}\""
  result = `#{cmd}`
  puts "Done!"

  #	update volume mix
  puts "Updating volume and saving to #{tmp_filename}..."
  change_video_volume(
    tmp_filename2,
    tmp_filename, 
    mix_info[:volume_offset]
  )
  puts "Done!"

  #	s3 upload mix with new name
  out_filename = "#{File.basename(bucket_path, ".mp4")}_x.mp4"

  puts "Uploading volume adjusted mix to S3..."
  cmd = "aws s3 cp \"#{tmp_filename}\" \"s3://beat45-test-bucket/mixes/#{out_filename}\" --acl public-read"
  result = `#{cmd}`
  puts "Done!"

  #	Calculate new average volume
  puts "Calculating new average volume..."
  cmd = "./calculate_volume.rb \"#{tmp_filename}\""
  result = `#{cmd}`
  new_volume = result[/^.*?: (-?\d+\.\d+)/, 1]
  puts "Done!"

#	DB update mix_path & avg_volume & status
  puts "Updating DB values..."
  File.write("/tmp/_adjust_query.sql", "UPDATE video_mix SET status='P', avg_volume='#{new_volume}', mix_path='https://s3-us-west-1.amazonaws.com/beat45-test-bucket/mixes/#{out_filename.gsub("'", "''")}' WHERE video_id=#{mix_info[:video_id]}")

  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db < /tmp/_adjust_query.sql"
  result = `#{cmd}`
  puts "Done!"
end

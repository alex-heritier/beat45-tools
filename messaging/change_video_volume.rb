#!/usr/bin/env ruby

require 'json'
require 'securerandom'

VIDEO_ID = ARGV[0]
VOLUME_CHANGE = ARGV[1]
abort("ERROR: Invalid input") unless VIDEO_ID && VOLUME_CHANGE

def perform_query(query)
  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db -e \"#{query};\""
  puts cmd
  `#{cmd}`
end

def change_video_volume(in_file, out_file, amount)
  cmd = "ffmpeg -y -i \"#{in_file}\" -vcodec copy -b:a 314k -af \"volume=#{amount}dB\" \"#{out_file}\""
  `#{cmd}`
end

tmp_filename = "/tmp/_#{SecureRandom.uuid}_change_video_volume.mp4"
tmp_filename2 = "/tmp/__#{SecureRandom.uuid}_change_video_volume.mp4"

begin

  # Get video mix URL from DB
  puts "Getting video URL for #{VIDEO_ID}..."
  query = "SELECT mix_path FROM video_mix WHERE video_id=#{VIDEO_ID}"
  puts query
  result = perform_query(query)
  puts result
  abort "ERROR: Failed to load URL" if result.empty?

  # 	s3 download mix
  bucket_path = result[/^http.*?\.com\/(.*)$/, 1]
  puts "Downloading s3://#{bucket_path}..."
  cmd = "aws s3 cp \"s3://#{bucket_path}\" \"#{tmp_filename2}\""
  result = `#{cmd}`
  puts "Done!"

  #	update volume mix
  puts "Updating volume and saving to #{tmp_filename}..."
  change_video_volume(
    tmp_filename2,
    tmp_filename, 
    VOLUME_CHANGE
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
  cmd = "../s3tools/calculate_volume.rb \"#{tmp_filename}\""
  result = `#{cmd}`
  new_volume = result[/^.*?: (-?\d+\.\d+)/, 1]
  puts "Done!"

  #	DB update mix_path & avg_volume & status
  puts "Updating DB values..."
  File.write("/tmp/_adjust_query.sql", "UPDATE video_mix SET status='P', avg_volume='#{new_volume}', mix_path='https://s3-us-west-1.amazonaws.com/beat45-test-bucket/mixes/#{out_filename.gsub("'", "''")}' WHERE VIDEO_ID=#{VIDEO_ID}")

  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db < /tmp/_adjust_query.sql"
  result = `#{cmd}`
  puts "Done!"
ensure
  puts "Cleaning up temporary files..."
  File.delete(tmp_filename) if File.exist?(tmp_filename)
  File.delete(tmp_filename2) if File.exist?(tmp_filename2)
  puts "Done!"
end

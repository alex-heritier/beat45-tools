#!/usr/bin/ruby

filename = ARGV[0]

def perform_query(query)
  cmd = "mysql -u root -h beat45.com -p'Zse45tgb' -P 3306 -D beat45db -e \"#{query};\""
  `#{cmd}`
end

def change_video_volume(in_file, out_file, amount)
  cmd = "ffmpeg -y -i #{in_file} -vcodec copy -b:a 314k -af \"volume=#{amount}dB\" #{out_file}"
  `#{cmd}`
end

# Get all mix URLs
mix_infos = []

#=begin
File.foreach(filename) do |line|
  tokens = line.split(",")
  video_id = tokens[0]

  puts "Getting video URL for #{video_id}..."
  query = "SELECT mix_path FROM video_mix WHERE video_id=#{video_id}"
  result = perform_query query
  return if result.empty?

  mix_infos.push({
    video_id: video_id,
    volume_offset: tokens[1],
    url: result
  })
end
#=end

=begin
mix_infos = [
  {
    video_id: 1,
    volume_offset: 11.87,
    url: "https://s3-us-west-1.amazonaws.com/beat45-test-bucket/mixes/210_BB45M7-658e3032c5c0a1a48d598eae41617edf.mp4"
  }
]
=end

tmp_filename = "/tmp/_mix.mp4"

# Loop over mix URLs
mix_infos.each do |mix_info|
  # 	s3 download mix
  bucket_path = mix_info[:url][/^http.*?\.com\/(.*)$/, 1]
  puts "Downloading s3://#{bucket_path}..."
  cmd = "aws s3 cp s3://#{bucket_path} #{tmp_filename}"
  result = `#{cmd}`
  puts "Done!"

  #	update volume mix
  out_filename = "/tmp/#{File.basename(bucket_path, ".mp4")}_x.mp4"
  puts "Updating volume and saving to #{out_filename}..."
  change_video_volume(
    tmp_filename,
    out_filename, 
    mix_info[:volume_offset]
  )
  puts "Done!"

  #	s3 upload mix with new name
  puts "Uploading volume adjusted mix to S3..."
  cmd = "aws s3 cp #{out_filename} s3://beat45-test-bucket/mixes/#{out_filename} --acl public-read"
  result = `#{cmd}`
  puts "Done!"

  #	Calculate new average volume
  puts "Calculating new average volume..."
  cmd = "./calculate_volume.rb #{out_filename}"
  result = `#{cmd}`
  new_volume = result[/^.*?: (-?\d+\.\d+)/, 1]
  puts "Done!"

  #	DB update mix_path & avg_volume
  puts "Updating DB values..."
  perform_query "UPDATE video_mix SET avg_volume='#{new_volume}', mix_path='https://s3-us-west-1.amazonaws.com/beat45-test-bucket/mixes/#{out_filename}' WHERE video_id=#{mix_info[:video_id]}"
  puts "Done!"
end

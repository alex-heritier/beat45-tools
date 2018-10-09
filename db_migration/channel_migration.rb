#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

sql_file = "channels.sql"

def fix_tokens tokens
  fixed_tokens = []

  fixed_tokens[0] = tokens[2]
  fixed_tokens[2] = tokens[0]

  fixed_tokens[1] = "'channel'"
  fixed_tokens[3] = "'beta'"
  fixed_tokens[4] = 0
  fixed_tokens[5] = "'context'"
  fixed_tokens[6] = tokens[10]

  return fixed_tokens
end

File.foreach(sql_file, sep: "\n") do |line|
  if (line == "\n") then next end

  # Clean up line
  line.sub!(/^\(/, "")
  line.sub!(/\);?,?$/, "")

  # Split line into tokens
  tokens = line.split(/(?<=\d|'), (?=\d|')/)#"', '")

  tokens = fix_tokens(tokens)

  if (tokens.size != 7)
    puts "tokens.size == #{tokens.size}"
    puts tokens
    exit
  end

  new_line = tokens.join(", ")
  new_line.tr!("\n", "")
  new_line = "(" + new_line
  new_line += "),"

  puts new_line
end

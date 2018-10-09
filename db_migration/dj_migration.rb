#!/Users/alex/.rvm/rubies/ruby-2.5.1/bin/ruby

sql_file = "djs.sql"

def fix_tokens tokens
  fixed_tokens = []

  fixed_tokens[0] = tokens[0]
  fixed_tokens[1] = tokens[6]
  fixed_tokens[2] = tokens[7]
  fixed_tokens[3] = "'_country'"
  fixed_tokens[4] = tokens[13]
  fixed_tokens[5] = "'_label_crew'"
  fixed_tokens[6] = "'_bio'"

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

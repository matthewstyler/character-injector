#!/usr/bin/env ruby
require 'optparse'

OPTIONS = {}
at_least_one_option_required = [:append, :prepend]
required_option = [:split]

OptionParser.new do |parser|
  parser.banner = "Usage: char_inject.rb [options]"
  parser.on("-h", "--help", "Show this help message") { puts parser }
  parser.on("-p", "--prepend STRING,NUM_TIMES", Array, "String to prepend to source after split") { |val| OPTIONS[:prepend] = val }
  parser.on("-a", "--append STRING,NUM_TIMES", Array, "String to append to source after split") { |val| OPTIONS[:append] = val }
  parser.on("-s", "--split STRING", "String to split on") { |val| OPTIONS[:split] = val }
  parser.on("-d", "--debug", "Prints Debug Information") { |val| OPTIONS[:debug] = val }
  parser.on("--prompt", "Prompt for source") { |val| OPTIONS[:prompt] = val }
  parser.on("-c", "--colourize", "Colourize Output") { |val| OPTIONS[:colorize] = val }
end.parse!

raise ArgumentError, "At least one option of #{at_least_one_option_required} required" if (at_least_one_option_required & OPTIONS.keys).empty?
raise ArgumentError, "Required #{required_option}" unless OPTIONS[:split]

def debug_string(string)
  puts colorize(string, :blue) if OPTIONS[:debug]
end

class String
  def red; "\e[31m#{self}\e[0m" end
  def green; "\e[32m#{self}\e[0m" end
  def blue; "\e[34m#{self}\e[0m" end
  def magenta; "\e[35m#{self}\e[0m" end
end

def colorize(string, color)
  OPTIONS[:colorize] ? string.public_send(color) : string
end

debug_string "Options #{OPTIONS}"

if OPTIONS[:prompt]
  puts colorize("Enter Source String (End: \\t\\n)", :red)
  source = gets("\t\n").chomp[0..-'\t'.size]
else
  source = ARGF.read.chomp
end

debug_string "Source: #{source}"

split_source = source.split(OPTIONS[:split])
debug_string "Split Source #{split_source}"

prepend = OPTIONS[:prepend]
append = OPTIONS[:append]

def alter_string(string, index, option)
  string = yield(string) if option && (option.size == 1 || index < option[1].to_i)
  string
end

split_source = split_source.map.with_index do |string, index|
  debug_string "#{string}#{index}"
  string = alter_string(string, index, prepend) { colorize(prepend.first, :green) + colorize(string, :magenta) }
  string = alter_string(string, index, append) { colorize(string, :magenta) + colorize(append.first, :green) }
  debug_string string
  string
end

puts split_source.join(OPTIONS[:split])
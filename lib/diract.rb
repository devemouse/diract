#!/usr/bin/env ruby

require 'yaml'
require 'pp'
require 'trollop'

RED      = "1;31"
GREEN    = "32"
YELLOW   = "33"

unless RUBY_PLATFORM.include?('linux')
   begin
      require 'Win32/Console/ANSI' #if RUBY_PLATFORM =~ /win32/
   rescue LoadError
      raise 'You must gem install win32console to use color on Windows'
   end
end

class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

class Array
  def to_hash_keys(&block)
    Hash[*self.collect { |vector|
      [vector, block.call(vector)]
    }.flatten]
  end

  def to_hash_values(&block)
    Hash[*self.collect { |vector|
      [block.call(vector), vector]
    }.flatten]
  end
end

# Diract class contains all functionality of diract app
class Diract
   DEFAULT_CFG = File.join(ENV['HOME'], '.diract.conf')

   def initialize(fname = DEFAULT_CFG)
      @conf = load_conf(fname)
      @entries = Hash.new
   end

   def delete(entries)
      pp entries if $DEBUG
      list if @entries.empty?
      pp @entries if $DEBUG
      pp entries.map { |el| @entries.has_key?(el) ? el : nil}.compact if $DEBUG
   end

   def list
      out = ""
      dir_index = 'a'
      @conf.each do |line|
         out << rec_listdir(line.chomp, dir_index) << "\n"
         dir_index.next! 
      end
      out
   end

   def load_conf(fname = DEFAULT_CFG)
      if File.exists?(fname) then
         file = File.new(fname,"r")
      else
         file = File.new(fname,"w+")
      end
      file
   end


   def rec_listdir(directory, dir_index)
      out = ""
      old_dr = Dir.pwd
      if File.directory?(directory)
         #Dir.chdir(directory)
         files_in_dir = Dir[File.join(directory, '*')].map {|el| File.basename(el)}
         described = Hash.new
         dot_diract = File.join(directory, '.diract')
         dot_diract_exists = File.exists?(dot_diract)

         if files_in_dir.empty?
            File.delete(dot_diract) if dot_diract_exists
         else
            key_width = files_in_dir.max_by {|el| el.length }.length

            out << "\n"
            out << "==== (" + dir_index.color(YELLOW) + ') ' + directory.color(RED) + " ====\n"
            if dot_diract_exists

               described = files_in_dir.sort.to_hash_keys{nil}.merge(YAML::load_file(dot_diract)).delete_if {|key,val| !files_in_dir.include?(key)}

            else
               described = files_in_dir.sort.to_hash_keys{nil}
               File.open(dot_diract, 'w' ) do |out|
                  YAML.dump( described, out )
               end
            end

            described.each_with_index do |pair, index|
               index_str = index.to_s
               out << "%#{key_width+11}s (%#{described.length+2}s): %s\n" % [pair[0].color(GREEN), index_str.color(YELLOW),  pair[1]]
               @entries[dir_index + index_str] = pair[0]
            end

            File.open(dot_diract, 'w' ) do |out|
               YAML.dump( described, out )
            end
         end
      end
      out
   end
end


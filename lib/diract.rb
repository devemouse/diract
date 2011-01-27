#!/usr/bin/env ruby

require 'yaml'
require 'pp'

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

#String extended by coloring output
class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

#Array is extended by Array to hash converters
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
      if File.exists?(fname) then
         file = File.new(fname,"r")
      else
         file = File.new(fname,"w+")
      end
      @conf = file.map {|el| el.chomp}
      file.close
      @entries = Hash.new
   end

   def delete(entries)
      list if @entries.empty?

      if entries.is_a?(Enumerable)
      else
         file_to_remove = @entries[entries]
         full_path = file_to_remove[:file]
         if File.exists?(full_path)
            FileUtils.remove_entry_secure full_path, true
         end
         File.basename(full_path).to_s + ': ' + file_to_remove[:desc].to_s
      end
   end

   def list
      dir_indexes = ('a'..'z').to_a
      memo = ""

      @conf.each_with_index do |line,index|
         memo << rec_listdir(line, dir_indexes[index]) << "\n"
      end

      memo
   end

   def dot_diract(directory)
      files_in_dir = Dir[File.join(directory, '*')].map {|el| File.basename(el)}

      described = nil
      dot_diract = File.join(directory, '.diract')
      dot_diract_exists = File.exists?(dot_diract)

      if files_in_dir.empty?
         File.delete(dot_diract) if dot_diract_exists
      else
         described = files_in_dir.sort.to_hash_keys{nil}
         if dot_diract_exists
            described.merge!(YAML::load_file(dot_diract)).delete_if{|key,val| !files_in_dir.include?(key)}
         end

         File.open(dot_diract, 'w' ) do |out|
            YAML.dump( described, out )
         end
      end
      described
   end

   def rec_listdir(directory, dir_index)
      out = ""
      old_dr = Dir.pwd
      if File.directory?(directory)
         if described = dot_diract(directory)

            key_width = files_in_dir.max_by {|el| el.length }.length

            out << "\n"
            out << "==== (" + dir_index.color(YELLOW) + ') ' + directory.color(RED) + " ====\n"

            described.each_with_index do |pair, index|
               index_str = index.to_s
               out << "%#{key_width+11}s (%#{described.length+2}s): %s\n" % [pair[0].color(GREEN), index_str.color(YELLOW),  pair[1]]
               @entries[dir_index + index_str] = {:file => File.join(directory, pair[0]), :desc => pair[1] }
            end
         end

      end
      out
   end
end


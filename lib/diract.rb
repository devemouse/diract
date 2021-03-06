#!/usr/bin/env ruby

require 'yaml'
#require 'pp'
require 'fileutils'

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

#Hash is expanded by methods needed to operate on entries in .diract files
class Hash
   def remove(item)
      item_to_remove = self.delete(item)
      full_path = item_to_remove[:file]

      begin
         FileUtils.remove_entry_secure full_path
         File.basename(full_path).to_s + ': ' + item_to_remove[:description].to_s
      rescue
         nil
      end
   end

   def save(direcory)
      File.open(File.join(direcory, '.diract'), 'w' ) do |out|
         YAML.dump( self[direcory], out )
      end
   end
end

# Diract class contains all functionality of diract app
class Diract
   DEFAULT_CFG = File.join(ENV['HOME'], '.diractrc')

   def initialize(fname = DEFAULT_CFG)
      if File.exists?(fname) then
         file = File.new(fname,"r")
      else
         file = File.new(fname,"w+")
      end
      @conf = file.map {|el| el.chomp}
      file.close
      @lookup_table = Hash.new
      @described_files = Hash.new
   end

   def delete(*entries)
      list if @lookup_table.empty?
      entries.map {|entry| @lookup_table.remove(entry)}
   end

   def describe(entry, description = '')
      list if @lookup_table.empty?
      entry_to_describe = @lookup_table[entry]
      entry_to_describe[:description] = description
      file = entry_to_describe[:file]

      @described_files[File.dirname(file)][File.basename(file)] = description
      @described_files.save File.dirname(file)

      "%s: %s" % [File.basename(file), description]
   end

   def list
      dir_indexes = ('a'..'z').to_a
      memo = ""

      @conf.each_with_index do |line,index|
         memo << list_dir(line, dir_indexes[index]) << "\n"
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

   def list_dir(directory, dir_index)
      out = ""
      if File.directory?(directory)
         if @described_files[directory] = dot_diract(directory)

            key_width = @described_files[directory].max_by {|key, value| key.length }[0].length

            out << "\n"
            out << "==== (" + dir_index.color(YELLOW) + ') ' + directory.color(RED) + " ====\n"

            @described_files[directory].each_with_index do |pair, index|
               index_str = index.to_s
               filename = pair[0]
               description = pair[1]
               out << "%#{key_width+11}s (%#{@described_files[directory].length+2}s): %s\n" % [filename.color(GREEN), index_str.color(YELLOW),  description]
               @lookup_table[dir_index + index_str] = {:file => File.join(directory, filename), :description => description }
            end
         end

      end
      out
   end
end


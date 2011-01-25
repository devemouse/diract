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
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end

  def to_hash_values(&block)
    Hash[*self.collect { |v|
      [block.call(v), v]
    }.flatten]
  end
end

class Diract
   attr_accessor :debug

   def initialize(fname = "diract.conf")
      @conf = load_conf(fname)
      @entries = Hash.new
   end

   def delete(entries)
      pp entries
      list if @entries.empty?
      pp @entries
      pp entries.map { |el| @entries.has_key?(el) ? el : nil}.compact
   end

   def list
      out = ""
      dir_index = 'a'
      @conf.each do |line|
         out << rec_listdir(line.chomp, dir_index)
         out << "\n"
         dir_index.next! 
      end
      out
   end

   def load_conf(fname = "diract.conf")
      if File.exists?(fname) then
         file = File.new(fname,"r")
      else
         print 'Config does not exist. Creating...'
         file = File.new(fname,"w+")
         file.puts "c:\\Darek\\@Action\\"
         file.rewind
         puts 'Done.'
      end
      file
   end


   def rec_listdir(directory, dir_index)
      out = ""
      old_dr = Dir.pwd
      if File.directory?(directory)
         #Dir.chdir(directory)
         files_in_dir = Dir[File.join(directory, '*')]
         described = Hash.new

         if files_in_dir.empty?
            File.delete('.diract') if File.exists?('.diract')
         else
            key_width = files_in_dir.max_by {|x| x.length }.length

            out << "\n"
            out << "==== (" + dir_index.color(YELLOW) + ') ' + directory.color(RED) + " ====\n"
            if File.exists?('.diract')
               #puts '.diract exists'

               described = YAML::load_file('.diract')
               #print 'described before changes: '
               #pp described

               described = files_in_dir.sort.to_hash_keys{nil}.merge(described)

               #print 'merged hash: '
               #pp described

               described.delete_if {|key,val| !files_in_dir.include?(key)}

               #print 'files after removal: '
               #pp described

            else
               items_H = files_in_dir.sort.to_hash_keys{nil}
               File.open( '.diract', 'w' ) do |out|
                  YAML.dump( items_H, out )
               end
               described = items_H
            end

            described.each_with_index do |pair, i|
               out << "%#{key_width+11}s (%#{described.length+2}s): %s\n" % [pair[0].color(GREEN), (i+1).to_s.color(YELLOW),  pair[1]]
               @entries[dir_index + (i+1).to_s] = pair[0]
            end

            File.open( '.diract', 'w' ) do |out|
               YAML.dump( described, out )
            end
         end
      end
      out
   end
end


#!/usr/bin/ruby

###========================================================================###
#
#     Author: David Billsbrough <billsbrough@gmail.com>
#    Created: Thursday, May 07, 2015 at 13:09:46 PM (EDT)
#    License: GNU General Public License -- version 2
#   Warranty: None
#    Version: $Revision: 0.2 $
#
#    Purpose: Convert an Elm address book for use with the Trojita imap client
#
#   $Id: elm2trojita.rb,v 0.2 2015/05/07 17:29:05 kc4zvw Exp kc4zvw $
#
###========================================================================###
# vim: tabstop=4:expandtab:shiftwidth=4:syntax=ruby:

def get_home_dir
	myHOME = ENV["HOME"]
	print "My $HOME directory is #{myHOME}.\n"
	return myHOME
end

def get_timestamp
	""" Date Format: 04-16-2006 at 17:57:11 """
	tm = Time.now
	return sprintf("%02d-%02d-%04d at %02d:%02d:%02d",
		tm.mon, tm.mday, tm.year, tm.hour, tm.min, tm.sec)
end

###------------------------------------------------------------------------###

def delete_comment (name, pos)
	return name[0, pos]
end

def get_firstname (name, pos)
	return name[pos + 2, 99]
end

def get_lastname (name, pos)
	return name[0, pos]
end

def get_fullname (first_name, last_name)
	return "#{first_name} #{last_name}"
end

###------------------------------------------------------------------------###

def display_entry(full_name)
	puts "Converting '#{full_name}'   (#{$.})"
end

def write_header(i, output)
	index = i - 1
	output.print "[#{index}]\n"
end

def write_trojita(myalias, first, last, email, output)

	fullname = get_fullname(first, last)

	output.print "name=#{fullname}\n"
	output.print "email=#{email}\n"
	output.print "address=[address]\n"
	output.print "city=[city]\n"
	output.print "state=[state]\n"
	output.print "zip=[zip]\n"
	output.print "country=USA\n"
	output.print "phone=n/a\n"
	output.print "workphone=\n"
	output.print "fax=\n"
	output.print "mobile=\n"
	output.print "nick=#{myalias}\n"
	output.print "url=\n"
	output.print "anniversary=none\n"
	output.print "\n"
end

###------------------------------------------------------------------------###

def process_line(output, aline, index)

	pos1 = pos2 = nil
	myalias = name = email = ""
	first = last = ""

	line = aline.chomp

	myalias, name, email = line.split(' = ')

	pos1 = name.index(',')                # search for a comma
	pos2 = name.index(';')                # search for a semicolon

	if pos1 != nil then
		#print "Comma at #{pos1}.\n"
		name = delete_comment(name, pos1)
	end

	if pos2 != nil then
		#print "Semicolon at #{pos2}.\n"
		first = get_firstname(name, pos2)
		last = get_lastname(name, pos2)
		name = get_fullname(first, last)
	end

	display_entry(name)                   # Display progress
	write_header(index, output)
	write_trojita(myalias, first, last, email, output)	# Write single entry
end

###---------------------------- Main Routine ------------------------------###

home = get_home_dir

elm_path = [ home, ".elm", "aliases.text" ]
output_path = [ home, ".abook", "address_book_2" ]

elm = elm_path.join("/")
addressbook = output_path.join("/")

puts
puts "The Elm mail alias file is #{elm}."
puts "The trojita address book file is #{addressbook}."
puts

begin
	input = File.open(elm, mode='r')
rescue
	puts "Can not read input mail aliases."
	puts "#{$!}"
	exit 1
end

begin
	output = File.open(addressbook, mode='w')
rescue
	puts "Can not write output address book."
	puts "#{$!}"
	exit 2
end

until input.eof()
	line = input.readline
	process_line(output, line, $.)
end

input.close
output.close

datestamp = get_timestamp
record_count = $.

puts
print "processed #{record_count} records on #{datestamp}.\n"
puts
puts "Finished."

# End of Program

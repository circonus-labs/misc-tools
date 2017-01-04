#!/usr/local/bin/ruby

# Circonus, Inc
# version 0.00001
# Adjust this as appropriate for your platform
#
# This relies on ruby-snmp rather than
# running shell commands.
#
# This script is intended to work for most switches, YMMV
# It will walk the subtree of the ifTable object and
# Return results than can then be used to create a
# check within Circonus.  This tool will spit out a
# json file that can be used with a separate tool
# to create check.  You may then edit and reuse the json if
# you have a lot of the same model devices.
#
# Sorry for this code - pjy

require 'snmp'
include SNMP

# Command Line Arguments
host = ARGV[1]
community = ARGV[0]

# Set properties for probing a device
manager = Manager.new(:Host => host, :Port => 161, :community => community)
ifTable = ObjectId.new("1.3.6.1.2.1.2.2.1")
next_oid = ifTable
numports = 0
properties = 0
portlist = Array.new
property = Array.new
uniqueprop = Array.new
while next_oid.subtree_of?(ifTable)
  response = manager.get_next(next_oid)
  varbind = response.varbind_list.first
  next_oid = varbind.name
  fulloid = next_oid.join(".")
  if varbind.name.to_s =~ /ifDescr/
    numports += 1
    portidpre = varbind.name.to_s.tr('IF-MIB::ifDescr.','')
    portid = portidpre.tr('-','')
#    puts numports
    portlist[numports] = [portid,varbind.value.to_s]
  end
  nameport = varbind.name.to_s.tr('IF-MIB::-','')
  nameport = nameport.split(".")
  properties += 1
  property[properties] = [nameport[0],nameport[1],fulloid]
  uniqueprop[properties] = nameport[0]
  #puts "#{varbind.name.to_s.tr('IF-MIB::-','')}  #{varbind.value.to_s}  #{varbind.value.asn1_type}"
end

uniqueprop.uniq.each do |snowflake|
  unless snowflake.nil?
    puts "#{snowflake}"
  end
end

# Show ports found
portlist.each do |portlist|
  puts "This is a port I found: #{portlist}"
end


#puts properties
property.each do |proplist|
  puts "Here is some properties: #{proplist}"
end


# save this nugget for later: .gsub(/[^\d,\.]/, '')

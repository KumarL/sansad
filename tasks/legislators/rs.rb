require 'curb'
require 'nokogiri'
require '../utils.rb'
require 'yaml'

def self.get_bio_url(id)
  return "http://164.100.47.5/AndroidFeeds/member_biography.aspx?member_id=#{id.to_s}"
end

mp_ids = {}

for mp_id in 1..5000
  puts "Querying mp_id = #{mp_id}"
  xml_doc = Nokogiri::XML (Utils.curl get_bio_url(mp_id))
  name = (xml_doc.css 'MemberName').text
  if ("" == name)
    next
  end
  # remove the title
  name = name.split(' ')[1..-1].join(' ')
  mp_ids[name] = mp_id
  puts "Added mp_id = #{mp_id}"
end

File.open('mp_rs_ids.yml', 'w') {|f| f.write mp_ids.to_yaml}

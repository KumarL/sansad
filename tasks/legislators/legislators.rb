require 'spreadsheet'
require 'digest'

class Legislators

  # options:
  #   cache: don't re-download unitedstates data
  #   current: limit to current legislators only
  #   limit: stop after N legislators
  #   clear: wipe the db of legislators first
  #   bioguide_id: limit to one legislator, with this bioguide ID

  def self.run(options = {})

    # 1. Download the excel file
    # 2. Compute checksum and exit if it's same as the last download
    # 3. If not, update the db
    lsbook_url = "http://www.prsindia.org/MPTrack-16.xls"
    rsbook_url = "http://www.prsindia.org/Rajya.xls"

    legislator_urls = {"Lok Sabha" => lsbook_url, "Rajya Sabha" => rsbook_url}

    bad_legislators = []
    count = 0

    legislator_urls.keys.each do |chamber|
      mpbook_path = "download/#{chamber.gsub(/\s+/, "")}New.xlx"
      File.delete mpbook_path if File.exists? mpbook_path

      book_url = legislator_urls[chamber]

      result = Utils.curl book_url, mpbook_path
      if result.nil? or '200 OK' != result.status
        puts "Couldn't download the MP file. The url #{book_url} returned with status #{result.status}" 
        next
      end

      # Check if the newly downloaded file is same as the last download
      mpbook_old_path = "download/#{chamber.gsub(/\s+/, "")}.xlx"
      if (File.exists? mpbook_old_path)
	      old_file = File.new mpbook_old_path
	      new_file = File.new mpbook_path

	      old_chksum = Digest::SHA2.file(old_file).hexdigest
	      new_chksum = Digest::SHA2.file(new_file).hexdigest

	      if (old_chksum == new_chksum) # If the downloaded file is bit indentical to last download
	        File.delete mpbook_path
	        next
	      end
      end

	    # If you are here, that means we want to work with the newly downloaded file
      # First step - Rename it to the new with the "old" file, overriding if needed
	    File.rename(mpbook_path,mpbook_old_path)
      book = Spreadsheet.open mpbook_old_path
      sheet1 = book.worksheet 0 # Access the first worksheet
      is_first = true
      sheet1.each do |row|

        if (is_first)
          is_first = false
          next # Ignore the header row
        end

        attributes_new = attributes_from_prs row, chamber
        legislator = Legislator.find_or_initialize_by bioguide_id: attributes_new[:bioguide_id]
        legislator.attributes = attributes_new

        if legislator.save
          count += 1
        else
          bad_legislators << {attributes: legislator.attributes, errors: legislator.errors.full_messages}
        end
      end
    end

#    We will revisit this code later. We're fine for now.

#    lsmembers_url = 'http://164.100.47.132/LssNew/Members/Alphabaticallist.aspx'
#    doc = Utils.html_for lsmembers_url
#    puts 'Failed to parse HTML document of LokSabha page'; return if doc.nil?
#
#    rows = doc.css 'table#ctl00_ContPlaceHolderMain_Alphabaticallist1_dg1 > tr'
#    rows.each do |row|
#      tds = row.css 'td.griditem'
#      next unless 4 == tds.count
#      bio_link = URI.join lsmembers_url, (tds[0].css 'a').first()['href']
#      bio_link = URI::join lsmembers_url, bio_link #Ensures that relative links are absolute links
#      mp_id = bio_link[(bio_link.rindex('=')+1)..-1]
#
#      bio_doc = Utils.html_for bio_link
#      titledName = (bio_doc.css 'table#ctl00_ContPlaceHolderMain_Bioprofile1_Datagrid1 td.gridheader1').text
#      last_name, first_name = titledName.split ','
#      title, first_name = first_name.split ' '
#      first_name = (first_name.split ' ')[1..-1].join ' ' if first_name.start_with? '('
#
#    end
#
    if bad_legislators.any?
      Report.warning self, "Failed to save #{bad_legislators.size} PRS LS legislators.", bad_legislators: bad_legislators
    end

    Report.success self, "Processed #{count} legislators from PRS"
  end

  def self.attributes_from_prs(row, house)
    name_index = 0
    elected_index = 1
    term_start_index = 2
    term_end_index = 3
    state_name_index = 4
    constituency_index = 5
    party_index = 6
    gender_index = 7
    education_qualification_index = 8
    education_details_index = 9
    age_index = 10
    debates_index = 11
    private_bills_index = 12
    questions_index = 13
    attendance_index = 14
    notes_index = 15

    first_name, last_name = Utils.split_fullname row[name_index]
    elected = row[elected_index].downcase.eql? 'Elected'.downcase
    in_office = true # We're only querying the current session of the parliament

    attributes = {
      bioguide_id: row[name_index] + '_' + row[state_name_index],
      first_name: first_name.to_s,
      last_name: last_name.to_s,
      gender: row[gender_index],
      age: row[age_index].to_i.to_s,
      state: row[state_name_index],
      constituency: row[constituency_index].to_s,
      party: row[party_index],
      elected: elected,
      in_office: in_office,
      education_qualification: row[education_qualification_index],
      education_details: row[education_details_index],
      debates: row[debates_index],
      private_bills: row[private_bills_index],
      questions: row[questions_index],
      attendance: (row[attendance_index] * 100).to_i.to_s,
      notes: row[notes_index],
      chamber: house,
      term_start: row[term_start_index].to_s,
      term_end: row[term_end_index].to_s
    }

    attributes # return attributes
  end

  def self.party_for(us_party)
    {
      'Democrat' => 'D',
      'Republican' => 'R',
      'Independent' => 'I'
    }[us_party] || us_party
  end

  def self.social_media_from(details)
    facebook = details['social']['facebook_id'] || details['social']['facebook']
    facebook = facebook.to_s if facebook
    {
      twitter_id: details['social']['twitter'],
      youtube_id: details['social']['youtube'],
      facebook_id: facebook
    }
  end

  def self.terms_for(us_legislator)
    us_legislator['terms'].map do |original_term|
      term = original_term.dup

      # these go on the top level and are only correct for the current term
      ['phone', 'fax', 'url', 'address', 'office', 'contact_form'].each {|field| term.delete field}

      type = term.delete 'type'
      # override for non-voting members
      if term['state'] == "PR"
        type = "com"
      elsif ["VI", "MP", "AS", "GU", "DC"].include?(term['state'])
        type = "del"
      end

      term['party'] = party_for term['party']
      term['title'] = type.capitalize

      term['chamber'] = {
        'rep' => 'house',
        'sen' => 'senate',
        'del' => 'house',
        'com' => 'house'
      }[type]

      term
    end
  end
end

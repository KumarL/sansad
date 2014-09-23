require 'docsplit'
require 'uri'
#require 'pry-remote'

class Bills

  # options:
  #   congress: The congress to update.
  #   bill_id: The particular bill to update. Useful for development.
  #   limit: A limit on the number of processed bills. Useful for development.

  def self.run(options = {})
    count = 0
    bad_bills = []
    @billtrack_url = 'http://www.prsindia.org/billtrack'

    html_doc = Utils.html_for @billtrack_url
    
    if (html_doc.nil?)
      Report.failure self, "Nokogiri failed to parse the HTML content of the bill track web page"
      return
    end

    rows_selector = 'div.content > form > div > table > tr[onclick]'
    rows = html_doc.css rows_selector

    if (0 == rows.count)
      Report.failure self, "Failed to find any rows in the table of the bills. Returning."
      return
    end

    #rows belong to a table that contains a list of the bills
    rows.each do |row|

      if (options[:limit] and count >= options[:limit].to_i)
        break
      end

      bill = create_bill row

      if bill.save
        count += 1
        puts "[#{bill.bill_id}] Saved successfully" if options[:debug]
      else
        bad_bills << {attributes: bill.attributes, error_messages: bill.errors.full_messages}
        puts "[#{bill_id}] Error saving, will file report"
      end

    end
  end

  def self.create_bill(billtrack_row)
    # initialize bill by bill_id
    # get attributes from the billtrack_row
    
    col_vals = billtrack_row.css('td')

    #first columns points to the bill title
    #second column gives the status
    #third column gives the links to the bill text and the summary

    if (col_vals.count != 3)
      return nil
    end

    title, ministry, introduced_on, summary, ls_status, rs_status, bill_url, com_ref, com_rep, last_action, last_action_at = bill_details(col_vals[0])
    last_action_at = nil if Date.civil == last_action_at
    bill_id = title # We'd make title of the bill as its id if we cannot find its number

    status = bill_status(col_vals[1])
    bill_text_filepath = bill_text(col_vals[2])
    text = ''
    if (bill_text_filepath.nil?)
      puts "Failed to extract text of the bill."
      text = ''
    else
      text = File.read(bill_text_filepath)
      bill_id, introduced_by = read_bill_text bill_text_filepath
      File.delete(bill_text_filepath)
    end

    # Now start creating a bill object that can be returned to the caller
    bill = Bill.find_or_initialize_by bill_id: bill_id

    bill.attributes = {
      title: title,
      status: status,
      ministry: ministry.to_s,
      introduced_on: introduced_on.to_s,
      ls_status: ls_status.to_s,
      rs_status: rs_status.to_s,
      com_ref: com_ref.to_s,
      com_rep: com_rep.to_s,
      last_action: last_action.to_s,
      last_action_at: last_action_at.to_s,
      introduced_by: introduced_by.to_s,
      summary: summary,
      text: text,
      url: bill_url
    }

    return bill
  end

  def self.read_bill_text(bill_filepath)
    return nil unless File.exists? bill_filepath

    bill_num = nil
    bill_sponsor = nil

    f = File.open bill_filepath, 'r'
    while !f.eof?
      break unless bill_num.nil? or bill_sponsor.nil?
      line = f.readline

      if bill_num.nil?
        m = /bill (No.|No|Number) ([\da-z]+) of (20\d\d)$/i.match line
        if (not m.nil?)
          bill_num = "Bill #{m.captures[1]}, #{m.captures[2]}"
          next
        end
      end
      if (bill_sponsor.nil?)
        m = /\((Shri|Mr.|Smt.|Shrimati|Mrs.) (.*)?, Minister of .*/.match line
        if (not m.nil?)
          bill_sponsor = m.captures[1]
          next
        end
      end
    end

    f.close
    return bill_num, bill_sponsor
  end

  def self.bill_status(billstatus_col)
    s = billstatus_col.text.strip
    # Remove any extended ASCII character in the tail
    while (s[-1].ord > 127)
      s.chop!
    end
    return s.strip
  end

  def self.bill_text(billtext_col)
    data_dir_path = 'download' # <-- TODO: We will make it configurable through the environment settings
    billtext_col.css('a').each do |a|
      #binding.remote_pry
      if (a.text.lstrip.start_with? 'Bill Text' or a.text.lstrip.start_with? 'Ordinance Text')
        filename_noext = "#{data_dir_path}/bill_#{Time.now.strftime '%d_%s'}"
        filename_pdf = "#{filename_noext}.pdf"
        filename_txt = "#{filename_noext}.txt"
        Dir.mkdir(data_dir_path) unless Dir.exists?(data_dir_path)
        text_link = URI.join(@billtrack_url, a['href']).to_s #avoid errors due to relative paths
        c = Curl::Easy.download(text_link, filename_pdf)
        if ('200 OK' != c.status)
          Report.warning self, "Could not download the PDF file from #{a['href']}"
          return nil
        end

        if (File.exists?(filename_pdf))
          Docsplit.extract_text(filename_pdf, :output => data_dir_path)
          return filename_txt if File.exists? filename_txt
        end
      end
    end
    return nil
  end

  def self.find_ministry(ministry_node)
    return nil if ministry_node.nil? or ministry_node.previous().nil? or ministry_node.previous().previous().nil?
    return ministry_node.text.strip if (':' == ministry_node.previous().text) and ('Ministry' == ministry_node.previous().previous().text)
    return nil
  end

  #billtrack_col = One of the column in the HTML table that has the URL of the details page of the bill
  #This function first finds the URL of the details page of bill, and then scraps it to find all the
  #related details, and sends them back to the client in an array
  def self.bill_details(billtrack_col)
    ret_title = billtrack_col.text.strip
    bill_detail_url = billtrack_col.css('a').first()['href']

	  ret_summary = ret_ministry = ''
    ret_introduced_on = ret_ls_status = ret_rs_status = ret_com_ref = ret_com_rep = last_action = nil
    last_action_at = Date.civil

    puts "Parsing bill details at: #{bill_detail_url}"

    bill_detail_doc = Utils.html_for bill_detail_url

    #We've parsed the HTML details page of bill. 
    #let's scrap the important information from it
    tables = bill_detail_doc.css('form#prs-billtrack1 table')
    if (tables)
      ministry_node = tables.at('span.text1')
      ret_ministry = find_ministry ministry_node
      first = true
      tds = tables.css('td.text1')
    
      ret_summary = tds[0].text.strip unless tds.nil? or tds.count == 0 or tds[0].text == 'Introduction'

      idx = 1
      while (idx < tds.count)
        td = tds[idx]
        idx = idx + 1

        case td.text
        when 'Introduction'
          if (ret_introduced_on.nil?) # Some pages are not well formatted
            ret_introduced_on = Utils.parse_date(td.next().text) unless td.next().nil?
            last_action, last_action_at = 'Introduction', ret_introduced_on if ret_introduced_on > last_action_at unless ret_introduced_on.nil?
            idx = idx + 1
          end
        when 'Com. Ref.'
          date = Utils.parse_date(td.next().text) unless td.next().nil?
          ret_com_ref = date unless date.nil? or date > Date.today
          last_action, last_action_at = 'Referred to the standing committee', ret_com_ref if ret_com_ref > last_action_at unless ret_com_ref.nil?
          idx = idx + 1
        when 'Com. Rep.'
          date = Utils.parse_date(td.next().text) unless td.next().nil?
          ret_com_rep = date unless date.nil? or date > Date.today
          last_action, last_action_at = 'Report presented by the standing committee', ret_com_rep if ret_com_rep > last_action_at unless ret_com_rep.nil?
          idx = idx + 1
        when 'Lok Sabha'
          date = Utils.parse_date(td.next().text) unless td.next().nil?
          ret_ls_status = date unless date.nil? or date > Date.today
          last_action, last_action_at = 'Bill debated and passed in Lok Sabha', ret_ls_status if ret_ls_status > last_action_at unless ret_ls_status.nil?
          idx = idx + 1
        when 'Rajya Sabha'
          date = Utils.parse_date(td.next().text) unless td.next().nil?
          ret_rs_status = date unless date.nil? or date > Date.today
          last_action, last_action_at = 'Bill debated and passed in Rajya Sabha', ret_rs_status if ret_rs_status > last_action_at unless ret_rs_status.nil?
          idx = idx + 1
        end
      end
    end

    return ret_title, ret_ministry, ret_introduced_on, ret_summary, ret_ls_status, 
      ret_rs_status, bill_detail_url, ret_com_ref, ret_com_rep, last_action, last_action_at
  end
end

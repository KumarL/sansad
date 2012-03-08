require 'feedzirra'
require 'nokogiri'

class UpcomingSenateDaily
  
  def self.run(options = {})
    count = 0
    bill_count = 0
    
    url = "https://democrats.senate.gov/floor/daily-summary/feed/"
    
    rss = nil
    begin
      rss = Feedzirra::Feed.fetch_and_parse url, :timeout => 20
    rescue Exception => ex
      Report.warning self, "Network error on fetching Senate Daily Summary feed, can't go on.", :url => url
      return
    end

    if rss.is_a?(Fixnum)
      Report.warning self, "Got status code #{rss} from Senate Daily Summary feed, can't go on.", :url => url
      return
    elsif rss.nil?
      Report.warning self, "Got a nil return value from Feedzirra from the Senate Daily Summary feed, can't go on.", :url => url
      return
    end

    bad_entries = []
    
    # accumulate upcoming bills 
    upcoming_bills = {}
    
    rss.entries.each do |entry|
      doc = Nokogiri::HTML entry.content
      
      legislative_date = Utils.utc_parse entry.title
      unless legislative_date
        # There are now a bunch of "State Work Period" entries in the feed, going forward in time through September
        # Just ignore them
        next
      end

      legislative_day = legislative_date.strftime "%Y-%m-%d"
      session = Utils.session_for_year legislative_date.year
      
      since = options[:since] ? Utils.utc_parse(options[:since]) : Time.now.midnight.utc
      
      # don't care unless it's today or in the future
      next if legislative_date.midnight < since.midnight
      
      upcoming_bills[legislative_day] = {}
      text_pieces = []
      day_bill_ids = []
      
      items = nil
      if root = doc.at("/html/body/ul")
        items = root.xpath "li"
      else
        items = doc.at("/html/body").element_children
      end
      
      items.each_with_index do |item, i|
        
        text = Utils.strip_unicode item.text
        
        next unless text.present?
            
        # figure out the text item, including any following sub-items
        if item.next_element and item.next_element.name == "ul"
          text << "\n"
          item.next_element.xpath("li").each do |subitem|
            text << "\n* #{subitem.text}"
          end
        end
        
        text_pieces << text
        
        bill_ids = Utils.bill_ids_for text, session
        day_bill_ids += bill_ids
        
        bill_ids.each do |bill_id|
          if upcoming_bills[legislative_day][bill_id]
            upcoming_bills[legislative_day][bill_id][:context] << text
          else
            upcoming_bills[legislative_day][bill_id] = {
              :session => session,
              :chamber => "senate",
              :context => [text],
              :bill_id => bill_id,
              :legislative_day => legislative_day,
              :source_type => "senate_daily",
              :source_url => entry.url,
              :permalink => entry.url
            }
            if bill = Utils.bill_for(bill_id) and bill['abbreviated'] != true
              upcoming_bills[legislative_day][bill_id][:bill] = bill
            end
          end
        end
      end
      
      schedule = UpcomingSchedule.find_or_initialize_by(
        :source_type => "senate_daily",
        :legislative_day => legislative_day
      )
      
      schedule.attributes = {
        :chamber => "senate",
        :session => session,
        :legislative_day => legislative_day,
        :bill_ids => day_bill_ids.uniq,
        :items => text_pieces,
        :original => entry.content.strip,
        :source_url => entry.url,
        :permalink => entry.url
      }
      
      schedule.save!
      
      puts "[#{legislative_day}][senate_daily][schedule] Created/updated schedule" if config['debug']
      count += 1
      
    end
    
    Report.success self, "Created or updated #{count} schedules"
    
    # create any accumulated upcoming bills
    upcoming_bills.each do |legislative_day, bills|
      # clear out the previous items for that legislative day
      UpcomingBill.where(
        :source_type => "senate_daily",
        :legislative_day => legislative_day
      ).delete_all
      
      puts "[#{legislative_day}][senate_daily][bill] Cleared upcoming bills" if config['debug']
      
      bills.each do |bill_id, bill|
        upcoming = UpcomingBill.create! bill
        
        # sync to bill object
        if upcoming[:bill]
          Utils.update_bill_upcoming! bill_id, upcoming
        end

        bill_count += 1
      end
      
    end
    
    Report.success self, "Created or updated #{bill_count} upcoming bills"

    if bad_entries.any?
      Report.warning self, "#{bad_entries.size} expected date-less titles in feed", :bad_entries => bad_entries
    end

  end
end
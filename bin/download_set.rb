require 'rubygems'
require 'mechanize'
require 'optparse'
require 'sanitize'
require 'set'
require 'pp'
require 'fastercsv'

def download(options)
  agent = Mechanize.new
  page = agent.get options[:url]
  downloaded_names = Set.new
  cards = []

  page.search('html body table tr td table tr td table').each do |color_table|
    color_table.search('tr td table').each do |card_table|
      name = card_table.search('tr[1] td[1]').text.strip
      name.slice!(0) if name =~ /^\*/
      if downloaded_names.include? name
        next
      else
        downloaded_names.add name
      end

      mana_cost = ''
      converted_mana_cost = 0
      card_table.search('tr[1] td[2] img').each do |mana_el|
        if mana_el['alt'] =~ /\d+/
          converted_mana_cost += mana_el['alt'].to_i
        else
          converted_mana_cost += 1
        end
        mana_cost += mana_el['alt'].upcase
      end

      type = card_table.search('tr[2] td[1]').text.strip

      rarity = card_table.search('tr[2] td[2] img')[0]['alt'][0,1].upcase
      if rarity == 'B'
        rarity = 'L'
      end

      text = Sanitize.clean(card_table.search('tr[3] td')[0].inner_html, Sanitize::Config::RELAXED)
      text.gsub!(/<img.+?\/>/) do |match|
        alt = match[/alt=(.+?)\s/]
        if alt =~ /\{\w\}/
          alt = alt[/\{\w\}/][1,1]
        else
          alt = alt[/\d/]
        end
        alt
      end
      text.gsub!(/<br \/>/, "\n")
      text.gsub!(/&#13;/, '')
      text = text.strip.chop
      text = Sanitize.clean(text)

      pt = card_table.search('tr[4] td[2]').text.strip
      power = 0
      toughness = 0
      unless pt == ''
        if power =~ /\//
          power = pt[/^\d+/] || power
        end
        toughness = pt[/\d+$/] || toughness
      end

      cards += [[name, mana_cost, converted_mana_cost, power, toughness, rarity, type, text]]
    end
  end

  puts "found #{cards.size} cards"
  
  FasterCSV.open("../res/sets/#{options[:set]}.csv", File::CREAT|File::WRONLY) do |csv|
    cards.each do |card|
      csv << card
    end
  end
end

set = ARGV[0]
url = ARGV[1]

unless url and set
  puts "usage: ruby download_set.rb set_name set_url"
  exit
end

download(:set => set, :url => url)

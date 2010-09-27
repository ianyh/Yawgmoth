#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'optparse'
require 'sanitize'
require 'set'
require 'pp'
require 'fastercsv'

def load_image_map
  image_map_file = '../res/card-image-map'
  FasterCSV.read(image_map_file, :col_sep => "\t").inject({}) do |img_map, pair|
    img_map.merge({ pair[0] => pair[1] })
  end
end

def write_image_map(image_map)
  image_map_file = '../res/card-image-map'
  FasterCSV.open(image_map_file, File::WRONLY, :col_sep => "\t") do |tsv|
    image_map.each do |fname, url|
      tsv << [fname, url]
    end
  end
end

def filename_from_name(card_name)
  fname = card_name.gsub(/ \/\/ /, '_').gsub(/'/, '').gsub(',', '').gsub(/ /, '_').gsub(/-/, '_')
  fname += '.jpg'
  fname.downcase
end

def download(options)
  def clean_row(row)
    return row.content.gsub(/ +/, ' ').gsub(/\n+/,"\n\n").gsub(/\r+/, '').gsub(/(\s)\s*/, '\1').gsub("\342\200\224", "-").chomp
  end

  def process_card(card)
    processed = card.clone

    # convert power and toughness
    # have to deal with loyalty on planeswalkers
    if processed[:pt] =~ /\//
      processed[:pt] = [processed[:pt][/\((.+)\//, 1],
                        processed[:pt][/\/(.+?)\)/, 1]]
    elsif processed[:pt] =~ /\(/
      processed[:pt] = [nil, processed[:pt][/\((.+?)\)/, 1]]
    else
      processed[:pt] = [nil, nil]
    end

    # calculate converted mana cost
    #
    # if there are parentheses, the cost has split costs like (W/U)
    # each split cost is counted as 1 in converted mana cost; might be
    # weirdness there with things like (2/U)
    if processed[:cost]
      if processed[:cost] =~ /\(/
        processed[:converted_cost] = processed[:cost].scan(/\(.+?\)/).length
      else
        processed[:converted_cost] = 0
      end
      
      processed[:converted_cost] += processed[:cost].scan(/[WUBRG]/).length +
        processed[:cost].gsub(/[WUBRGX]/, '').to_i
    else
      processed[:converted_cost] = 0
    end

    # convert rarity string to rarity character
    if processed[:rarity] =~ /Mythic Rare/
      processed[:rarity] = 'M'
    elsif processed[:rarity] =~ /Rare/
      processed[:rarity] = 'R'
    elsif processed[:rarity] =~ /Uncommon/
      processed[:rarity] = 'U'
    elsif processed[:rarity] =~ /Common/
      processed[:rarity] = 'C'
    elsif processed[:rarity] =~ /Basic/
      processed[:rarity] = 'L'
    else
      puts "unknown rarity: #{processed[:rarity]}"
      processed[:rarity] = nil
    end

    processed
  end
  
  agent = Mechanize.new
  
  if options[:url] and options[:set]
    page = agent.get options[:url]
    downloaded_names = Set.new
    cards = []
    card = {}

    page.search('div.textspoiler table tr').each do |data_row|
      content = clean_row(data_row)
      attr_sym = nil
      if content =~ /Name:/
        attr_sym = :name
      elsif content =~ /Cost:/
        attr_sym = :cost
      elsif content =~ /Type:/
        attr_sym = :type
      elsif content =~ /Pow\/Tgh:|Loyalty:/
        attr_sym = :pt
      elsif content =~ /Rules Text:/
        attr_sym = :text
      elsif content =~ /Rarity:/
        attr_sym = :rarity
      end

      if attr_sym.nil?
        cards.push process_card(card)
        card.clear
      else
        card[attr_sym] = content[/:\n((\n|.)+)$/, 1]
      end
    end
    
    puts "found #{cards.size} cards"

    FasterCSV.open("../res/sets/#{options[:set]}.csv", File::CREAT|File::WRONLY) do |csv|
      cards.each do |card|
        csv << [card[:name], card[:cost], card[:converted_cost]] + card[:pt] + [card[:rarity], card[:type], card[:text]]
      end
    end    
  end
end

if __FILE__ == $0
  options = {}
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
    opts.on('-sMANDATORY', '--set', 'set name to be downloaded') do |s|
      options[:set] = s
    end
    opts.on('-uMANDATORY', '--spoiler-url', String, 'url to grab card information from') do |u|
      options[:url] = u
    end
    opts.on_tail('-h', '--help', 'show this message') do
      puts opts
      exit
    end
  end

  opts.parse!(ARGV)
  
  unless (options[:url] and options[:set])
    puts opts
    exit
  end

  download(options)
end

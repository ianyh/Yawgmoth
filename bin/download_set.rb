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
  agent = Mechanize.new

  if options[:url] and options[:set]
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
        text = text.strip
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

  if options[:image_url]
    page = agent.get options[:image_url]
    puts page.search('img').each {|foo|}
    page.search('img').each do |img|
      next unless img
      name = img['alt']
      next unless name
      
      if options[:url] and options[:set] and downloaded_names.include? name or options[:image_url]
        url = img['src']
        url = 'http://gatherer.wizards.com/' + url.gsub('../', '')
        options[:image_map][filename_from_name(name)] = url
      end
    end
    write_image_map(options[:image_map])
  end
  
end

if __FILE__ == $0
  options = {}
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
    opts.on('-s', '--set', String, 'set name to be downloaded') do |s|
      options[:set] = s
    end
    opts.on('-u', '--spoiler-url', String, 'url to grab card information from') do |u|
      options[:url] = u
    end
    opts.on('-i', '--images-url URL', String, 'url to grab card image urls from') do |s|
      options[:image_url] = s
    end
    opts.on_tail('-h', '--help', 'show this message') do
      puts opts
      exit
    end
  end

  opts.parse!(ARGV)
  
  unless options[:image_url]
    puts 'no image url'
    unless (options[:url] and options[:set])
      puts opts
      exit
    end
  end

  download(options.merge({:image_map => load_image_map}))
end

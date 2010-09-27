#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'fastercsv'
require 'download_set'

def gen(sets, sets_conversion)
  image_map = load_image_map

  sets.each do |set|
    puts "scraping #{set}"
    page_no = 1
    url = 'http://magiccards.info/query?q=%2B%2Be:' + sets_conversion[set] + '/en&v=scan&s=issue&p='
#    url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&method=visual&set=[%22' + set_name + '%22]'
    agent = Mechanize.new
    page = agent.get(url + page_no.to_s)
    while not page.content =~ /Your query did not match any cards/
      page.search('img').each do |img|
        next unless img and img['alt']

        name = img['alt']
        u = img['src']
        #      url = 'http://gatherer.wizards.com/' + url.gsub('../', '')
        image_map[filename_from_name(name)] = u
      end

      page_no += 1
      page = agent.get(url + page_no.to_s)
    end
  end

  write_image_map(image_map)
end

SETS = ['Unglued',
        'Unhinged',
        'Limited Edition Alpha',
        'Limited Edition Beta',
        'Unlimited Edition',
        'Arabian Nights',
        'Antiquities',
        'Revised Edition',
        'Legends',
        'The Dark',
        'Fallen Empires',
        'Fourth Edition',
        'Homelands',
        'Ice Age',
        'Alliances',
        'Mirage',
        'Visions',
        'Fifth Edition',
        'Weatherlight',
        'Tempest',
        'Stronghold',
        'Exodus',
        'Urza\'s Saga',
        'Urza\'s Legacy',
        'Classic Sixth Edition',
        'Urza\'s Destiny',
        'Mercadian Masques',
        'Nemesis',
        'Prophecy',
        'Invasion',
        'Planeshift',
        'Seventh Edition',
        'Apocalypse',
        'Odyssey',
        'Torment',
        'Judgment',
        'Onslaught',
        'Legions',
        'Scourge',
        'Eighth Edition',
        'Mirrodin',
        'Darksteel',
        'Fifth Dawn',
        'Champions of Kamigawa',
        'Betrayers of Kamigawa',
        'Saviors of Kamigawa',
        'Ninth Edition',
        'Ravnica: City of Guilds',
        'Guildpact',
        'Dissension',
        'Coldsnap',
        'Time Spiral',
        'Planar Chaos',
        'Future Sight',
        'Tenth Edition',
        'Lorwyn',
        'Morningtide',
        'Shadowmoor',
        'Eventide',
        'Shards of Alara',
        'Conflux',
        'Alara Reborn',
        'Magic 2010',
        'Zendikar',
        'Worldwake',
        'Rise of the Eldrazi',
        'Magic 2011',
        'Scars of Mirrodin']

SET_CONVERSION = {
  'Scars of Mirrodin' => 'som',
  'Rise of the Eldrazi' => 'roe',
  'Worldwake' => 'wwk',
  'Zendikar' => 'zen',
  'Alara Reborn' => 'arb',
  'Conflux' => 'cfx',
  'Shards of Alara' => 'ala',
  'Eventide' => 'eve',
  'Shadowmoor' => 'shm',
  'Lorwyn' => 'lw',
  'Morningtide' => 'mt',
  'Future Sight' => 'fut',
  'Planar Chaos' => 'pc',
  'Time Spiral' => 'ts',
  'Time Spiral "Timeshifted"' => 'tsts',
  'Coldsnap' => 'cs',
  'Alliances' => 'ai',
  'Ice Age' => 'ia',
  'Dissension' => 'di',
  'Guildpact' => 'gp',
  'Ravnica: City of Guilds' => 'rav',
  'Saviors of Kamigawa' => 'sok',
  'Betrayers of Kamigawa' => 'bok',
  'Champions of Kamigawa' => 'chk',
  'Fifth Dawn' => '5dn',
  'Darksteel' => 'ds',
  'Mirrodin' => 'mi',
  'Scourge' => 'sc',
  'Legions' => 'le',
  'Onslaught' => 'on',
  'Judgment' => 'ju',
  'Torment' => 'tr',
  'Odyssey' => 'od',
  'Apocalypse' => 'ap',
  'Planeshift' => 'ps',
  'Invasion' => 'in',
  'Prophecy' => 'pr',
  'Nemesis' => 'ne',
  'Mercadian Masques' => 'mm',
  'Urza\'s Destiny' => 'ud',
  'Urza\'s Legacy' => 'ul',
  'Urza\'s Saga' => 'us',
  'Exodus' => 'ex',
  'Stronghold' => 'sh',
  'Tempest' => 'tp',
  'Weatherlight' => 'wl',
  'Visions' => 'vi',
  'Mirage' => 'mr',
  'Homelands' => 'hl',
  'Fallen Empires' => 'fe',
  'The Dark' => 'dk',
  'Legends' => 'lg',
  'Antiquities' => 'aq',
  'Arabian Nights' => 'an',
  'Magic 2011' => 'm11',
  'Magic 2010' => 'm10',
  'Tenth Edition' => '10e',
  'Ninth Edition' => '9e',
  'Eighth Edition' => '8e',
  'Seventh Edition' => '7e',
  'Classic Sixth Edition' => '6e',
  'Fifth Edition' => '5e',
  'Fourth Edition' => '4e',
  'Revised Edition' => 'rv',
  'Unlimited Edition' => 'un',
  'Limited Edition Beta' => 'be',
  'Limited Edition Alpha' => 'al',
  'Unhinged' => 'uh',
  'Unglued' => 'ug',
  'Starter 2000' => 'st2k',
  'Starter 1999' => 'st',
  'Portal' => 'po',
  'Portal Second Age' => 'po2',
  'Portal Three Kingdoms' => 'p3k'
}

if ARGV.size > 0
  gen(ARGV, SET_CONVERSION)
else
  gen(SETS, SET_CONVERSION)
end


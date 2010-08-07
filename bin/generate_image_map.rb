require 'rubygems'
require 'mechanize'
require 'fastercsv'
require 'download_set'

def gen(sets)
  image_map = load_image_map

  sets.each do |set|
    puts "scraping #{set}"
    set_name = set.gsub(' ','+')
    url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx?output=spoiler&method=visual&set=[%22' + set_name + '%22]'
    agent = Mechanize.new
    page = agent.get url

    page.search('img').each do |img|
      next unless img and img['alt']

      name = img['alt']
      url = img['src']
      url = 'http://gatherer.wizards.com/' + url.gsub('../', '')
      image_map[filename_from_name(name)] = url
    end
  end

  write_image_map(image_map)
end

SETS = ['Unglued',
        'Unhinged',
        'Limited Edition Alpha',
        'Limited Edition Beta',
        'Unlimited',
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
        'Judgement',
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
        'Cold Snap',
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
        'Magic 2011']

gen(SETS)

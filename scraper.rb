# This is a template for a Ruby scraper on Morph (https://morph.io)
# including some code snippets below that you should find helpful

#
# require 'mechanize'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("http://foo.com")
#
# # Find somehing on the page using css selectors
# p page.at('div.content')
#
# # Write out to the sqlite database using scraperwiki library
# ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries. You can use whatever gems are installed
# on Morph for Ruby (https://github.com/openaustralia/morph-docker-ruby/blob/master/Gemfile) and all that matters
# is that your final data is written to an Sqlite database called data.sqlite in the current working directory which
# has at least a table called data.

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'json'

doc = Nokogiri::HTML(open('http://en.wikipedia.org/wiki/Opinion_polling_for_the_next_New_Zealand_general_election'))

rows = doc.css('table:first tr')

headers = rows[0].css('th')

parties = {}

headers[2..headers.length].each_with_index do |cell, i|
  parties[i+2] = cell.text
end

results = []

rows.each do |row|
  cells = row.css('td')
  next unless cells.length > 1
  poll = cells[0].text.gsub(/\[.*\]/, '')
  date = cells[1].text.gsub(/\[.*\]/, '')
  parties.each do |key, party|
    value = cells[key].text
    next if value == ''
    results.push({
      poll: poll,
      date: date,
      party: party,
      value: value.to_f
    })
  end
end

ScraperWiki.save_sqlite(["polls"], results)

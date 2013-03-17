#!/usr/bin/env ruby

# rlinkchecker.rb spiders a site and will gather all links (external and internal)
# and return the response code for each link.

require 'rubygems'
gem 'anemone', '=0.4.0.1'
require 'anemone'
require 'net/http'
require 'cgi'
require 'colorize'

target = URI(ARGV.last)
filename  = (ARGV[-2]) if (ARGV[-2]) =~ /^\w.*/
output = ARGV[-3] if ARGV[-3] != /^-./

if !ARGV[-2] 
  puts <<-INFO
Usage:
  ruby rlinkchecker.rb [file output path] <filename> <url>
    
Synopsis:
  RLinkChecker crawls the target site, gathering all links on each page, internal and external,
  but will not follow external links. The response code is returned for all links found. 
  The link's parent page, errors, total pages processed, total links processed, total unique links,
  and other scan statistics are also recorded. It's recommended to import/convert the generated 
  report into a spreadsheet to better view the results.

Example:
  ruby rlinkchecker.rb /Users/johnsnow/Desktop/ myfilename http://tar.get
INFO
  exit(0)
end

allLinks = []
uniqueLinks = []
result = {}
final = []
totalPages  = -1

begin
  Anemone.crawl(target, :discard_page_bodies => true, :remember_external_links => true) do |anemone|
    @t1 = Time.now.strftime("%m/%d/%y at %r" )
    puts @t1.green + ": Processing pages...".green
    anemone.on_every_page do |page|
      totalPages  += 1
      page.links.each { |link|
        uniqueLinks.push(link) unless uniqueLinks.include?(link)
        result =  { :page_url => page.url, :link => CGI::unescape(link.to_s), :code => "Error", :errors => '' }
        allLinks.push(result) #unless allLinks.detect { |x| x[:link] == link.to_s }
      }
    end
    
    anemone.after_crawl do |z|
      puts "Total Pages Processed: ".yellow + "#{totalPages}"
      puts "Links Queued: ".yellow + "#{allLinks.count}"
      puts Time.now.strftime("%m/%d/%y at %r" ).green + ": Processing all links...".green
      
      allLinks.each {|link|
        begin
          uri = URI.parse(link[:link])
          req = Net::HTTP::Head.new(uri.path)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if link[:link] =~ /^https/
          res = http.request(req)
          link[:code] = res.code
        rescue Exception => ex
          link[:errors] = ex.message
        end
          final.push "#{link[:code]}\t" + "#{link[:page_url]}\t" + "#{link[:link]}\t" + "#{link[:errors]}\t"
      }
      @t2 = Time.now.strftime("%m/%d/%y at %r" ) 
      puts  @t2.green + ": Complete! ".green
    end
  end
  #puts uniqueLinks.count
  #puts allLinks.count
  #puts totalLinks
  File.open("#{output}" + "#{filename}.txt", "w") do |f|
    f.puts "Results for Target:\t" + "Started At:\t" + "Completed At:\t" + "Pages Processed:\t" + "Links Processed:\t" +"Unique Links:\t"
    f.puts "#{target}\t" + "#{@t1}\t" + "#{@t2}\t" + "#{totalPages}\t" + "#{allLinks.count}\t" + "#{uniqueLinks.count}"
    f.puts ""
    f.puts "Response Code\t" + "Parent Page\t" + "Link\t" + "Errors\t"
    f.puts final
  end

rescue Exception => ex
  puts ex.message
end
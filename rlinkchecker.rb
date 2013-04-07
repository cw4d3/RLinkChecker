#!/usr/bin/env ruby

# rlinkchecker.rb spiders a site and will gather all links (external and internal)
# and return the response code and other information for each link.

require 'rubygems'
gem 'anemone'#, '=0.4.0.1'
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
totalPages  = 0
pagesWithLinks = Hash.new(0)

begin
  Anemone.crawl(target, :discard_page_bodies => true, :remember_external_links => true) do |anemone|
    @t1 = Time.now.strftime("%m/%d/%y at %r" )
    puts @t1.green + ": Processing pages...".green
    anemone.on_every_page do |page|
      totalPages += 1
      page.links.each { |link|
        uniqueLinks.push(link) unless uniqueLinks.include?(link)
        result =  { :page_url => page.url, :link => CGI::unescape(link.to_s), :code => "Error",
                    :depth => page.depth, :size => '', :response_time => '', :headers => '', :errors => ''
                  }
        allLinks.push(result)
      }
    end
    
    anemone.after_crawl do |z|
      allLinks.each { |h| pagesWithLinks[h[:page_url]] += 1 }
      pagesWithLinks = Hash[pagesWithLinks.map {|key,value| [key,value.to_s] }]
      puts "Total Pages Processed: ".yellow + "#{totalPages}"
      puts "Total Pages With Links: ".yellow + "#{pagesWithLinks.count}"
      puts "Links Queued: ".yellow + "#{allLinks.count}"
      puts Time.now.strftime("%m/%d/%y at %r" ).green + ": Processing queued links...".green
      
      allLinks.each {|link|
        begin
          uri = URI.parse(link[:link])
          req = Net::HTTP::Head.new(uri.path)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if link[:link] =~ /^https/
          start_time = Time.now # mark start of request
          res = http.request(req) # get response
          
          link[:code] = res.code
          link[:headers] = res["last-modified"]
          link[:size] = res["content-length"]
          link[:response_time] = Time.now - start_time # get response time
        rescue Exception => ex
          link[:errors] = ex.message
        end
          final.push  "#{link[:code]}\t" + "#{link[:page_url]}\t" + "#{link[:link]}\t" +
                      "#{link[:depth]}\t" + "#{link[:size]}\t" + "#{link[:response_time]}\t" +
                      "#{link[:headers]}\t" + "#{link[:errors]}\t"
      }
      @t2 = Time.now.strftime("%m/%d/%y at %r" ) 
      puts  @t2.green + ": Complete! ".green
      
    end
  end
  
  File.open("#{output}" + "#{filename}.txt", "w") do |f|
    f.puts "Results for Target:\t" + "Started At:\t" + "Completed At:\t" + "Pages Processed:\t" + "Pages With Links:\t" + "Links Processed:\t" + "Unique Links:\t"
    f.puts "#{target}\t" + "#{@t1}\t" + "#{@t2}\t" + "#{totalPages}\t" + "#{pagesWithLinks.count}\t" + "#{allLinks.count}\t" + "#{uniqueLinks.count}"
    f.puts ""
    f.puts "Response Code\t" + "Parent Page\t" + "Link\t" + "Link Depth\t" + "Size (bytes)\t" + "Response Time\t" + "Last-Modified Headers\t" + "Errors\t"
    f.puts final
  end

rescue Exception => ex
  puts ex.message
end
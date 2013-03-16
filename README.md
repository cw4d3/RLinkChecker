RLinkChecker
============

**Usage:**
```ruby
ruby rlinkchecker.rb [file output path] <filename> <url>
```
If you supply a file output path, don't forget the trailing "/"
    
**Synopsis:**

  RLinkChecker crawls the target site, gathering all links on each page, internal and external,
  but will not follow external links. The response code is returned for all unique links found.
  Parent page, errors, and scan statistics are also recorded. It's recommended to import the
  generated report into a spreadsheet to better view the results.

**Example:***
```
ruby rlinkchecker.rb /Users/johnsnow/Desktop/ myfilename http://tar.get
```

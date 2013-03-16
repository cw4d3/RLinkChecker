RLinkChecker
============

**Usage:**
```ruby
ruby rlinkchecker.rb [file output path] <filename> <url>
```
If you supply a file output path, don't forget the trailing "/".
    
**Synopsis:**

  RLinkChecker crawls the target site, gathering all links on each page, internal and external,
  but will not follow external links. The response code is returned for all links found.
  The link's parent page, errors, total pages processed, total links processed, total unique links,
  and other scan statistics are also recorded. It's recommended to import/convert the generated 
  report into a spreadsheet to better view the results.

**Example:**
```
ruby rlinkchecker.rb /Users/johnsnow/Desktop/ myfilename http://tar.get
```

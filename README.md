RLinkChecker
============

**Installation:**

This program requires a specific version of the Anemone gem. Install the gem from GitHub using the version `pigeonworks` forked and modified,
so as to allow for the remembering of exernal links:
```
gem install specific_install
gem specific_install -l https://github.com/pigeonworks/anemone.git
```

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

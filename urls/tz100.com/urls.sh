ruby -e "(1..50).each { |i| puts \"http://www.tz100.com/?p=#{i}\" }" |
xargs -I URL curl -s URL | 
ruby -ne "puts 'http://www.tz100.com' + \$1 if \$_ =~ /(\/item\/\d+\/)/" | 
sort -u

ruby -e "(1..50).each { |i| puts \"http://www.mgpyh.com/newest/#{i}\" }" |
xargs -I URL curl -s URL | 
ruby -ne "puts 'http://www.mgpyh.com/' + \$1 if \$_ =~ /(\/recommend\/[^\/]+\/)/" | 
sort -u

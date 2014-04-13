ruby -e "(1..50).each { |i| puts \"http://www.123haitao.com/home/?page=#{i}\" }" |
xargs -I URL curl -s URL | 
ruby -ne "puts 'http://www.123haitao.com/t/' + \$1 if \$_ =~ /www\.123haitao\.com\/t\/(\d+)/" | 
sort -u

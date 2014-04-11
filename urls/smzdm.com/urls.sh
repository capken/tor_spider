ruby -e "(1..100).each { |i| puts \"http://haitao.smzdm.com/#{i}\" }" |
xargs -I URL curl -s URL | 
ruby -ne "puts 'http://haitao.smzdm.com/youhui/' + \$1 if \$_ =~ /haitao\.smzdm\.com\/youhui\/(\d+)/" | 
sort -u

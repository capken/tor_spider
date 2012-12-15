#root page: http://www.starbucks.com.cn/store/store-list.html

curl -X POST --data "Action=GetStore&Area=&Province=&City=" "http://www.starbucks.com.cn/interFace/Store.ashx" |
ruby -ne "puts \$1 if \$_ =~ /ShowNextPage\(([0-9]+)\)\">尾页/" |
ruby -ne "(1..\$_.to_i).each { |i| puts 'Action=GetStore&Area=&Province=&City=&Page=' + i.to_s}" |
xargs -I DATA curl -X POST --data "DATA" "http://www.starbucks.com.cn/interFace/Store.ashx" |
ruby -ne "puts \$_.scan /<a href=\"(.+?)\">/i" | egrep -v "javascript" |
xargs -I PATH echo "http://www.starbucks.com.cn/store/PATH"

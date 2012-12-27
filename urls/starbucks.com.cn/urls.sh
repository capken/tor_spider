#root page: http://www.starbucks.com.cn/store/store-list.html

curl -X POST --data "Action=GetStore&Area=&Province=&City=" "http://www.starbucks.com.cn/interFace/Store.ashx" |
ruby -ne "puts \$1 if \$_ =~ /ShowNextPage\(([0-9]+)\)\">尾页/" |
ruby -ne "(1..\$_.to_i).each { |i| puts 'Action=GetStore&Area=&Province=&City=&Page=' + i.to_s}" | cat |
xargs -I DATA $(dirname $0)/curl_wrapper.sh -X POST --data "DATA" "http://www.starbucks.com.cn/interFace/Store.ashx" |
ruby -ruri -ne "records = \$_.scan /<tr><td>(.+?)<\/td><\/tr>/
  records.each do |s|
    arr = s[0].split '</td><td>'
    r,l,u = arr[1], arr[2], arr[5]
    if u =~ /<a href=\"(.+?)\">/i
      puts URI.encode(\$1) + \"?region=\" + URI.encode(r) + \"&locality=\" + URI.encode(l)
    end
  end" |
xargs -I PATH echo "http://www.starbucks.com.cn/store/PATH"

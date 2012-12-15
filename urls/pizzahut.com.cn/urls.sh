curl "http://www.pizzahut.com.cn/phcda/xml/GetHappyProvince.aspx" | egrep "item" |
ruby -ne "puts [\$1, \$2].map(&:strip).join(\"\\t\") if \$_ =~ /name=\"(.+?)\" id=\"(.+?)\"/" |
ruby -ruri -ne "pname, pid = \$_.split; puts 'http://www.pizzahut.com.cn/phcda/xml/GetHappyCity.aspx?provinceId=' + pid + '&province=' + URI.encode(pname)" |
xargs -I URL curl URL | egrep "item" | ruby -ne "puts [\$1, \$2].join(\"\\t\") if \$_ =~ /name=\"(.+?)\" id=\"(.+?)\"/" |
ruby -ruri -ne "cname, cid = \$_.split; puts 'http://www.pizzahut.com.cn/phcda/xml/GetHappyStore.aspx?cityid=' + cid + '&city=' + URI.encode(cname)"

# details urls http://www.pizzahut.com.cn/phcda/minisite/storemap/choice.aspx?s=763

echo "上海
杭州
苏州" |
xargs -I CITY curl -X POST -d "con= and City like '%CITY%'" "http://www.familymart.com.cn/shfm/service/searchStores.aspx"

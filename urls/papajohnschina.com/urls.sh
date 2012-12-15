curl "http://www.papajohnschina.com/bj/info_search.php" | ruby -ne "puts \$_.scan /http.+?city=([^\"]+)/" | xargs -I CITY echo "http://www.papajohnschina.com/bj/info_search.php?cit=CITY"

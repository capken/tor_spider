curl "http://www.papajohnschina.com/bj/info_search.php" |
ruby -ne "puts \$_.scan /http.+?city=([^\"]+)/" |
ruby -ruri -ne "puts 'http://www.papajohnschina.com/bj/info_search.php?cit=' + URI.encode(\$_.strip)"

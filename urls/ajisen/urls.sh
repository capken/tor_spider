curl "http://www.ajisen.com.cn/restaurant03.php" | grep "restaurant03.php?cid=" | ruby -ne "puts \$_.scan(/restaurant03\.php\?cid=\d+/)" | xargs -I PATH echo "http://www.ajisen.com.cn/PATH"

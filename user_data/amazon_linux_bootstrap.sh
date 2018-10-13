#!/bin/sh

yum update -y
yum install -y httpd php
service httpd start

dbString="${dbString}"
cat <<EOL > /var/www/html/index.php
<html>
<h3> Test connection to the database </h3>
<?php
\$connect = fsockopen("$dbString", 3306, \$errno, \$errstr, .1);
if (\$connect)
{
    echo "The database is up!";
    return true;
}
else
{
    echo "I can't talk to the database :(";
}
?>
</html>
EOL

service httpd restart
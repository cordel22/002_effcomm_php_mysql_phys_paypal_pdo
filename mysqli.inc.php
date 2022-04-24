
<?php
//  Set the database access information as constants:
DEFINE('DB_USER', 'root');
DEFINE('DB_PASSWORD', 'root');
DEFINE('DB_HOST', 'localhost');
DEFINE('DB_NAME', 'ecommerce2');

//    error reporting
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

//  Make the connection:
$dbc = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

//  Set the character set:

mysqli_set_charset($dbc, 'utf8');


//  for more typess of users:
/* 
$user = 'general';
require(MYSQL);

DEFINE('DB_HOST', 'localhost');
DEFINE('DB_NAME', 'ecommerce2');
if (isset($user) && ('user' == 'general') ) {
  DEFINE('DB_USER', 'username');
  DEFINE('DB_PASSWORD', 'password');
} elseif (isset($user) && ('user' == 'cart')) { //...
  DEFINE('DB_USER', 'otherUser');
  DEFINE('DB_PASSWORD','otherPassword');
}
 */



//  Omit the closing PHP tag to avoid 'headers already sent' error!


<?php
/* require('./includes/config.inc.php'); */
require('./htdocs/includes/config.php');

if (isset($_GET['type']) && ($_GET['type'] == 'goodies')) {
  $page_title = 'Our Goodies, by Category';
  $sp_type = 'other';
  $type = 'goodies';
} else {  //  Default is coffee!!
  $page_title = 'Our Coffee Products';
  $type = $sp_type = 'coffee';
}
include('./htdocs/includes/header.html');
require(MYSQL);

//  $r = mysqli_query($dbc, "CALL select_categories('$sp_type')");
$r = $pdo->query("CALL select_categories('$sp_type')");

//  or offline debugging
//  if (!$r) echo mysqli_error($dbc);
if (!$r) echo $pdo->errorInfo();

$row_count = $r->rowCount();

//  if (mysqli_num_rows($r) >= 1) {
if ($row_count > 0) {
  include('./htdocs/views/list_categories.html');
} else {  //  Include the eror page;
  include('./htdocs/views/error.html');
}

?>



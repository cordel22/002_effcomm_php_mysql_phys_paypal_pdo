
<?php
require('./htdocs/includes/config.php');
$page_title = 'Coffee - Wouldn\'t You Love a Cup Right Now?';
include('./htdocs/includes/header.html');
require(MYSQL);
//  $r = mysqli_query($dbc, "CALL select_sale_items(false)");
$r = $pdo->query("CALL select_sale_items(false)");
include('./htdocs/views/home.html');
include('./htdocs/includes/footer.html');

?>




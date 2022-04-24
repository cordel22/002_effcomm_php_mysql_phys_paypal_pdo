
<?php
require('./htdocs/includes/config.php');

if (isset($_COOKIE['SESSION'])) {
  $uid = $_COOKIE['SESSION'];
} else {
  $uid = md5(uniqid('biped', true));
}

setcookie('SESSION', $uid, time() + (60 * 60 * 24 * 30));

$page_title = 'Coffee - Your Wish List';
include('./htdocs/includes/header.html');

require(MYSQL);
include('./htdocs/includes/product_functions.inc.php');

if (isset($_GET['sku'])) {
  list($sp_type, $pid) = parse_sku($_GET['sku']);
}

if (isset($sp_type, $pid, $_GET['action']) && ($_GET['action'] == 'add')) {
  //  $r = mysqli_query($dbc, "CALL remove_from_wish_list('$uid','$sp_type',$pid)");
  $r = $pdo->query("CALL remove_from_wish_list('$uid','$sp_type',$pid)");
} elseif (
  isset($sp_type, $pid, $_GET['action'], $_GET['qty']) &&
  ($_GET['action'] == 'move')
) {
  $qty = (filter_var(
    $_GET['qty'],
    FILTER_VALIDATE_INT,
    array('min_range' => 1)
  )) ? $_GET['qty'] : 1;
  //  $r = mysqli_query($dbc, "CALL add_to_wish_list('$uid','$sp_type',$pid,$qty)");
  //  $r = mysqli_query($dbc, "CALL remove_from_cart('$uid','$sp_type',$pid)");
  $r = $pdo->query("CALL add_to_wish_list('$uid','$sp_type',$pid,$qty)");
  $r = $pdo->query("CALL remove_from_cart('$uid','$sp_type',$pid)");

  /* if (!$r) echo mysqli_error($dbc); */
} elseif (isset($_POST['quantity'])) {
  foreach ($_POST['quantity'] as $sku => $qty) {
    list($sp_type, $pid) = parse_sku($sku);
    if (isset($sp_type, $pid)) {
      $qty = (filter_var($qty, FILTER_VALIDATE_INT, array('min_range' => 0))) ? $qty : 1;
      //  $r = mysqli_query($dbc, "CALL update_wish_list('$uid','$sp_type',$pid,$qty)");
      $r = $pdo->query("CALL update_wish_list('$uid','$sp_type',$pid,$qty)");
    }
  }
} //  END OF MAIn IF.
echo ' actually, the get_wish_list_contents dont exist but are similar to the cart procedure\n
  so u still gotta build em\n';
/*  debug
$r = mysqli_query($dbc, "CALL get_wish_list_contents('$uid')");

if (mysqli_num_rows($r) > 0) {
  include('./htdocs/views/wishlist.html');
} else {  //  Empty crt!    */
include('./htdocs/views/emptylist.html');
//  a\ tu konci debug: }

include('./htdocs/includes/footer.html');
?>


<?php
require('./htdocs/includes/config.php');

$type = $sp_type = $sp_cat = $category = false;
if (
  isset($_GET['type'], $_GET['category'], $_GET['id']) &&
  filter_var($_GET['id'], FILTER_VALIDATE_INT, array('min_range' => 1))
) {
  $category = $_GET['category'];
  $sp_cat = $_GET['id'];

  if ($_GET['type'] == 'goodies') {
    $sp_type = 'other';
    $type = 'goodies';
  } elseif ($_GET['type'] == 'coffee') {
    $type = $sp_type = 'coffee';
  }

  if (!$type || !$sp_type || !$sp_cat || !$category) {
    $page_title = 'Error!';
    include('./htdocs/includes/header.html');
    include('./htdocs/views/error.html');
    include('./htdocs/includes/footer.html');
    exit();
  }

  $page_title = ucfirst($type) . 'to Buy::' . $category;
  include('./htdocs/includes/header.html');

  require(MYSQL);
  //  $r = mysqli_query($dbc, "CALL select_products('$sp_type', $sp_cat)");
  $r = $pdo->query("CALL select_products('$sp_type', $sp_cat)");

  $row_count = $r->rowCount();

  //  if (mysqli_num_rows($r) >= 1) {
  if ($row_count > 0) {
    if ($type == 'goodies') {
      include('./htdocs/views/list_products.html');
    } elseif ($type == 'coffee') {
      include('./htdocs/views/list_coffees.html');
    }
  } else {
    include('./htdocs/views/noproducts.html');
  }
} //  naviac

include('./htdocs/includes/footer.html')
?>


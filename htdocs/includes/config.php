
<?php

//  Are we live?
$live = false;

//  Errors are emailed here:
$contact_email = 'cordelfenevall@gmail.com';

//  Determine location of files and the URL of the site:

// define('BASE_URI', 'C:\Users\Sisi\Desktop\akcia_14_07_21\php-14-07-21\effcomm_php_mysql\002_effcomm_php_mysql_phys'/* '/path/to/Web/parent/folder/' */);
// define('BASE_URL', 'http://localhost:3000/'/* 'www.example.com/' */);
// define('MYSQL', 'C:\Users\Sisi\Desktop\akcia_14_07_21\php-14-07-21\effcomm_php_mysql\002_effcomm_php_mysql_phys\mysqli.inc.php'/* '/path/to/mysql.inc.php' */);

define('BASE_URI', 'C:\Users\Sisi\Desktop\akcia_14_07_21\php-14-07-21\effcomm_php_mysql\002_effcomm_php_mysql_phys_paypal_pdo'/* '/path/to/Web/parent/folder/' */);
define('BASE_URL', 'http://localhost:3000/'/* 'www.example.com/' */);
define('MYSQL', 'C:\Users\Sisi\Desktop\akcia_14_07_21\php-14-07-21\effcomm_php_mysql\002_effcomm_php_mysql_phys_paypal_pdo\pdo.php'/* '/path/to/mysql.inc.php' */);



//  Function for handling errors:
function my_error_handler($e_number = null, $e_message = null, $e_file = null, $e_line = null, $e_vars = null)
{
  global $live, $contact_email;

  //  Build the error message:
  $message = "An error occurred in script '$e_file' on line 
        $e_line:\n$e_message\n";

  //  Add the backtrace:
  $message .= "<pre>" . print_r(debug_backtrace(), 1) . "</pre>\n";

  if (!$live) { //  Show the error in the browser.
    echo '<div class="error">' . nl2br($message) . '</div>';
  } else {  //  Development (print the error).
    //  Send the error in an email:
    error_log($message, 1, $contact_email, 'From: cordelfenevall@gmail.com');
    //  Only print an error message in the browser, if the error isn't a notice:
    if ($e_number != E_NOTICE) {
      echo '<div class="error">A system error occurred.
            We apologize for the inconvenience.</div>';
    }
  } //  End of $live IF-ELSE.

  return true; // So that PHP doesn't try to handle the error, too.
} //  End of my_error_handler() definition.

//  Use my error handler:
set_error_handler('my_error_handler');

//  Omit the closing PHP tag to avoid 'headers already sent' errors!

/*
    Every PHP script in this site uses
view files—separate HTML pages—to display content. Technically, a separate
view file should be created for displaying errors, too. Without such a file, you
may see errors displayed in odd places. I’ve omitted a dedicated error view file
here so as not to complicate things even further, but you can find it among the
downloadable code available at www.DMCInsights.com/ecom/.
    */

//  debug
//$config = "config is here!";
//  end debug
?>



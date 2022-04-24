-- --------------------------------------------------------
-- Hostiteľ:                     127.0.0.1
-- Verze serveru:                10.6.4-MariaDB - mariadb.org binary distribution
-- OS serveru:                   Win32
-- HeidiSQL Verzia:              11.3.0.6295
-- --------------------------------------------------------

/* pica
cpses_vlxi4plh91
These was the admin reply
 was this a pre-existing database they they brought over from some other location?
those errors usually mean their definers are set incorrectly.
 CREATE DEFINER=`cpses_vlxi4plh91`@`localhost` PROCEDURE `add_to_cart`(uid CHAR(32),type VARCHAR(6),pid
        MEDIUMINT,qty TINYINT)

where did cpses_vlxi4plh91 come from?

a potom

Thanks for waiting. The admins request to check your database and make sure the definer is set correctly. 
 
  truly understand your situation but according to the admins you need to set the definer since it's a customer made database. Thanks for understanding.
 
 
 */

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Exportování struktury databáze pro
-- CREATE DATABASE IF NOT EXISTS `ecommerce2` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
-- USE `ecommerce2`;

-- Exportování struktury pro procedura ecommerce2.add_customer
DELIMITER //
CREATE PROCEDURE `add_customer`(e VARCHAR(80),f VARCHAR(20),
	l VARCHAR(40),a1 VARCHAR(80),a2 VARCHAR(80),c VARCHAR(60),
	s CHAR(2),z MEDIUMINT,p INT,OUT cid INT)
BEGIN
	INSERT INTO customers VALUE (NULL,e,f,l,a1,a2,c,s,z,p,NOW());
	SELECT LAST_INSERT_ID() INTO cid;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.add_order
DELIMITER //
CREATE PROCEDURE `add_order`(cid INT,uid CHAR(32), ship DECIMAL(5,2),
	cc MEDIUMINT,OUT total DECIMAL(7,2),OUT oid INT)
BEGIN
	DECLARE subtotal DECIMAL(7,2);
	INSERT INTO orders (customer_id,shipping,credit_card_number,
		order_date) VALUES (cid,ship,cc,NOW());
	SELECT LAST_INSERT_ID() INTO oid;
	INSERT INTO order_contents(order_id,product_type,product_id,
		quantity,price_per) SELECT oid,c.product_type,c.product_id,
		c.quantity,IFNULL(sales.price,ncp.price) FROM carts AS c INNER JOIN
		non_coffee_products AS ncp ON c.product_id=ncp.id LEFT OUTER JOIN
		sales ON (sales.product_id=ncp.id AND sales.product_type='other'
		AND ((NOW() BETWEEN sales.start_date AND sales.end_date)
		OR (NOW() > sales.start_date AND sales.end_date IS NULL))) WHERE
		c.product_type="other" AND c.user_session_id=uid UNION SELECT
		oid, c.product_type,c.product_id,c.quantity,IFNULL(sales.price,
		sc.price)FROM carts AS c INNER JOIN specific_coffees AS sc ON
		c.product_id=sc.id LEFT OUTER JOIN sales ON (sales.product_id=sc.id
		AND sales.product_type='coffee' AND ((NOW() BETWEEN
		sales.start_date AND sales.end_date) OR (NOW() > sales.start_date
		AND sales.end_date IS NULL)))WHERE c.product_type="coffee" AND
		c.user_session_id=uid;
	SELECT SUM(quantity*price_per) INTO subtotal FROM order_contents
		WHERE order_id=oid;
	UPDATE orders SET total = (subtotal + ship) WHERE id=oid;
	SELECT (subtotal + ship) INTO total;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.add_to_cart
DELIMITER //
CREATE PROCEDURE `add_to_cart`(uid CHAR(32),type VARCHAR(6),pid
	MEDIUMINT,qty TINYINT)
BEGIN
	DECLARE cid INT;
	SELECT id INTO cid FROM carts WHERE user_session_id=uid AND
		product_type=type AND product_id=pid;
	IF cid > 0 THEN
		UPDATE carts SET quantity=quantity+qty,date_modified=NOW()
			WHERE id=cid;
	ELSE
		INSERT INTO carts (user_session_id,product_type,product_id,quantity)
			VALUES (uid,type,pid,qty);
	END IF;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.add_transaction
DELIMITER //
CREATE PROCEDURE `add_transaction`(oid INT,trans_type VARCHAR(18),
	amt DECIMAL(7,2),rc TINYINT,rrc TINYTEXT,tid BIGINT, r TEXT)
BEGIN
	INSERT INTO transactions VALUES (NULL,oid,trans_type,amt,rc,rrc,tid,r,NOW());
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.carts
CREATE TABLE IF NOT EXISTS `carts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `quantity` tinyint(3) unsigned NOT NULL,
  `user_session_id` char(32) NOT NULL,
  `product_type` enum('coffee','other') NOT NULL,
  `product_id` mediumint(8) unsigned NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_modified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `product_type` (`product_type`,`product_id`),
  KEY `user_session_id` (`user_session_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.carts: 1 rows
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` (`id`, `quantity`, `user_session_id`, `product_type`, `product_id`, `date_created`, `date_modified`) VALUES
	(4, 3, '27669d5fa355a7a5d7b05464ba306940', 'coffee', 14, '2022-03-31 18:47:50', '2022-03-31 23:33:10');
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;

-- Exportování struktury pro procedura ecommerce2.clear_cart
DELIMITER //
CREATE PROCEDURE `clear_cart`(uid CHAR(32))
BEGIN
	DELETE FROM carts WHERE user_session_id=uid;
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.customers
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(80) NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(40) NOT NULL,
  `address1` varchar(80) NOT NULL,
  `address2` varchar(80) DEFAULT NULL,
  `city` varchar(60) NOT NULL,
  `state` char(2) NOT NULL,
  `zip` mediumint(5) unsigned zerofill NOT NULL,
  `phone` int(11) NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.customers: 9 rows
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(1, 'ferko@mrkvicka.com', 'ferko', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-09 23:34:27');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(2, 'ferko@mrkvicka.com', 'ferko', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-09 23:35:17');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(3, 'ferko@mrkvicka.com', 'ferko', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-09 23:35:20');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(4, 'ferko@mrkvicka.com', 'ferko', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-09 23:35:59');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(5, 'ferko@mrkvicka.com', 'ferko', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-09 23:37:14');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(6, 'feri@mrkvicka.com', 'feri', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-10 01:24:22');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(7, 'ferko@mrkvicka.com', 'feri', 'mrkvicka', 'Jelenia', '', 'Austin', 'TX', 81105, 660183484, '2022-03-10 01:49:30');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(8, 'sisehkc@hotmail.com', 'kubulo', 'kubo', 'Main Street', '', 'New York', 'NY', 81105, 252492810, '2022-03-31 19:42:11');
INSERT INTO `customers` (`id`, `email`, `first_name`, `last_name`, `address1`, `address2`, `city`, `state`, `zip`, `phone`, `date_created`) VALUES
	(9, 'jebinko@jebko.com', 'jebinko', 'jebko', 'Main Street', '', 'New York', 'NY', 81105, 252492810, '2022-03-31 23:35:39');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.general_coffees
CREATE TABLE IF NOT EXISTS `general_coffees` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(40) NOT NULL,
  `description` tinytext DEFAULT NULL,
  `image` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type` (`category`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.general_coffees: 3 rows
/*!40000 ALTER TABLE `general_coffees` DISABLE KEYS */;
INSERT INTO `general_coffees` (`id`, `category`, `description`, `image`) VALUES
	(1, 'Original Blend', 'Our original blend, featuring a quality mixture of\r\n		bean and a medium roast for a rich color and smooth flavor.', 'original_coffee.jpg');
INSERT INTO `general_coffees` (`id`, `category`, `description`, `image`) VALUES
	(2, 'Dark Roast', 'Our darkest, non-espresso roast, with a full flavor and a\r\n		slightly bitter aftertaste.', 'dark_roast.jpg');
INSERT INTO `general_coffees` (`id`, `category`, `description`, `image`) VALUES
	(3, 'Kona', 'A real treat! Kona coffee, fresh from the lush mountains of\r\n		Hawaii. Smooth in flavor and perfectly roasted!', 'kona.jpg');
/*!40000 ALTER TABLE `general_coffees` ENABLE KEYS */;

-- Exportování struktury pro procedura ecommerce2.get_order_contents
DELIMITER //
CREATE PROCEDURE `get_order_contents`(oid INT)
BEGIN
	SELECT oc.quantity,oc.price_per,(oc.quantity*oc.price_per) AS subtotal,
ncc.category,ncp.name,o.total,o.shipping
FROM order_contents AS oc
INNER JOIN non_coffee_products AS ncp ON oc.product_id=ncp.id
INNER JOIN non_coffee_categories AS ncc
ON ncc.id=ncp.non_coffee_category_id
INNER JOIN orders AS o ON oc.order_id=o.id
WHERE oc.product_type="other" AND oc.order_id=oid
	UNION
	SELECT oc.quantity,oc.price_per,(oc.quantity*oc.price_per),
gc.category,CONCAT_WS("-",s.size,sc.caf_decaf,sc.ground_whole),
	o.total,o.shipping
FROM order_contents AS oc
INNER JOIN specific_coffees AS sc ON oc.product_id=sc.id
INNER JOIN sizes AS s ON s.id=sc.size_id
INNER JOIN general_coffees AS gc ON gc.id=sc.general_coffee_id

INNER JOIN orders AS o ON oc.order_id=o.id
WHERE oc.product_type="coffee" AND oc.order_id=oid;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.get_shopping_cart_contents
DELIMITER //
CREATE PROCEDURE `get_shopping_cart_contents`(uid CHAR(32))
BEGIN
	SELECT CONCAT("O",ncp.id) AS sku,c.quantity, ncc.category,
ncp.name, ncp.price, ncp.stock, sales.price AS sale_price
FROM carts AS c
INNER JOIN non_coffee_products AS ncp ON c.product_id=ncp.id
INNER JOIN non_coffee_categories AS ncc ON ncc.id=ncp.non_coffee_category_id
LEFT OUTER JOIN sales ON
(sales.product_id=ncp.id AND sales.product_type='other' AND
((NOW() BETWEEN sales.start_date AND sales.end_date) OR (NOW()>
	sales.start_date AND sales.end_date IS NULL)))
WHERE c.product_type="other" AND c.user_session_id=uid
	UNION
	SELECT CONCAT("C",sc.id),c.quantity,gc.category,
CONCAT_WS("-",s.size,sc.caf_decaf,sc.ground_whole),sc.price,
sc.stock,sales.price
FROM carts AS c
INNER JOIN specific_coffees AS sc ON c.product_id=sc.id
INNER JOIN sizes AS s ON s.id=sc.size_id
INNER JOIN general_coffees AS gc ON gc.id=sc.general_coffee_id
LEFT OUTER JOIN sales ON
(sales.product_id=sc.id AND sales.product_type='coffee' AND
((NOW() BETWEEN sales.start_date AND sales.end_date) OR (NOW()>
	sales.start_date AND sales.end_date IS NULL)))
WHERE c.product_type="coffee" AND c.user_session_id=uid;
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.non_coffee_categories
CREATE TABLE IF NOT EXISTS `non_coffee_categories` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(40) NOT NULL,
  `description` tinytext NOT NULL,
  `image` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `category` (`category`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.non_coffee_categories: 4 rows
/*!40000 ALTER TABLE `non_coffee_categories` DISABLE KEYS */;
INSERT INTO `non_coffee_categories` (`id`, `category`, `description`, `image`) VALUES
	(1, 'Edibles', 'A wonderful assortment of goodies to eat. Includes biscotti,\r\n		baklava, lemon bars, and more!', 'goodies.jpg');
INSERT INTO `non_coffee_categories` (`id`, `category`, `description`, `image`) VALUES
	(2, 'Gift Baskets', 'Gift baskets for any occasion! Inluding our many coffees\r\n		and other goodies.', 'gift_basket.jpg');
INSERT INTO `non_coffee_categories` (`id`, `category`, `description`, `image`) VALUES
	(3, 'Mugs', 'A selection of lovely mugs for enjoying your coffee, tea, hot\r\n		cocoa or other hot beverages.', '781426_32573620.jpg');
INSERT INTO `non_coffee_categories` (`id`, `category`, `description`, `image`) VALUES
	(4, 'Books', 'Our recommended books about coffee, goodies, plus anything\r\n		written by Larry Ullman!', 'books.jpg');
/*!40000 ALTER TABLE `non_coffee_categories` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.non_coffee_products
CREATE TABLE IF NOT EXISTS `non_coffee_products` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `non_coffee_category_id` tinyint(3) unsigned NOT NULL,
  `name` varchar(60) NOT NULL,
  `description` tinytext DEFAULT NULL,
  `image` varchar(45) NOT NULL,
  `price` decimal(5,2) unsigned NOT NULL,
  `stock` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `non_coffee_category_id` (`non_coffee_category_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.non_coffee_products: 4 rows
/*!40000 ALTER TABLE `non_coffee_products` DISABLE KEYS */;
INSERT INTO `non_coffee_products` (`id`, `non_coffee_category_id`, `name`, `description`, `image`, `price`, `stock`, `date_created`) VALUES
	(1, 3, 'Pretty Flower Coffee Mug', 'A pretty coffee mug with a flower design on a \r\n	white background.', 'd9996aee5639209b3fb618b07e10a34b27baad12.jpg', 6.50, 100, '2022-02-22 22:54:55');
INSERT INTO `non_coffee_products` (`id`, `non_coffee_category_id`, `name`, `description`, `image`, `price`, `stock`, `date_created`) VALUES
	(2, 3, 'Red Dragon Mug', 'An elaborate, painted gold dragon on\r\n	a red background. With partially detached, fancy handle.', '847a1a3bef0fb5c2f2299b06dd63669000f5c6c4.jpg', 7.95, 4, '2022-02-22 22:54:55');
INSERT INTO `non_coffee_products` (`id`, `non_coffee_category_id`, `name`, `description`, `image`, `price`, `stock`, `date_created`) VALUES
	(3, 3, 'juggs', 'yummies', 'd6c85738cdff89f728e04cb3dbc4fd7d8daa0755.jpg', 500.00, 6, '2022-03-08 22:49:46');
INSERT INTO `non_coffee_products` (`id`, `non_coffee_category_id`, `name`, `description`, `image`, `price`, `stock`, `date_created`) VALUES
	(4, 1, 'hot chocolate', 'lickies', 'a36c7a1944cada71697ba5197d1247b90da8970b.jpg', 500.00, 2, '2022-03-08 22:53:51');
/*!40000 ALTER TABLE `non_coffee_products` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` int(10) unsigned NOT NULL,
  `total` decimal(7,2) unsigned DEFAULT NULL,
  `shipping` decimal(5,2) unsigned NOT NULL,
  `credit_card_number` mediumint(4) unsigned NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `customer_id` (`customer_id`),
  KEY `order_date` (`order_date`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.orders: ~16 rows (přibližně)
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(1, 5, 2303.00, 303.00, 27, '2022-03-09 23:44:54');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(2, 5, 2303.00, 303.00, 27, '2022-03-09 23:47:29');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(3, 5, 2303.00, 303.00, 27, '2022-03-10 00:04:45');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(4, 5, 2303.00, 303.00, 27, '2022-03-10 00:18:28');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(5, 5, 2303.00, 303.00, 27, '2022-03-10 00:32:58');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(6, 5, 2303.00, 303.00, 27, '2022-03-10 00:34:52');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(7, 5, 2303.00, 303.00, 27, '2022-03-10 00:43:11');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(8, 5, 2303.00, 303.00, 27, '2022-03-10 00:55:06');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(9, 5, 2303.00, 303.00, 27, '2022-03-10 00:56:41');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(10, 5, 2303.00, 303.00, 27, '2022-03-10 00:58:12');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(11, 5, 2303.00, 303.00, 27, '2022-03-10 01:02:52');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(12, 6, 2878.00, 378.00, 27, '2022-03-10 01:24:40');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(13, 7, 3338.00, 438.00, 27, '2022-03-10 01:49:48');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(14, 9, 31.32, 7.32, 4444, '2022-03-31 23:41:47');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(15, 9, 31.32, 7.32, 4444, '2022-03-31 23:53:11');
INSERT INTO `orders` (`id`, `customer_id`, `total`, `shipping`, `credit_card_number`, `order_date`) VALUES
	(16, 9, 31.32, 7.32, 4444, '2022-03-31 23:53:43');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.order_contents
CREATE TABLE IF NOT EXISTS `order_contents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int(10) unsigned NOT NULL,
  `product_type` enum('coffee','other') DEFAULT NULL,
  `product_id` mediumint(8) unsigned NOT NULL,
  `quantity` tinyint(3) unsigned NOT NULL,
  `price_per` decimal(5,2) unsigned NOT NULL,
  `ship_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ship_date` (`ship_date`),
  KEY `product_type` (`product_type`,`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.order_contents: ~18 rows (přibližně)
/*!40000 ALTER TABLE `order_contents` DISABLE KEYS */;
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(1, 1, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(2, 2, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(3, 3, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(4, 4, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(5, 5, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(6, 6, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(7, 7, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(8, 8, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(9, 9, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(10, 10, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(11, 11, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(12, 12, 'other', 3, 5, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(13, 12, 'other', 4, 1, 500.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(15, 13, 'other', 3, 6, 400.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(16, 13, 'other', 4, 1, 500.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(17, 14, 'coffee', 14, 3, 8.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(18, 15, 'coffee', 14, 3, 8.00, NULL);
INSERT INTO `order_contents` (`id`, `order_id`, `product_type`, `product_id`, `quantity`, `price_per`, `ship_date`) VALUES
	(19, 16, 'coffee', 14, 3, 8.00, NULL);
/*!40000 ALTER TABLE `order_contents` ENABLE KEYS */;

-- Exportování struktury pro procedura ecommerce2.remove_from_cart
DELIMITER //
CREATE PROCEDURE `remove_from_cart`(uid CHAR(32),type VARCHAR(6),
	pid MEDIUMINT)
BEGIN
	DELETE FROM carts WHERE user_session_id=uid AND product_type=type
		AND product_id=pid;
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.sales
CREATE TABLE IF NOT EXISTS `sales` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `product_type` enum('coffee','other') DEFAULT NULL,
  `product_id` mediumint(8) unsigned NOT NULL,
  `price` decimal(5,2) unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `start_date` (`start_date`),
  KEY `product_type` (`product_type`,`product_id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.sales: 7 rows
/*!40000 ALTER TABLE `sales` DISABLE KEYS */;
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(1, 'other', 1, 5.00, '2010-08-16', '2010-08-31');
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(2, 'coffee', 7, 7.00, '2010-08-19', NULL);
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(3, 'coffee', 9, 13.00, '2010-08-19', '2010-08-26');
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(4, 'other', 2, 7.00, '2010-08-22', NULL);
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(5, 'coffee', 8, 13.00, '2010-08-22', '2010-08-31');
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(6, 'coffee', 10, 30.00, '2010-08-22', '2010-09-30');
INSERT INTO `sales` (`id`, `product_type`, `product_id`, `price`, `start_date`, `end_date`) VALUES
	(7, 'other', 3, 400.00, '2022-03-09', '2022-03-11');
/*!40000 ALTER TABLE `sales` ENABLE KEYS */;

-- Exportování struktury pro procedura ecommerce2.select_categories
DELIMITER //
CREATE PROCEDURE `select_categories`(TYPE VARCHAR(6))
BEGIN
	IF TYPE = 'coffee' THEN
		SELECT * FROM general_coffees ORDER BY category;
	ELSEIF TYPE = 'other' THEN
		SELECT * FROM non_coffee_categories ORDER BY category;
	END IF;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.select_products
DELIMITER //
CREATE PROCEDURE `select_products`(TYPE VARCHAR(6), cat TINYINT)
BEGIN
	IF TYPE = 'coffee' THEN
		SELECT gc.description,gc.image, CONCAT("C",sc.id) AS sku,
			CONCAT_WS("-",s.size,sc.caf_decaf,sc.ground_whole,sc.price)
			AS name,sc.stock, sc.price, sales.price AS sale_price 
			FROM specific_coffees AS sc INNER JOIN sizes
			AS s ON s.id=sc.size_id INNER JOIN general_coffees AS gc ON
			gc.id=sc.general_coffee_id 
			LEFT OUTER JOIN sales ON (sales.product_id=sc.id
			AND sales.product_type='coffee' AND
			((NOW() BETWEEN sales.start_date AND sales.end_date)
			OR (NOW() > sales.start_date AND sales.end_date IS NULL)))
			WHERE general_coffee_id=cat AND stock>0
			
ORDER BY NAME;
	ELSEIF TYPE = 'other' THEN
		SELECT ncc.description AS g_description,ncc.image AS g_image,
			CONCAT("O",ncp.id) AS sku, ncp.name, ncp.description,
			ncp.image,ncp.price,ncp.stock, sales.price AS sale_price
			FROM non_coffee_products AS
			ncp INNER JOIN non_coffee_categories AS ncc ON
			ncc.id=ncp.non_coffee_category_id
			LEFT OUTER JOIN sales ON (sales.product_id=ncp.id
			AND sales.product_type='other' AND
			((NOW() BETWEEN sales.start_date AND sales.end_date) OR (NOW() >
			sales.start_date AND sales.end_date IS NULL)))
WHERE non_coffee_category_id=cat ORDER BY date_created DESC;
	END IF;
END//
DELIMITER ;

-- Exportování struktury pro procedura ecommerce2.select_sale_items
DELIMITER //
CREATE PROCEDURE `select_sale_items`(get_all BOOLEAN)
BEGIN
IF get_all = 1 THEN
SELECT CONCAT("O",ncp.id) AS sku,sa.price AS sale_price,ncc.category,
	ncp.image,ncp.name,ncp.price,ncp.stock,ncp.description FROM sales
	AS sa INNER JOIN non_coffee_products AS ncp ON
	sa.product_id=ncp.id INNER JOIN non_coffee_categories AS ncc ON
	ncc.id=ncp.non_coffee_category_id WHERE sa.product_type="other"
	AND ((NOW() BETWEEN sa.start_date AND sa.end_date) OR (NOW() >
	sa.start_date AND sa.end_date IS NULL))
UNION SELECT CONCAT("C",sc.id),sa.price,gc.category,gc.image,
CONCAT_WS("-",s.size,sc.caf_decaf,sc.ground_whole),sc.price,
sc.stock,gc.description FROM sales AS sa INNER JOIN specific_coffees
AS sc ON sa.product_id=sc.id INNER JOIN sizes AS s ON s.id=sc.size_id
INNER JOIN general_coffees AS gc ON gc.id=sc.general_coffee_id WHERE
sa.product_type="coffee" AND ((NOW() BETWEEN sa.start_date AND
sa.end_date) OR (NOW() > sa.start_date AND sa.end_date IS NULL));
ELSE
(SELECT CONCAT("O",ncp.id) AS sku,sa.price AS sale_price,
	ncc.category,ncp.image,ncp.name FROM sales AS sa INNER JOIN
	non_coffee_products AS ncp ON sa.product_id=ncp.id INNER JOIN
	non_coffee_categories AS ncc ON ncc.id=ncp.non_coffee_category_id
	WHERE sa.product_type="other" AND ((NOW() BETWEEN sa.start_date
	AND sa.end_date) OR (NOW() > sa.start_date AND sa.end_date
	IS NULL)) ORDER BY RAND() LIMIT 2) UNION (SELECT CONCAT("C",
	sc.id),sa.price,gc.category,gc.image, CONCAT_WS("-",s.size,
	sc.caf_decaf,sc.ground_whole) FROM sales AS sa INNER JOIN
	specific_coffees AS sc ON sa.product_id=sc.id INNER JOIN sizes AS s
	ON s.id=sc.size_id INNER JOIN general_coffees AS gc ON
	gc.id=sc.general_coffee_id WHERE sa.product_type="coffee" AND
	((NOW() BETWEEN sa.start_date AND sa.end_date) OR (NOW() >
	sa.start_date AND sa.end_date IS NULL)) ORDER BY RAND() LIMIT 2);
END IF;
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.sizes
CREATE TABLE IF NOT EXISTS `sizes` (
  `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `size` varchar(40) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `size` (`size`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.sizes: 5 rows
/*!40000 ALTER TABLE `sizes` DISABLE KEYS */;
INSERT INTO `sizes` (`id`, `size`) VALUES
	(1, '2 oz. Sample');
INSERT INTO `sizes` (`id`, `size`) VALUES
	(2, 'Half Pound');
INSERT INTO `sizes` (`id`, `size`) VALUES
	(3, '1 lb.');
INSERT INTO `sizes` (`id`, `size`) VALUES
	(4, '2 lbs.');
INSERT INTO `sizes` (`id`, `size`) VALUES
	(5, '5 lbs.');
/*!40000 ALTER TABLE `sizes` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.specific_coffees
CREATE TABLE IF NOT EXISTS `specific_coffees` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `general_coffee_id` tinyint(3) unsigned NOT NULL,
  `size_id` tinyint(3) unsigned NOT NULL,
  `caf_decaf` enum('caf','decaf') DEFAULT NULL,
  `ground_whole` enum('ground','whole') DEFAULT NULL,
  `price` decimal(5,2) unsigned NOT NULL,
  `stock` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `general_coffee_id` (`general_coffee_id`),
  KEY `size` (`size_id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.specific_coffees: 21 rows
/*!40000 ALTER TABLE `specific_coffees` DISABLE KEYS */;
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(1, 3, 1, 'caf', 'ground', 2.00, 20, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(2, 3, 2, 'caf', 'ground', 4.50, 30, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(3, 3, 2, 'decaf', 'ground', 5.00, 20, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(4, 3, 3, 'caf', 'ground', 8.00, 50, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(5, 3, 3, 'decaf', 'ground', 8.50, 20, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(6, 3, 3, 'caf', 'whole', 7.50, 50, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(7, 3, 3, 'decaf', 'whole', 8.00, 20, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(8, 3, 4, 'caf', 'whole', 15.00, 30, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(9, 3, 4, 'decaf', 'whole', 15.50, 15, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(10, 3, 5, 'caf', 'whole', 32.50, 5, '2022-02-22 23:08:01');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(11, 3, 1, 'caf', 'ground', 2.00, 20, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(12, 3, 2, 'caf', 'ground', 4.50, 30, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(13, 3, 2, 'decaf', 'ground', 5.00, 20, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(14, 3, 3, 'caf', 'ground', 8.00, 50, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(15, 3, 3, 'decaf', 'ground', 8.50, 20, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(16, 3, 3, 'caf', 'whole', 7.50, 50, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(17, 3, 3, 'decaf', 'whole', 8.00, 20, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(18, 3, 4, 'caf', 'whole', 15.00, 30, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(19, 3, 4, 'decaf', 'whole', 15.50, 15, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(20, 3, 5, 'caf', 'whole', 32.50, 5, '2022-02-22 23:08:08');
INSERT INTO `specific_coffees` (`id`, `general_coffee_id`, `size_id`, `caf_decaf`, `ground_whole`, `price`, `stock`, `date_created`) VALUES
	(21, 2, 2, 'decaf', 'whole', 100.00, 2, '2022-03-09 00:34:12');
/*!40000 ALTER TABLE `specific_coffees` ENABLE KEYS */;

-- Exportování struktury pro tabulka ecommerce2.transactions
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` int(10) unsigned NOT NULL,
  `type` varchar(18) NOT NULL,
  `amount` decimal(7,2) NOT NULL,
  `response_code` tinyint(1) unsigned NOT NULL,
  `response_reason` tinytext DEFAULT NULL,
  `transaction_id` bigint(20) unsigned NOT NULL,
  `response` text NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.transactions: 0 rows
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;

-- Exportování struktury pro procedura ecommerce2.update_cart
DELIMITER //
CREATE PROCEDURE `update_cart`(
	IN `uid` CHAR(32),
	IN `type` VARCHAR(6),
	IN `pid` MEDIUMINT,
	IN `qty` TINYINT
)
BEGIN
	IF qty > 0 THEN
		UPDATE carts SET quantity=qty,date_modified=NOW() WHERE
			user_session_id=uid AND product_type=type AND product_id=pid;
	ELSEIF qty = 0 THEN
		CALL remove_from_cart (uid,type,pid);
	END IF;
END//
DELIMITER ;

-- Exportování struktury pro tabulka ecommerce2.wish_lists
CREATE TABLE IF NOT EXISTS `wish_lists` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `quantity` tinyint(3) unsigned NOT NULL,
  `user_session_id` char(32) NOT NULL,
  `product_type` enum('coffee','other') DEFAULT NULL,
  `product_id` mediumint(8) unsigned NOT NULL,
  `date_created` timestamp NOT NULL DEFAULT current_timestamp(),
  `date_modified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `product_type` (`product_type`,`product_id`),
  KEY `user_session_id` (`user_session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

-- Exportování dat pro tabulku ecommerce2.wish_lists: 0 rows
/*!40000 ALTER TABLE `wish_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `wish_lists` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

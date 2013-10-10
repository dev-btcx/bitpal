-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Июл 24 2013 г., 09:56
-- Версия сервера: 5.6.12-log
-- Версия PHP: 5.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `bitcoin_app_development`
--
CREATE DATABASE IF NOT EXISTS `bitcoin_app_development` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `bitcoin_app_development`;

-- --------------------------------------------------------

--
-- Структура таблицы `internal_transactions`
--

CREATE TABLE IF NOT EXISTS `internal_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_type` int(11) NOT NULL DEFAULT '0',
  `amount` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `merchant_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `internal_transactions_merchant_id_fk` (`merchant_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

-- --------------------------------------------------------

--
-- Структура таблицы `merchants`
--

CREATE TABLE IF NOT EXISTS `merchants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(50) NOT NULL,
  `bitcoin_address` varchar(50) NOT NULL,
  `api_key` varchar(255) NOT NULL,
  `password_digest` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Структура таблицы `orders`
--

CREATE TABLE IF NOT EXISTS `orders` (
  `id` binary(16) NOT NULL,
  `bitcoin_address` varchar(50) NOT NULL,
  `number` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `amount` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `status` int(11) NOT NULL DEFAULT '1',
  `result_url` varchar(255) NOT NULL,
  `postback_url` varchar(255) NOT NULL,
  `merchant_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_merchant_id_fk` (`merchant_id`),
  KEY `index_orders_on_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `payments`
--

CREATE TABLE IF NOT EXISTS `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` binary(16) NOT NULL,
  `internal_transaction_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_order_id_fk` (`order_id`),
  KEY `payments_internal_transaction_id_fk` (`internal_transaction_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Структура таблицы `refunds`
--

CREATE TABLE IF NOT EXISTS `refunds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bitcoin_address` varchar(50) NOT NULL,
  `amount` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `fee` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `order_id` binary(16) DEFAULT NULL,
  `internal_transaction_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `refunds_order_id_fk` (`order_id`),
  KEY `refunds_internal_transaction_id_fk` (`internal_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Структура таблицы `schema_migrations`
--

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `withdraws`
--

CREATE TABLE IF NOT EXISTS `withdraws` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `fee` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `commission` decimal(18,8) NOT NULL DEFAULT '0.00000000',
  `merchant_id` int(11) NOT NULL,
  `internal_transaction_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `withdraws_merchant_id_fk` (`merchant_id`),
  KEY `withdraws_internal_transaction_id_fk` (`internal_transaction_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `internal_transactions`
--
ALTER TABLE `internal_transactions`
  ADD CONSTRAINT `internal_transactions_merchant_id_fk` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`);

--
-- Ограничения внешнего ключа таблицы `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_merchant_id_fk` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`);

--
-- Ограничения внешнего ключа таблицы `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_internal_transaction_id_fk` FOREIGN KEY (`internal_transaction_id`) REFERENCES `internal_transactions` (`id`),
  ADD CONSTRAINT `payments_order_id_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Ограничения внешнего ключа таблицы `refunds`
--
ALTER TABLE `refunds`
  ADD CONSTRAINT `refunds_internal_transaction_id_fk` FOREIGN KEY (`internal_transaction_id`) REFERENCES `internal_transactions` (`id`),
  ADD CONSTRAINT `refunds_order_id_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Ограничения внешнего ключа таблицы `withdraws`
--
ALTER TABLE `withdraws`
  ADD CONSTRAINT `withdraws_internal_transaction_id_fk` FOREIGN KEY (`internal_transaction_id`) REFERENCES `internal_transactions` (`id`),
  ADD CONSTRAINT `withdraws_merchant_id_fk` FOREIGN KEY (`merchant_id`) REFERENCES `merchants` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
CREATE TABLE IF NOT EXISTS `qb-propplacing` (
  `id` varchar(50) DEFAULT NULL,
  `model` int(11) DEFAULT NULL,
  `item` varchar(50) DEFAULT NULL,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `heading` float DEFAULT NULL,
  `citizen` varchar(50) DEFAULT NULL,
  `metadata` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
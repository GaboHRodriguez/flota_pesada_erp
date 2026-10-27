-- phpMyAdmin SQL Dump
-- version 3.1.3.1
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 07-05-2023 a las 02:44:59
-- Versión del servidor: 5.1.33
-- Versión de PHP: 5.2.9

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de datos: `dbequipos`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `combustible`
--

DROP TABLE IF EXISTS `combustible`;
CREATE TABLE `combustible` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipoCombustible` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Volcar la base de datos para la tabla `combustible`
--

REPLACE INTO `combustible` (`id`, `tipoCombustible`) VALUES
(1, 'Diesel'),
(2, 'Nafta'),
(3, 'GNC'),
(4, 'Electricidad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipos`
--

DROP TABLE IF EXISTS `equipos`;
CREATE TABLE `equipos` (
  `anio` int(11) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `dominio` varchar(50) NOT NULL,
  `estado` varchar(50) NOT NULL,
  `fechaCompra` date NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `marca` int(11) NOT NULL,
  `nchasis` varchar(50) NOT NULL,
  `nmotor` varchar(50) NOT NULL,
  `npoliza` varchar(50) NOT NULL,
  `origen` int(11) NOT NULL,
  `pmensual` float NOT NULL,
  `pstandby` float NOT NULL,
  `seguro` varchar(50) NOT NULL,
  `tseguro` varchar(50) NOT NULL,
  `valCompra` float NOT NULL,
  `vencimiento` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=184 ;

--
-- Volcar la base de datos para la tabla `equipos`
--

REPLACE INTO `equipos` (`anio`, `codigo`, `dominio`, `estado`, `fechaCompra`, `id`, `marca`, `nchasis`, `nmotor`, `npoliza`, `origen`, `pmensual`, `pstandby`, `seguro`, `tseguro`, `valCompra`, `vencimiento`) VALUES
(1988, 'AC001', 'SZU 640', 'En uso', '2020-01-01', 1, 26, '5245', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1988, 'AC001', 'SZU 640', 'En uso', '2020-01-01', 2, 26, '5245', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1990, 'AC002', 'SZU 645', 'En uso', '2020-01-01', 3, 27, '5986', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1974, 'AC003', 'SZU 646', 'En uso', '2020-01-01', 4, 68, 'BAQ2135', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1997, 'AC004', 'BKN 212', 'En uso', '2020-01-01', 5, 63, '8C9N0863FV1002115', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1998, 'AC005', 'CGJ 176', 'En uso', '2020-01-01', 6, 28, '9488', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1990, 'AC006', 'TAF 470', 'En uso', '2020-01-01', 7, 99, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1988, 'AC007', 'SZU 644', 'En uso', '2020-01-01', 8, 100, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'AC008', 'FFH 670', 'En uso', '2020-01-01', 9, 90, '8A9SRVT305A022013', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'AM001', '', 'En uso', '2020-01-01', 10, 40, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'AM002', '', 'En uso', '2020-01-01', 11, 41, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1985, 'AP003', '', 'En uso', '2020-01-01', 12, 33, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'ASJ004', '', 'En uso', '2020-01-01', 13, 101, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'ASJ005', '', 'En uso', '2020-01-01', 14, 102, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'ASJ006', '', 'En uso', '2020-01-01', 15, 102, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'BA003', 'JKD 583', 'En uso', '2020-01-01', 16, 85, '8A9S161BA10PSR729', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'BOM003', '', 'En uso', '2020-01-01', 17, 31, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'BOM004', '', 'En uso', '2020-01-01', 18, 31, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'BOM005', '', 'En uso', '2020-01-01', 19, 31, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1998, 'CA013', 'CAH 393', 'En uso', '2020-01-01', 20, 75, 'W2219243', '31111198', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'CA016', 'JBB 386', 'En uso', '2020-01-01', 21, 19, '9BFYCAWYXABB61466', '36197574', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2011, 'CA017', 'JZR 462', 'En uso', '2020-01-01', 22, 18, '9BFXCE2U5BBB79204', '36265044', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'CA018', 'EYA 647', 'En uso', '2020-01-01', 23, 25, '9BFYTNFT64BB38055', '30512717', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'CA019', 'PDB 434', 'En uso', '2020-01-01', 24, 36, '9BFLF47P5GB006774', '89668014', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'CA020', 'AB199ML', 'En uso', '2020-01-01', 25, 14, '93ZC53C01H8469656', '7250224', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'CA021', 'AC 224 WS', 'En uso', '2020-01-01', 26, 36, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CAR001', '', 'En uso', '2020-01-01', 27, 103, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CAR002', '', 'En uso', '2020-01-01', 28, 103, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CAR003', '', 'En uso', '2020-01-01', 29, 103, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CAR004', '', 'En uso', '2020-01-01', 30, 103, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CAR005', '', 'En uso', '2020-01-01', 31, 103, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CON001', '', 'En uso', '2020-01-01', 32, 104, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CON002', '', 'En uso', '2020-01-01', 33, 105, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CON003', '', 'En uso', '2020-01-01', 34, 106, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CON004', '', 'En uso', '2020-01-01', 35, 48, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CON005', '', 'En uso', '2020-01-01', 36, 107, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'CON006', '', 'En uso', '2020-01-01', 37, 92, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'CON007', '', 'En uso', '2020-01-01', 38, 91, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'CP002', '', 'En uso', '2020-01-01', 39, 65, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2007, 'CP003', '373088UFQ394', 'En uso', '2020-01-01', 40, 66, 'PE4045D580932', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'CP004', 'BP2321', 'En uso', '2020-01-01', 41, 97, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'CP005', '', 'En uso', '2020-01-01', 42, 5, '', 'J04045d674108', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CR001', '', 'En uso', '2020-01-01', 43, 108, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CR002', '', 'En uso', '2020-01-01', 44, 109, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CR003', '', 'En uso', '2020-01-01', 45, 110, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CR004', '', 'En uso', '2020-01-01', 46, 110, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'CR006', '', 'En uso', '2020-01-01', 47, 110, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2001, 'CT001', 'DZC 936', 'En uso', '2020-01-01', 48, 86, '000732', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'CT002', '', 'En uso', '2020-01-01', 49, 111, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'CT003', '', 'En uso', '2020-01-01', 50, 112, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2021, 'CT005', '', 'En uso', '2020-01-01', 51, 87, '8B9SGT3CMLA030044', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'DE001', '', 'En uso', '2020-01-01', 52, 113, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'DE003', '', 'En uso', '2020-01-01', 53, 54, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'DTG001', '', 'En uso', '2020-01-01', 54, 37, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'ETE002', '', 'En uso', '2020-01-01', 55, 114, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'ETO001', '', 'Robado', '2020-01-01', 56, 115, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'ETO002', '', 'Robado', '2020-01-01', 57, 115, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2014, 'ETO003', '', 'En uso', '2020-01-01', 58, 61, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2009, 'FUS002', '', 'En uso', '2020-01-01', 59, 116, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2007, 'GRE001', '', 'En uso', '2020-01-01', 60, 98, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2009, 'GRE002', '', 'En uso', '2020-01-01', 61, 117, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2001, 'GRE003', '', 'En uso', '2020-01-01', 62, 64, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'GRE004', '', 'Robado', '2020-01-01', 63, 118, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'GRE005', '', 'En uso', '2020-01-01', 64, 47, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2013, 'GRE006', '', 'En uso', '2020-01-01', 65, 46, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2013, 'GRE007', '', 'En uso', '2020-01-01', 66, 45, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'GRE008', 'HP 2IP05 220-12', 'En uso', '2020-01-01', 67, 119, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE010', '', 'En uso', '2020-01-01', 68, 3, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE011', '', 'En uso', '2020-01-01', 69, 53, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE011', '', 'En uso', '2020-01-01', 70, 3, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE012', '', 'En uso', '2020-01-01', 71, 52, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE013', '', 'En uso', '2020-01-01', 72, 4, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'GRE014', '', 'En uso', '2020-01-01', 73, 55, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'HOR001', '', 'En uso', '2020-01-01', 74, 120, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'MA005', '', 'En uso', '2020-01-01', 75, 56, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'MA006', '', 'En uso', '2020-01-01', 76, 56, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'MA007', '', 'En uso', '2020-01-01', 77, 56, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'MA008', '', 'En uso', '2020-01-01', 78, 121, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'MAH 002', '', 'En uso', '2020-01-01', 79, 122, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'MAH001', '', 'En uso', '2020-01-01', 80, 123, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'MAH002', '', 'En uso', '2020-01-01', 81, 124, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'MAT001', '', 'En uso', '2020-01-01', 82, 39, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'MG003', '', 'En uso', '2020-01-01', 83, 125, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'MN002', 'GD 523', 'Baja', '2020-01-01', 84, 126, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1992, 'MN003', 'GD 623', 'Baja', '2020-01-01', 85, 1, '1021', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'MN004', 'BXT 93', 'En uso', '2020-01-01', 86, 17, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'MSO001', '', 'En uso', '2020-01-01', 87, 127, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'NV001', '', 'En uso', '2020-01-01', 88, 128, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'NV002', '', 'En uso', '2020-01-01', 89, 128, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'NV004', '', 'En uso', '2020-01-01', 90, 129, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'NV005', '', 'En uso', '2020-01-01', 91, 62, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1993, 'PC003', '', 'En uso', '2020-01-01', 92, 95, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'PC005', 'BNB 70', 'En uso', '2020-01-01', 93, 15, '1305420', '21790622', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2011, 'PC007', 'CAL 91', 'En uso', '2020-01-01', 94, 2, '1010028', '97919171', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2016, 'PC008', 'DFI 26', 'En uso', '2020-01-01', 95, 20, 'CAT0226BLDXZ01114', 'CZ201806', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PC009', 'DGY 47', 'En uso', '2020-01-01', 96, 20, 'CAT0226BCDXZ01179', 'CZ202019', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PC010', 'DLI 61', 'En uso', '2020-01-01', 97, 57, 'HAR070WSPH2499507', '002689C', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'PC011', 'DJD 40', 'En uso', '2020-01-01', 98, 57, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PC012', 'DNW37', 'En uso', '2020-01-01', 99, 58, 'RAJ070WSTH2575609', '007505C', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2016, 'PC013', 'EGN 49', 'En uso', '2020-01-01', 100, 10, '', '8FS05995', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1968, 'PE001', '', 'En uso', '2020-01-01', 101, 130, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'PL001', '', 'En Reparación', '2020-01-01', 102, 131, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2007, 'PMC001', '', 'Alquilada', '2020-01-01', 103, 8, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'PMC002', '', 'Alquilada', '2020-01-01', 104, 9, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2007, 'PRE005', 'BYA 17', 'En uso', '2020-01-01', 105, 88, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PRE008', 'DFT01', 'En uso', '2020-01-01', 106, 21, 'HHKHU601VG0000660', 'RG75486R025666B', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PRE009', 'DGY 09', 'En uso', '2020-01-01', 107, 21, 'HBRH940CEG0000008', 'B521314Y', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PRE010', 'DIP 41', 'En uso', '2020-01-01', 108, 96, 'KMTWB0244AHUF90314', '1484707', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'PRE011', 'DLH 07', 'En uso', '2020-01-01', 109, 96, 'KMTWB024CHUF90410', '001520397', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'PRE012', 'DJD 63', 'En uso', '2020-01-01', 110, 96, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2021, 'PRE013', 'DQH93', 'En uso', '2020-01-01', 111, 96, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'RE006', 'BMU 74', 'En uso', '2020-01-01', 112, 50, 'JCBJS20DK81611073', '4HK1XYSJ02421320', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'RE009', 'CAX 33', 'En uso', '2020-01-01', 113, 16, 'CAT0320DCA8F01610', 'GDC34580', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1999, 'RE010', '', 'En uso', '2020-01-01', 114, 71, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'RE011', 'CIL 96', 'En uso', '2020-01-01', 115, 82, 'HHIHNB06TB00018', '35282942', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'RE012', 'CXN 15', 'En uso', '2020-01-01', 116, 70, 'KMTPC180CEBB33110', '36506145', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'RE013', 'CYS 88', 'En uso', '2020-01-01', 117, 83, 'HKHM909TF0005310', 'G1883', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'RE014', 'CNN 37', 'En uso', '2020-01-01', 118, 12, '1FF035DXECG268982', 'YN3TNV88116593', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'RE015', 'DIL 88', 'En uso', '2020-01-01', 119, 35, 'VCEEC55BT00039139', '32290', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'RE016', 'DLG 17', 'En uso', '2020-01-01', 120, 70, 'KMTPC244LHBB50312', '36574063', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'RE017', 'DLI 22', 'En uso', '2020-01-01', 121, 69, 'KMTPC244HHBB50327', '36575062', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'RE018', 'DLK 96', 'En uso', '2020-01-01', 122, 80, '36573562', 'HBRR220CAH0000892', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'RE019', 'DNU 56', 'En uso', '2020-01-01', 123, 81, '105109', 'hhkmh03hh0001679', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'RE020', 'BZQ77', 'En uso', '2020-01-01', 124, 11, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2005, 'RN001', '', 'En uso', '2020-01-01', 125, 132, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1968, 'RN003', 'GW 27', 'En uso', '2020-01-01', 126, 133, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2007, 'RPC001', 'BFQ 73', 'En uso', '2020-01-01', 127, 24, '709B777', '30383911', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'SOL001', '', 'En uso', '2020-01-01', 128, 49, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA001', '', 'En uso', '2020-01-01', 129, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA002', '', 'En uso', '2020-01-01', 130, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA003', '', 'En uso', '2020-01-01', 131, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA004', '', 'En uso', '2020-01-01', 132, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA005', '', 'En uso', '2020-01-01', 133, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA006', '', 'En uso', '2020-01-01', 134, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'TA007', '', 'En uso', '2020-01-01', 135, 22, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TA008', '', 'En uso', '2020-01-01', 136, 134, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'TAL001', '', 'En uso', '2020-01-01', 137, 135, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'TAL002', '', 'En uso', '2020-01-01', 138, 135, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'TAL003', '', 'En uso', '2020-01-01', 139, 135, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'TAL004', '', 'En uso', '2020-01-01', 140, 135, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TAS001', '', 'En uso', '2020-01-01', 141, 136, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'TAS002', '', 'En uso', '2020-01-01', 142, 136, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2002, 'TE002', '', 'En uso', '2020-01-01', 143, 137, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2002, 'TE002', '', 'En uso', '2020-01-01', 144, 32, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'TU001', 'BP2337', 'En uso', '2020-01-01', 145, 73, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'TU002', '', 'En uso', '2020-01-01', 146, 6, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'TU003', '', 'En uso', '2020-01-01', 147, 7, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'TU004', '', 'En uso', '2020-01-01', 148, 72, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'TU005', '', 'En uso', '2020-01-01', 149, 72, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'UM016', 'JFO 662', 'En uso', '2020-01-01', 150, 30, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2010, 'UM018', 'JJV 807', 'En uso', '2020-01-01', 151, 38, '9BWAB05U2BT123042', 'CFZ787628', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2011, 'UM020', 'JZI 609', 'En uso', '2020-01-01', 152, 29, '9BRBU42EXC4700353', '2ZRM001766', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2011, 'UM021', 'KEQ 694', 'En uso', '2020-01-01', 153, 51, 'sa1kcf705cl837032', 'k9ka700d182363', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1995, 'UM022', 'AAL 223', 'En Reparación', '2020-01-01', 154, 93, 'KN4FAK2OTC021468', 'SS-059472', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(1994, 'UM023', 'AAL 219', 'En Reparación', '2020-01-01', 155, 93, 'KN4FAK2AORC021467', 'SS-059608', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2013, 'UM024', 'MTA 102', 'En uso', '2020-01-01', 156, 78, '8AFAR22J3DJ125692', 'QW2PDJ125692', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2013, 'UM025', 'MTR 003', 'En uso', '2020-01-01', 157, 79, '8AFAR22JXEJ135699', 'QW2PEJ35699', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2014, 'UM026', 'NPQ 889', 'En uso', '2020-01-01', 158, 34, '9FBHSR1N5EM018231', 'K4NA690Q207320', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2014, 'UM027', 'NON 894', 'En uso', '2020-01-01', 159, 51, '8A1FC1315EL987132', 'K4MJ730Q130068', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'UM028', 'OTG 378', 'En uso', '2020-01-01', 160, 67, '8ADGJ9HJCFG524266', '10JBED0042292', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'UM029', 'OSP 435', 'En uso', '2020-01-01', 161, 13, '8AD4D5FMJFG025225', '10FJBZ2167891', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'UM030', 'PET 436', 'En uso', '2020-01-01', 162, 43, '8AJEZ32GXF1018336', '1KD-A845362', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2015, 'UM031', 'PET 486', 'En uso', '2020-01-01', 163, 44, '8AJER32G9F4060298', '2KD-A853567', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'UM032', 'AC 304 XZ', 'En uso', '2020-01-01', 164, 77, '8AFAR22P5JJ055855', 'EV2EJJ055855', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'UM033', 'AC 304 YA', 'En uso', '2020-01-01', 165, 77, '8AFAR22P5JJ052907', 'EV2EJJ052907', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'UM034', 'AC275PB', '', '2020-01-01', 166, 59, '3FA6POH98JR126235', 'JR126235', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'UM035', 'HCQ 111', 'En uso', '2020-01-01', 167, 42, '8ajdr22g284007936', '2kd7504358', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'UM036', 'AC751UE', '', '2020-01-01', 168, 74, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'UM037', 'AB197YR', 'En uso', '2020-01-01', 169, 84, '9BWLB45U4HP069938', 'CFZR63664', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(0, 'UM038', 'MUY 290', 'En uso', '2020-01-01', 170, 76, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP 015', 'C9690', 'En uso', '2020-01-01', 171, 60, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'VAP006', '', 'En uso', '2020-01-01', 172, 23, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'VAP007', '', 'En uso', '2020-01-01', 173, 23, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP010', '', 'En uso', '2020-01-01', 174, 94, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP011', '', 'En uso', '2020-01-01', 175, 94, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP012', '', 'En uso', '2020-01-01', 176, 94, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP013', '1105260', 'En uso', '2020-01-01', 177, 89, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP014', '1108507', 'En uso', '2020-01-01', 178, 89, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2017, 'VAP016', 'C9696', 'En uso', '2020-01-01', 179, 60, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2008, 'VI001', '', 'En uso', '2020-01-01', 180, 138, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'VI002', '', 'En uso', '2020-01-01', 181, 138, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2012, 'VI003', '', 'En uso', '2020-01-01', 182, 138, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01'),
(2018, 'VI004', '', 'En uso', '2020-01-01', 183, 138, '', '', '', 0, 0, 0, '', '', 0, '2020-01-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `filtros`
--

DROP TABLE IF EXISTS `filtros`;
CREATE TABLE `filtros` (
  `codFiltro` varchar(50) NOT NULL,
  `equipo` int(11) NOT NULL,
  `equivalencia` varchar(50) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipoFiltro` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Volcar la base de datos para la tabla `filtros`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lubricantes`
--

DROP TABLE IF EXISTS `lubricantes`;
CREATE TABLE `lubricantes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `capacidadLubricantes` int(11) NOT NULL,
  `denomLubricante` int(11) NOT NULL,
  `equipo` int(11) NOT NULL,
  `parteLubricante` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Volcar la base de datos para la tabla `lubricantes`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcas`
--

DROP TABLE IF EXISTS `marcas`;
CREATE TABLE `marcas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `capacidad` int(11) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `potencia` int(11) NOT NULL,
  `tipoEquipo` int(11) NOT NULL,
  `traccion` int(11) NOT NULL,
  `uCapacidad` int(11) NOT NULL,
  `uPotencia` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=139 ;

--
-- Volcar la base de datos para la tabla `marcas`
--

REPLACE INTO `marcas` (`id`, `capacidad`, `marca`, `modelo`, `potencia`, `tipoEquipo`, `traccion`, `uCapacidad`, `uPotencia`) VALUES
(2, 0, 'TIAN GONG', '028-ZL50H', 220, 29, 1, 0, 0),
(1, 0, 'KOMATSU', '30701428', 196, 26, 1, 0, 0),
(3, 0, 'LUSQTOFF', '10 kva', 0, 20, 3, 0, 0),
(4, 0, 'LUSQTOFF', '10GF2-4', 11, 20, 3, 0, 0),
(5, 0, 'SULLAIR', '185Q-JD', 0, 13, 1, 0, 0),
(6, 0, 'HAMMERHEAD', '2"', 0, 43, 3, 0, 0),
(7, 0, 'HAMMERHEAD', '2,5PP', 0, 43, 3, 0, 0),
(8, 0, '', '2184', 0, 33, 3, 0, 0),
(9, 0, '', '2212', 0, 33, 3, 0, 0),
(10, 0, 'CATERPILLAR', '236D', 74, 29, 1, 0, 0),
(11, 0, 'CATERPILLAR', '336DLME', 0, 34, 1, 0, 0),
(12, 0, 'JOHN DEERE', '35D', 30, 34, 1, 0, 0),
(13, 0, 'PEUGEOT', '408 SPORT 163 CV', 160, 5, 1, 0, 0),
(14, 0, 'IVECO', '428- DAILY 55C17 PASO 3750', 168, 8, 1, 0, 0),
(15, 0, 'JCB', '436 ZX', 177, 29, 1, 0, 0),
(16, 0, 'CATERPILLAR', '635320D L', 148, 34, 1, 0, 0),
(17, 0, 'JOHN DEERE', '670G', 207, 26, 1, 0, 0),
(18, 0, 'FORD', '743 CARGO 1317E', 160, 8, 1, 0, 0),
(19, 0, 'FORD', '749- CARGO 1832E', 315, 8, 1, 0, 0),
(20, 0, 'CATERPILLAR', '787-226B-3', 61, 29, 1, 0, 0),
(21, 0, 'HYUNDAI', '940H', 158, 30, 2, 0, 0),
(22, 0, 'Grosspal', 'AT 1500', 0, 40, 3, 0, 0),
(23, 0, 'WACKER', 'BS 502plus', 0, 46, 3, 0, 0),
(24, 0, 'DYNAPAC', 'CA-25', 109, 36, 4, 0, 0),
(25, 0, 'FORD', 'CARGO 1722', 215, 8, 1, 0, 0),
(26, 0, 'SALTO', 'ch 8,15/1988', 0, 37, 1, 0, 0),
(27, 0, 'SALTO', 'CH 8,5', 0, 37, 1, 0, 0),
(28, 0, 'SALTO', 'CH AC', 0, 1, 1, 0, 0),
(29, 0, 'TOYOTA', 'Corolla XLI 1,8', 136, 5, 1, 0, 0),
(30, 0, 'FORD', 'Curier', 60, 44, 1, 0, 0),
(31, 0, 'Motorarg', 'DCO 1100M', 1, 7, 3, 0, 0),
(32, 0, 'P230', 'DEUTHZ', 0, 42, 1, 0, 0),
(33, 0, 'BITELLI', 'DRAGO', 90, 3, 1, 0, 0),
(34, 0, 'REANULT', 'DUSTER', 110, 5, 1, 0, 0),
(35, 0, 'VOLVO', 'EC55BPRO', 52, 34, 1, 0, 0),
(36, 0, 'FORD', 'F4000', 148, 8, 1, 0, 0),
(37, 0, 'BW Technologies', 'Gas Alert Micro 5', 0, 16, 3, 0, 0),
(38, 0, 'VOLKWAGEN', 'Gol', 101, 5, 1, 0, 0),
(39, 0, 'BOSCH', 'GSH 11 E', 1500, 22, 3, 0, 0),
(40, 0, 'BOSCH', 'GUUS 22-180', 0, 2, 3, 0, 0),
(41, 0, 'BOSCH', 'GUUS7', 0, 2, 3, 0, 0),
(42, 0, 'Toyota', 'Hilux', 171, 9, 1, 0, 0),
(43, 0, 'TOYOTA', 'HILUX 3,0 TDI DC DR 4X2', 171, 9, 1, 0, 0),
(44, 0, 'TOYOTA', 'HILUX 4X2 C/D PCK Electrico 2,5 tdi - h3', 171, 9, 1, 0, 0),
(45, 0, 'KOREA', 'HP 4I6,5Kw.', 0, 20, 3, 0, 0),
(46, 0, 'KOREA', 'HP4I5', 0, 20, 3, 0, 0),
(47, 0, 'GAMA', 'HZTPOS-12', 0, 20, 3, 0, 0),
(48, 0, '', 'INBU-39015-5', 0, 14, 3, 0, 0),
(49, 0, 'LUSQTOFF', 'Iron 250 5TA', 0, 38, 3, 0, 0),
(50, 0, 'JCB', 'JS200 LC', 136, 34, 1, 0, 0),
(51, 0, 'REANULT', 'KANGOO', 95, 44, 1, 0, 0),
(52, 0, 'KIPOR', 'Kde 19KVA', 0, 20, 3, 0, 0),
(53, 0, 'KIPOR', 'KDE19STA3', 0, 20, 3, 0, 0),
(54, 0, 'LUSQTOFF', 'LD-52', 0, 15, 1, 0, 0),
(55, 0, 'LUSQTOFF', 'LG2500EX', 0, 20, 1, 0, 0),
(56, 0, 'CETEC', 'M368277', 0, 24, 1, 0, 0),
(57, 0, 'VOLVO', 'MC70', 60, 29, 1, 0, 0),
(58, 0, 'VOLVO', 'MC70C', 60, 29, 1, 0, 0),
(59, 0, 'FORD', 'MONDEO SEL 2,0 ECOBOOST 4 PTAS', 236, 5, 1, 0, 0),
(60, 0, 'MIKASA', 'mtx 60hf', 0, 46, 3, 0, 0),
(61, 0, 'SOUTH', 'N7', 0, 17, 3, 0, 0),
(62, 0, 'LEICA', 'NA324', 0, 28, 3, 0, 0),
(63, 0, 'FRUEHAUF', 'NR NF3', 0, 1, 3, 0, 0),
(64, 0, 'BOUNOUS', 'ODB 04/9', 0, 20, 3, 0, 0),
(65, 0, 'CETEC', 'OTR 275A Serie', 7, 13, 3, 0, 0),
(66, 0, 'INGERSOLL RAND', 'P250WJD', 0, 13, 3, 0, 0),
(67, 0, 'PEUGEOT', 'PARTNER PATAGONICA HDI 1,6 VTC PLUS', 92, 44, 1, 0, 0),
(68, 0, 'FRUEHAUF', 'PB-F2HD', 0, 37, 1, 0, 0),
(69, 155, 'KOMATSU', 'PC-200', 143, 34, 1, 0, 0),
(70, 0, 'KOMATSU', 'PC-200 LC-8', 143, 34, 1, 0, 0),
(71, 0, 'KOMATSU', 'PC-450 LC-7', 353, 34, 1, 0, 0),
(72, 0, 'HELIX', 'PHETIPO3000', 0, 43, 3, 0, 0),
(73, 0, 'HELIX', 'PHHR 530', 0, 43, 3, 0, 0),
(74, 0, 'Chevrolet', 'prisma', 115, 5, 1, 0, 0),
(75, 0, 'SCANIA', 'R113 H', 356, 8, 1, 0, 0),
(76, 0, 'FORD', 'RANGER', 150, 9, 1, 0, 0),
(77, 0, 'FORD', 'Ranger 2,5 DC 4x2L/16 XL Safety 2017', 123, 9, 1, 0, 0),
(78, 0, 'FORD', 'Ranger 4x2 Safety 2,2L D', 166, 9, 1, 0, 0),
(79, 0, 'FORD', 'Ranger2 DC 4x2 Safety 2,2L D', 166, 9, 1, 0, 0),
(80, 0, 'HYUNDAI', 'Robex 220 LC-9SB?', 150, 34, 1, 0, 0),
(81, 0, 'HYUNDAI', 'ROBEX 35Z-9', 26, 34, 1, 0, 0),
(82, 0, 'HYUNDAI', 'ROBEX 500 LC-6', 356, 34, 1, 0, 0),
(83, 265, 'HYUNDAI', 'ROBEX 60', 64, 34, 1, 0, 0),
(84, 0, 'VOLKSWAGEN', 'SAVEIRO 1,6', 115, 5, 1, 0, 0),
(85, 0, 'PLUSCARGA', 'S-BA/25-2004', 0, 6, 1, 0, 0),
(86, 0, 'PATRONELLI', 'SEM. CARR.3E', 0, 10, 1, 0, 0),
(87, 0, 'PATRONELLI', 'SEMCG3E', 0, 10, 1, 0, 0),
(88, 0, 'JOHN DEERE', 'SJ310', 94, 30, 2, 0, 0),
(89, 0, 'WEBBER', 'SRV660', 0, 46, 3, 0, 0),
(90, 0, 'BIANCHI', 'SRVT30-0387', 0, 1, 1, 0, 0),
(91, 0, 'BRANSEN', 'TIPO OFICINA', 0, 14, 3, 0, 0),
(92, 0, 'BRANSEN', 'TIPO PAÑOL', 0, 14, 3, 0, 0),
(93, 0, 'ASIA', 'Topic', 75, 9, 1, 0, 0),
(94, 0, 'CMC', 'V60', 0, 46, 3, 0, 0),
(95, 0, 'KOMATSU', 'WA250', 140, 29, 1, 0, 0),
(96, 0, 'KOMATSU', 'WB97R', 0, 30, 2, 0, 0),
(97, 0, 'ATLAS COPCO', 'XAS 185 JD HARD HAT', 0, 13, 1, 0, 0),
(98, 0, 'BOUNOUS', 'Yanmar 22/20', 0, 20, 3, 0, 0),
(99, 0, 'ROMAPAR', '', 0, 37, 1, 0, 0),
(100, 0, 'SALTO', '', 0, 37, 1, 0, 0),
(101, 0, 'WACKER', '', 8, 4, 3, 0, 0),
(102, 0, 'NORTON', '', 13, 4, 3, 0, 0),
(103, 0, '', '', 0, 11, 3, 0, 0),
(104, 0, '', '', 0, 14, 3, 0, 0),
(105, 0, 'Dryzort', '', 0, 14, 3, 0, 0),
(106, 0, 'Comet', '', 0, 14, 3, 0, 0),
(107, 0, '', '', 0, 14, 3, 0, 0),
(108, 0, 'Conrrado Iglesias', '', 0, 12, 3, 0, 0),
(109, 0, 'Tecnagro', '', 0, 12, 3, 0, 0),
(110, 0, '', '', 0, 12, 3, 0, 0),
(111, 0, 'S/M', '', 0, 10, 3, 0, 0),
(112, 0, 'AP', '', 0, 10, 3, 0, 0),
(113, 0, 'HERCULES', '', 0, 15, 3, 0, 0),
(114, 0, 'INDHOR', '', 0, 18, 3, 0, 0),
(115, 0, 'PENTAX', '', 0, 17, 3, 0, 0),
(116, 0, 'FRACCHIA', '', 0, 19, 3, 0, 0),
(117, 0, 'TOP MAN', '', 5500, 20, 3, 0, 0),
(118, 0, 'SENSEI', '', 0, 20, 3, 0, 0),
(119, 0, 'GAMA', '', 0, 20, 3, 0, 0),
(120, 140, 'Trompito', '', 1, 21, 3, 0, 0),
(121, 0, 'SULLAIR', '', 0, 24, 3, 0, 0),
(122, 0, 'Volvo', '', 0, 23, 3, 0, 0),
(123, 0, 'JCB', '', 0, 23, 3, 0, 0),
(124, 0, 'Volvo', '', 0, 23, 3, 0, 0),
(125, 0, 'SENSEI', '', 0, 25, 3, 0, 0),
(126, 0, 'KOMATSU', '', 196, 26, 3, 0, 0),
(127, 0, 'MILLER', '', 0, 27, 3, 0, 0),
(128, 0, 'TOPCON', '', 0, 28, 3, 0, 0),
(129, 0, 'PENTAX', '', 0, 28, 3, 0, 0),
(130, 0, 'WAGON DRILL', '', 0, 31, 3, 0, 0),
(131, 0, 'BARBER GREENE', '', 0, 32, 3, 0, 0),
(132, 0, 'DYNAPAC', '', 150, 35, 3, 0, 0),
(133, 0, 'HATRA', '', 0, 35, 3, 0, 0),
(134, 0, '', '', 0, 40, 3, 0, 0),
(135, 0, 'BOSCH', '', 0, 39, 3, 0, 0),
(136, 0, '', '', 0, 41, 3, 0, 0),
(137, 0, 'MARINI', '', 0, 42, 3, 0, 0),
(138, 0, 'INDHOR', '', 0, 45, 3, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obras`
--

DROP TABLE IF EXISTS `obras`;
CREATE TABLE `obras` (
  `cuit` varchar(50) NOT NULL,
  `Empresa` varchar(50) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `logo` int(11) NOT NULL,
  `nombreObra` int(11) NOT NULL,
  `numeroInterno` int(11) NOT NULL,
  `responsable` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Volcar la base de datos para la tabla `obras`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pais`
--

DROP TABLE IF EXISTS `pais`;
CREATE TABLE `pais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `continente` varchar(50) NOT NULL,
  `moneda` varchar(50) NOT NULL,
  `pais` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Volcar la base de datos para la tabla `pais`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partediario`
--

DROP TABLE IF EXISTS `partediario`;
CREATE TABLE `partediario` (
  `ID` int(11) NOT NULL,
  `equipo` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `horometroFinal` int(11) NOT NULL,
  `horometroInicial` int(11) NOT NULL,
  `ltsCombustible` int(11) NOT NULL,
  `ltsLubricante` int(11) NOT NULL,
  `nroOrdenCompra` int(11) NOT NULL,
  `nroValeCarga` int(11) NOT NULL,
  `numeroParte` int(11) NOT NULL,
  `Obra` int(11) NOT NULL,
  `Operario` int(11) NOT NULL,
  `tipoCombustible` int(11) NOT NULL,
  `tipoLubricante` int(11) NOT NULL,
  `trabajosRealizados` longtext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `partediario`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partemecanica`
--

DROP TABLE IF EXISTS `partemecanica`;
CREATE TABLE `partemecanica` (
  `id` int(11) NOT NULL,
  `parte` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `partemecanica`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

DROP TABLE IF EXISTS `permisos`;
CREATE TABLE `permisos` (
  `categoria` varchar(50) NOT NULL,
  `id` int(11) NOT NULL,
  `valor` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `permisos`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personal`
--

DROP TABLE IF EXISTS `personal`;
CREATE TABLE `personal` (
  `apellido` varchar(50) NOT NULL,
  `areatelefono` int(11) NOT NULL,
  `cargo` int(11) NOT NULL,
  `correo` varchar(50) NOT NULL,
  `cuil` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `legajo` varchar(50) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `pass` varchar(50) NOT NULL,
  `permisos` int(11) NOT NULL,
  `puesto` varchar(50) NOT NULL,
  `telefono` int(11) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `personal`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `service`
--

DROP TABLE IF EXISTS `service`;
CREATE TABLE `service` (
  `checkCambioFiltro` int(11) NOT NULL,
  `checkCambioLub` int(11) NOT NULL,
  `equipo` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `filtro` int(11) NOT NULL,
  `horometro` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `lugar` varchar(50) NOT NULL,
  `observaciones` longtext NOT NULL,
  `parteLubricante` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `service`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoequipos`
--

DROP TABLE IF EXISTS `tipoequipos`;
CREATE TABLE `tipoequipos` (
  `tipo` varchar(50) NOT NULL,
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `tipoequipos`
--

REPLACE INTO `tipoequipos` (`tipo`, `id`) VALUES
('Acoplados', 1),
('Amoladoras', 2),
('Aplanadoras', 3),
('Aserradoras de juntas', 4),
('Autos', 5),
('Bateas', 6),
('Bomba', 7),
('Camiónes', 8),
('Camionetas', 9),
('Carretones', 10),
('Carros', 11),
('Casillas Rodantes', 12),
('Compresores', 13),
('Contenedores', 14),
('Desmalezadoras', 15),
('Detector de Gases', 16),
('Estaciónes Totales', 17),
('Extractores de testigos', 18),
('Fusoras de Asfalto', 19),
('Grupos Electrogenos', 20),
('Hormigonera', 21),
('Martillo Demoledor', 22),
('Martillos Hidráulicos', 23),
('Martillos Neumaticos', 24),
('Motoguadañas', 25),
('Motoniveladoras', 26),
('Motosoldadoras', 27),
('Nivles Ópticos', 28),
('Pala Cargadoras', 29),
('Pala Retroexcavadoras', 30),
('Perforadoras', 31),
('Plantas de Asfalto', 32),
('Plantas Moviles de clasificación', 33),
('Retroexcavadoras', 34),
('Rodillos Neumaticos', 35),
('Rodillos Pata de Cabra', 36),
('Semi Remolques', 37),
('Soldadora', 38),
('Taladros', 39),
('Tanques', 40),
('Tanques Subterraneos', 41),
('Terminadoras de Asfalto', 42),
('Tuneleras', 43),
('Utilitarios', 44),
('Vibradores de inmersión', 45),
('Vibroapisonadores', 46);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipofiltro`
--

DROP TABLE IF EXISTS `tipofiltro`;
CREATE TABLE `tipofiltro` (
  `id` int(11) NOT NULL,
  `tipoFiltro` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `tipofiltro`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipolubricantes`
--

DROP TABLE IF EXISTS `tipolubricantes`;
CREATE TABLE `tipolubricantes` (
  `id` int(11) NOT NULL,
  `tipoLubricante` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `tipolubricantes`
--


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traccion`
--

DROP TABLE IF EXISTS `traccion`;
CREATE TABLE `traccion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipoTraccion` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Volcar la base de datos para la tabla `traccion`
--

REPLACE INTO `traccion` (`id`, `tipoTraccion`) VALUES
(1, 'Neumaticos'),
(2, 'Oruga'),
(3, 'Sin Tracción'),
(4, 'Rodillo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad`
--

DROP TABLE IF EXISTS `unidad`;
CREATE TABLE `unidad` (
  `definicion` varchar(50) NOT NULL,
  `id` int(11) NOT NULL,
  `unidad` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Volcar la base de datos para la tabla `unidad`
--



-- =================================================================================
-- TABLAS ACTUALIZADAS Y DATOS INICIALES (SIN DUPLICADOS DE PK)
-- =================================================================================

DROP TABLE IF EXISTS `partediario`;
CREATE TABLE `partediario` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `equipo` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `horometroFinal` int(11) NOT NULL,
  `horometroInicial` int(11) NOT NULL,
  `ltsCombustible` int(11) NOT NULL,
  `ltsLubricante` int(11) NOT NULL,
  `nroOrdenCompra` int(11) NOT NULL DEFAULT 0,
  `nroValeCarga` int(11) NOT NULL DEFAULT 0,
  `numeroParte` int(11) NOT NULL,
  `Obra` int(11) NOT NULL DEFAULT 1,
  `Operario` int(11) NOT NULL DEFAULT 5,
  `tipoCombustible` int(11) NOT NULL DEFAULT 1,
  `tipoLubricante` int(11) NOT NULL DEFAULT 1,
  `trabajosRealizados` longtext NOT NULL,
  `horaInicio` varchar(10) NOT NULL DEFAULT '07:30',
  `horaFin` varchar(10) NOT NULL DEFAULT '17:00',
  `observacionesFuncionamiento` text,
  `solicitaReparacion` tinyint(1) NOT NULL DEFAULT 0,
  `detalleSolicitudReparacion` text,
  `urgenciaReparacion` varchar(40) NOT NULL DEFAULT 'Normal',
  `sincronizadoServidor` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `service`;
CREATE TABLE `service` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `checkCambioFiltro` int(11) NOT NULL DEFAULT 0,
  `checkCambioLub` int(11) NOT NULL DEFAULT 0,
  `equipo` int(11) NOT NULL,
  `fecha` date DEFAULT NULL,
  `filtro` int(11) NOT NULL DEFAULT 1,
  `horometro` int(11) NOT NULL DEFAULT 0,
  `lugar` varchar(80) NOT NULL,
  `observaciones` longtext NOT NULL,
  `parteLubricante` int(11) NOT NULL DEFAULT 1,
  `tipoIntervencion` varchar(50) NOT NULL DEFAULT 'Mantenimiento Preventivo',
  `estadoOrden` varchar(30) NOT NULL DEFAULT 'Completado',
  `mecanicoResponsable` varchar(80) NOT NULL DEFAULT 'Taller Central',
  `repuestosUtilizados` text,
  `sistemaAfectado` varchar(80) NOT NULL DEFAULT 'Motor e Hidraulica',
  `costoRepuestos` decimal(12,2) NOT NULL DEFAULT 0.00,
  `costoManoObra` decimal(12,2) NOT NULL DEFAULT 0.00,
  `horasTrabajoTaller` decimal(8,2) NOT NULL DEFAULT 2.00,
  `parteDiarioOrigenId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `gastos_equipos`;
CREATE TABLE `gastos_equipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipoId` int(11) NOT NULL,
  `equipoCodigo` varchar(50) NOT NULL,
  `fecha` date NOT NULL,
  `categoriaGasto` varchar(60) NOT NULL,
  `proveedor` varchar(120) NOT NULL,
  `nroComprobante` varchar(60) NOT NULL,
  `montoUsd` decimal(12,2) NOT NULL DEFAULT 0.00,
  `obraId` int(11) NOT NULL,
  `registradoPor` varchar(80) NOT NULL,
  `descripcion` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `movimientos_obra`;
CREATE TABLE `movimientos_obra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `equipoId` int(11) NOT NULL,
  `equipoCodigo` varchar(50) NOT NULL,
  `obraOrigenId` int(11) NOT NULL,
  `obraDestinoId` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `tipoMovimiento` varchar(60) NOT NULL,
  `autorizadoPor` varchar(80) NOT NULL,
  `lecturaHorometro` decimal(12,2) NOT NULL DEFAULT 0.00,
  `motivoObservaciones` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

REPLACE INTO `permisos` (`id`, `categoria`, `valor`) VALUES
(1, 'Super Usuario (Sistemas y Acceso Total)', 1),
(2, 'Usuario Gerencia / Jefe de Obra (Informes, Costos y Asignacion Obras)', 2),
(3, 'Usuario Administrador (Equipos, Gastos, Consumos y Partes)', 3),
(4, 'Usuario Taller (ABM Informes Mantenimiento, Reparaciones y Stock)', 4),
(5, 'Usuario Operario (Carga de Parte Diario y Solicitud Reparacion)', 5);

REPLACE INTO `personal` (`id`, `nombre`, `apellido`, `correo`, `pass`, `legajo`, `cuil`, `areatelefono`, `telefono`, `cargo`, `puesto`, `permisos`, `usuario`) VALUES
(1, 'Martin', 'Rodriguez', 'super@constructora.com', 'Super2026!', 'LEG-001', 2024891023, 11, 45891001, 1, 'Administrador General de Sistemas TI', 1, 'mrodriguez'),
(2, 'Carlos', 'Mendez', 'gerencia@constructora.com', 'Gerencia2026!', 'LEG-005', 2021456789, 11, 45891002, 2, 'Gerente de Operaciones y Jefe de Obra', 2, 'cmendez'),
(3, 'Laura', 'Gomez', 'admin@constructora.com', 'Admin2026!', 'LEG-012', 2729345612, 11, 45891003, 3, 'Administracion de Flota y Costos', 3, 'lgomez'),
(4, 'Roberto', 'Sanchez', 'taller@constructora.com', 'Taller2026!', 'LEG-024', 2026789123, 11, 45891004, 4, 'Jefe de Taller Mecanico Vial', 4, 'rsanchez'),
(5, 'Juan', 'Perez', 'operario@constructora.com', 'Operario2026!', 'LEG-108', 2032456781, 11, 56782201, 5, 'Operador Maquinaria Pesada', 5, 'jperez');

REPLACE INTO `partediario` (`ID`, `equipo`, `fecha`, `horometroInicial`, `horometroFinal`, `ltsCombustible`, `ltsLubricante`, `nroOrdenCompra`, `nroValeCarga`, `numeroParte`, `Obra`, `Operario`, `tipoCombustible`, `tipoLubricante`, `trabajosRealizados`, `horaInicio`, `horaFin`, `observacionesFuncionamiento`, `solicitaReparacion`, `detalleSolicitudReparacion`, `urgenciaReparacion`, `sincronizadoServidor`) VALUES
(1001, 120, '2026-10-17', 5412, 5422, 165, 3, 312, 8841, 48201, 1, 5, 1, 1, 'Excavacion de zanja para desague pluvial progresiva Km 154 y carga en batea.', '07:30', '17:30', 'Transpiracion de aceite hidraulico en flexible de cilindro de balde.', 1, 'Reemplazar manguera hidraulica de cilindro de balde y service 250 hs.', 'Alta', 1),
(1002, 86, '2026-10-17', 4781, 4790, 140, 2, 312, 8842, 48202, 3, 6, 1, 1, 'Perfilado y nivelacion fina de base granular estabilizada.', '07:00', '16:30', 'Desgaste en cuchilla central de vertedera.', 1, 'Rotar o cambiar juego de cuchillas de vertedera y service 250 hs.', 'Normal', 1),
(1003, 95, '2026-10-16', 3296, 3305, 68, 0, 309, 8835, 48203, 4, 5, 1, 0, 'Acopio de aridos y carga de tolvas en Parque Industrial.', '08:00', '17:00', 'Funcionamiento normal de motor e hidraulica.', 0, '', 'Normal', 1);

REPLACE INTO `service` (`id`, `equipo`, `fecha`, `horometro`, `lugar`, `observaciones`, `checkCambioFiltro`, `checkCambioLub`, `filtro`, `parteLubricante`, `tipoIntervencion`, `estadoOrden`, `mecanicoResponsable`, `repuestosUtilizados`, `sistemaAfectado`, `costoRepuestos`, `costoManoObra`, `horasTrabajoTaller`, `parteDiarioOrigenId`) VALUES
(501, 120, '2026-10-17', 5422, 'Frente de Obra RN 9', 'Reemplazo de flexible de cilindro de balde y service preventivo 250 hs.', 1, 1, 3, 1, 'Reparacion Correctiva', 'En Proceso', 'Dario Villalba', 'Manguera Hidraulica R2 3/4 + Filtros Komatsu', 'Hidraulico y Motor', 244.00, 180.00, 4.50, 1001),
(502, 102, '2026-10-15', 8194, 'Taller Central', 'Cambio de rodamientos SKF tambor secador y calibracion de quemador.', 0, 1, 1, 1, 'Reparacion Correctiva', 'En Proceso', 'Roberto Sanchez', 'Rodamientos SKF 22218 + Correas en V', 'Tren Rotativo Planta Asfalto', 890.00, 450.00, 14.00, NULL),
(503, 94, '2026-10-12', 6480, 'Taller Central', 'Service preventivo completo de 500 hs en Pala Cargadora Tian Gong ZL50H.', 1, 1, 1, 1, 'Mantenimiento Preventivo', 'Completado', 'Roberto Sanchez', 'Kit Filtros Aceite, Combustible y Aire', 'Motor y Transmision', 310.00, 160.00, 5.00, NULL);

REPLACE INTO `gastos_equipos` (`id`, `equipoId`, `equipoCodigo`, `fecha`, `categoriaGasto`, `proveedor`, `nroComprobante`, `montoUsd`, `obraId`, `registradoPor`, `descripcion`) VALUES
(301, 120, 'RE016', '2026-10-17', 'Combustible', 'YPF Ruta / Cisterna Obra', 'FC-A-0012-00094812', 214.50, 1, 'Laura Gomez', 'Carga de 165 Lts Diesel en Frente de Obra RN 9'),
(302, 120, 'RE016', '2026-10-17', 'Repuestos y Filtros', 'Distribuidora Vial e Hidraulica SRL', 'FC-A-0004-00018290', 424.00, 1, 'Laura Gomez', 'Manguera alta presion + filtros Komatsu (OT #501)'),
(303, 102, 'PL001', '2026-10-15', 'Reparacion Externa', 'Rodamientos Industriales Centro SA', 'FC-A-0008-00044112', 1340.00, 5, 'Laura Gomez', 'Rodamientos SKF tambor secador Planta de Asfalto (OT #502)');

REPLACE INTO `movimientos_obra` (`id`, `equipoId`, `equipoCodigo`, `obraOrigenId`, `obraDestinoId`, `fecha`, `tipoMovimiento`, `autorizadoPor`, `lecturaHorometro`, `motivoObservaciones`) VALUES
(701, 120, 'RE016', 5, 1, '2026-10-01', 'Designacion a Obra', 'Ing. Carlos Mendez', 5310.00, 'Asignacion en carreton CT001 a Autopista RN 9'),
(702, 86, 'MN004', 1, 3, '2026-10-05', 'Transferencia entre Obras', 'Ing. Carlos Mendez', 4710.00, 'Traslado a Obra Pavimentacion Zona Norte');

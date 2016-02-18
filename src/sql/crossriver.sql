-- phpMyAdmin SQL Dump
-- version 4.4.10
-- http://www.phpmyadmin.net
--
-- Host: localhost:8889
-- Generation Time: Feb 12, 2016 at 04:50 PM
-- Server version: 5.5.42
-- PHP Version: 5.6.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `crossriver`
--

-- --------------------------------------------------------

--
-- Table structure for table `photos`
--

CREATE TABLE `photos` (
  `id` int(10) unsigned NOT NULL,
  `FileName` varchar(128) NOT NULL,
  `Title` varchar(128) NOT NULL DEFAULT '',
  `Description` varchar(256) NOT NULL DEFAULT '',
  `FileSize` int(11) NOT NULL DEFAULT '0',
  `Width` int(11) NOT NULL DEFAULT '0',
  `Height` int(11) NOT NULL DEFAULT '0',
  `Extension` varchar(16) NOT NULL DEFAULT '',
  `ExifImageDescription` varchar(256) NOT NULL DEFAULT '',
  `ExifMake` varchar(64) NOT NULL DEFAULT '',
  `ExifModel` varchar(64) NOT NULL DEFAULT '',
  `ExifArtist` varchar(64) NOT NULL DEFAULT '',
  `ExifCopyright` varchar(64) NOT NULL DEFAULT '',
  `ExifExposureTime` varchar(16) NOT NULL DEFAULT '',
  `ExifFNumber` varchar(16) NOT NULL DEFAULT '',
  `ExifExposureProgram` int(11) NOT NULL DEFAULT '0',
  `ExifISOSpeedRatings` varchar(16) NOT NULL DEFAULT '',
  `ExifDateTimeOriginal` varchar(64) NOT NULL DEFAULT '',
  `ExifMeteringMode` int(11) NOT NULL DEFAULT '0',
  `ExifFlash` int(11) NOT NULL DEFAULT '0',
  `ExifFocalLength` varchar(16) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `photos`
--
ALTER TABLE `photos`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `photos`
--
ALTER TABLE `photos`
  MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
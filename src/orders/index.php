<?php 
$fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';

$str = preg_replace('/^.*\/orders\/(.*)$/','$1', $_SERVER['REQUEST_URI']);

$arr = explode('/', $str);

if (count($arr)!=3)
	exit ('Invalid url');

if ($arr[1]!='photos')
	exit ('Invalid url');

$photo = explode('.',$arr[2]);
$idphoto = $photo[0];

$contents = file($fileroot . '/app.cfg');
$config = array();

foreach ($contents as $line) {
	$kv = explode('=', $line);
	$config[trim($kv[0])] = trim($kv[1]);
}

$dbh = new \PDO("mysql:host=localhost;dbname=" . $config['mysqldb'],  $config['mysqluser'] , $config['mysqlpwd']);

$result = $dbh->query("SELECT CI.*, P.idapi FROM cartitems CI INNER JOIN products P ON P.id=CI.idproduct WHERE idcart='$arr[0]' AND idphoto=$idphoto");

$item = $result->fetchObject();

if (!$item)
	exit ('Invalid order # or photo id');

$arr = glob($fileroot . '/photos/' . sprintf("%02d",$idphoto%100) . '/' . $idphoto . '_*.jpg');

if (count($arr)!=1)
	exit ('Photo does not exist on server');

$size = getimagesize($arr[0]);

$cropWidth = $size[0] * $item->cropwidth/100;
$cropHeight = $size[1] * $item->cropheight/100;
$cropX = $size[0] * $item->cropx/100;
$cropY = $size[1] * $item->cropy/100;

$img = imagecreatefromjpeg($arr[0]); //jpeg file
$imgCropped = imagecreatetruecolor($cropWidth, $cropHeight);

imagecopyresampled($imgCropped, $img, 0, 0, $cropX, $cropY, $cropWidth, $cropHeight, $cropWidth, $cropHeight);
imagedestroy($img);

header('Content-Type: image/jpeg');

// Output the image
imagejpeg($imgCropped);

// Free up memory
imagedestroy($imgCropped);
?>
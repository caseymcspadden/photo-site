<?php 

$str = preg_replace('/^.*\/downloads\/(.*)$/','$1', $_SERVER['REQUEST_URI']);

$arr = explode('/', $str);

//if (count($arr)!=2 && count($arr)!=3)
//	exit ('Invalid file url');

$downloadtype = $arr[0];

$fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
$photoroot = '/Users/caseymcspadden/sites/photo-site/build/photos';
//$fileroot = '/fileroot';
//$photoroot = '/var/www/html/photos';

$contents = file($fileroot . '/app.cfg');
$config = array();

foreach ($contents as $line) {
	$kv = explode('=', $line);
	$config[trim($kv[0])] = trim($kv[1]);
}

$dbh = new \PDO("mysql:host=localhost;dbname=" . $config['mysqldb'],  $config['mysqluser'] , $config['mysqlpwd']);

if ($downloadtype=='archive') {
	$filename =  $arr[1];
	$stmt = $dbh->prepare("SELECT * FROM archives WHERE id=?");
	$stmt->execute([$filename]);
	$archive = $stmt->fetchObject();
	if (!$archive)
		exit ('Not a valid file link');
	$dbh->query("UPDATE archives SET downloads=downloads+1 WHERE id='$filename'");
	$filename .= '.zip';
	$filepath = $fileroot . '/downloads/' . $filename;

	header("Pragma: public");
	header("Expires: 0");
	header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
	header("Cache-Control: public");
	header("Content-Description: File Transfer");
	header("Content-type: application/octet-stream");
	header("Content-Disposition: attachment; filename=\"".$filename."\"");
	header("Content-Transfer-Encoding: binary");
	header("Content-Length: ".filesize($filepath));
	//ob_end_flush();
	@readfile($filepath);
}
else if ($downloadtype=='file') {
	$sizemap = array(1=>'S', 2=>'M', 3=>'L', 4=>'X');

	$idgallery = $arr[1];
	$urlsuffix = $arr[2];
	$id = $arr[3];
	$result = $dbh->query("SELECT C.access, C.maxdownloadsize, C.downloadgallery, C.downloadfee, C.idpayment, P.title, P.uid FROM containers C INNER JOIN containerphotos CP ON CP.idcontainer=C.id INNER JOIN photos P ON P.id=CP.idphoto WHERE C.id=$idgallery AND C.urlsuffix='$urlsuffix' AND CP.idphoto=$id");
	if ($result===FALSE)
		exit ('Not a valid file link');
	$photo = $result->fetchObject();
	if (!$photo)
		exit ('Not a valid file link');
	if ($photo->downloadgallery==0 || $photo->maxdownloadsize==0 || ($photo->downloadgallery==2 && $photo->downloadfee>0 && $photo->idpayment=0))
		exit ('Permission denied');
	$size = $photo->maxdownloadsize;
	if ($size==5) 
		$arr = glob($fileroot . '/photos/' . substr($photo->uid,strlen($photo->uid)-2) . '/' . $photo->uid . '_*.jpg');
  	else
  		$arr = glob($photoroot . '/' . substr($photo->uid,strlen($photo->uid)-2) . '/' . $photo->uid . '_' . $sizemap[$size] . '.jpg');
  	if (count($arr)==0)
		exit ('File not found');

  	$filename = $photo->title ? $photo->title . '.jpg' : 'image.jpg';
  	$filepath = $arr[0];

	header("Pragma: public");
	header("Expires: 0");
	header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
	header("Cache-Control: public");
	header("Content-Description: File Transfer");
	header("Content-type: application/octet-stream");
	header("Content-Disposition: attachment; filename=\"".$filename."\"");
	header("Content-Transfer-Encoding: binary");
	header("Content-Length: ".filesize($filepath));
	//ob_end_flush();
	@readfile($filepath);  	
}
else if ($downloadtype=='print') {
	$printid = $arr[1];

	$photo = explode('.',$arr[2]);
	$idphoto = $photo[0];

	$result = $dbh->query("SELECT OI.* , P.uid FROM orderitems OI INNER JOIN orders O ON O.id=OI.idorder INNER JOIN photos P ON P.id = OI.idphoto WHERE O.printid='$printid' AND idphoto=$idphoto");

	$item = $result->fetchObject();

	if (!$item)
		exit ('Invalid photo id');

	$arr = glob($fileroot . '/photos/' . substr($item->uid,strlen($item->uid)-2) . '/' . $item->uid . '_*.jpg');

	if (count($arr)!=1)
		exit ('Photo does not exist on server');

	$size = getimagesize($arr[0]);

	$cropArray = array( 
		'x' => $size[0] * $item->cropx/100,
		'y' => $size[1] * $item->cropy/100,
		'width' => $size[0] * $item->cropwidth/100,
		'height' => $size[1] * $item->cropheight/100
	);

	$img = imagecreatefromjpeg($arr[0]); //jpeg file
	$imgCropped = imagecrop($img, $cropArray);

	imagedestroy($img);

	header('Content-Type: image/jpeg');

	// Output the image
	imagejpeg($imgCropped);

	// Free up memory
	imagedestroy($imgCropped);
}
else if ($downloadtype=='orderedphoto') {
	$orderid = $arr[1];

	$photo = explode('.',$arr[2]);
	$id = $photo[0];

	$result = $dbh->query("SELECT OI.*, P.uid FROM orderitems OI INNER JOIN orders O ON O.id=OI.idorder INNER JOIN photos P ON P.id=OI.idphoto WHERE O.orderid='$orderid' AND OI.id=$id");

	$item = $result->fetchObject();

	if (!$item)
		exit ('Invalid photo id');

	$arr = glob($photoroot . '/' . substr($item->uid,strlen($item->uid)-2) . '/' . $item->uid . '_S.jpg');

	if (count($arr)!=1)
		exit ('Photo does not exist on server');

	$size = getimagesize($arr[0]);

	$cropArray = array( 
		'x' => $size[0] * $item->cropx/100,
		'y' => $size[1] * $item->cropy/100,
		'width' => $size[0] * $item->cropwidth/100,
		'height' => $size[1] * $item->cropheight/100
	);

	$img = imagecreatefromjpeg($arr[0]); //jpeg file
	$imgCropped = imagecrop($img, $cropArray);

	imagedestroy($img);

	header('Content-Type: image/jpeg');

	// Output the image
	imagejpeg($imgCropped);

	// Free up memory
	imagedestroy($imgCropped);
}
else if ($downloadtype=='cartphoto') {
	$idcart = $arr[1];

	$photo = explode('.',$arr[2]);
	$id = $photo[0];

	$result = $dbh->query("SELECT CI.*, P.uid FROM cartitems CI INNER JOIN photos P ON P.id=CI.idphoto WHERE CI.idcart='$idcart' AND CI.id=$id");

	$item = $result->fetchObject();

	if (!$item)
		exit ('Invalid photo id');

	$arr = glob($photoroot . '/' . substr($item->uid,strlen($item->uid)-2) . '/' . $item->uid . '_S.jpg');

	if (count($arr)!=1)
		exit ('Photo does not exist on server');

	$size = getimagesize($arr[0]);

	$cropArray = array( 
		'x' => $size[0] * $item->cropx/100,
		'y' => $size[1] * $item->cropy/100,
		'width' => $size[0] * $item->cropwidth/100,
		'height' => $size[1] * $item->cropheight/100
	);

	$img = imagecreatefromjpeg($arr[0]); //jpeg file
	$imgCropped = imagecrop($img, $cropArray);

	imagedestroy($img);

	header('Content-Type: image/jpeg');

	// Output the image
	imagejpeg($imgCropped);

	// Free up memory
	imagedestroy($imgCropped);
}
?>
<?php 

$str = preg_replace('/^.*\/downloads\/(.*)$/','$1', $_SERVER['REQUEST_URI']);

$arr = explode('/', $str);

if (count($arr)!=2 && count($arr)!=4)
	exit ('Invalid file url');

$downloadtype = $arr[0];

error_log("download type = $downloadtype");

$fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
$photoroot = '/Users/caseymcspadden/sites/photo-site/build/photos';

$contents = file($fileroot . '/app.cfg');
$config = array();

foreach ($contents as $line) {
	$kv = explode('=', $line);
	$config[trim($kv[0])] = trim($kv[1]);
}

$dbh = new \PDO("mysql:host=localhost;dbname=" . $config['mysqldb'],  $config['mysqluser'] , $config['mysqlpwd']);

if ($downloadtype=='archive') {
	$filename =  $arr[1];
	$result = $dbh->query("SELECT * FROM archives WHERE id='$filename'");
	$archive = $result->fetchObject();
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
	$result = $dbh->query("SELECT C.access, C.maxdownloadsize, C.downloadgallery, C.downloadfee, C.idpayment, P.title FROM containers C INNER JOIN containerphotos CP ON CP.idcontainer=C.id INNER JOIN photos P ON P.id=CP.idphoto WHERE C.id=$idgallery AND C.urlsuffix='$urlsuffix' AND CP.idphoto=$id");
	if ($result===FALSE)
		exit ('Not a valid file link');
	$photo = $result->fetchObject();
	if (!$photo)
		exit ('Not a valid file link');
	if ($photo->downloadgallery==0 || ($photo->downloadgallery==1 && $photo->downloadfee>0 && $photo->idpayment=0))
		exit ('Permission denied');
	$size = $photo->maxdownloadsize;
	if ($size==5)
		$arr = glob($fileroot . '/photos/' . sprintf("%02d",$id%100) . '/' . $id . '_*.jpg');
  	else
  		$arr = glob($photoroot . '/' . sprintf("%02d",$id%100) . '/' . $id . '_' . $sizemap[$size] . '.jpg');
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
else if ($downloadtype=='orders') {
	$guid = $arr[1];

	$photo = explode('.',$arr[3]);
	$idphoto = $photo[0];

	$result = $dbh->query("SELECT OI.* FROM orderitems OI INNER JOIN orders O ON O.id=OI.idorder WHERE O.guid='$guid' AND idphoto=$idphoto");

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
}
?>
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
}

// http headers for zip downloads*
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
?>
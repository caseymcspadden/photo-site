<?php 

$str = preg_replace('/^.*\/downloads\/(.*)$/','$1', $_SERVER['REQUEST_URI']);

$arr = explode('/', $str);

if (count($arr)!==2)
	exit ('File link is missing or invalid');

$downloadtype = $arr[0];

error_log("download type = $downloadtype");

$fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';

$contents = file($fileroot . '/app.cfg');
$config = array();

foreach ($contents as $line) {
	$kv = explode('=', $line);
	$config[trim($kv[0])] = trim($kv[1]);
}

$dbh = new \PDO("mysql:host=localhost;dbname=" . $config['mysqldb'],  $config['mysqluser'] , $config['mysqlpwd']);

$filename =  $arr[1];

$result = $dbh->query("SELECT * FROM archives WHERE id='$filename'");

$archive = $result->fetchObject();

if (!$archive)
	exit ('Not a valid file link');

$dbh->query("UPDATE archives SET downloads=downloads+1 WHERE id='$filename'");

$filepath = $fileroot . '/downloads/';

$filename .= '.zip';

// http headers for zip downloads*
header("Pragma: public");
header("Expires: 0");
header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
header("Cache-Control: public");
header("Content-Description: File Transfer");
header("Content-type: application/octet-stream");
header("Content-Disposition: attachment; filename=\"".$filename."\"");
header("Content-Transfer-Encoding: binary");
header("Content-Length: ".filesize($filepath.$filename));
//ob_end_flush();
@readfile($filepath.$filename);
?>
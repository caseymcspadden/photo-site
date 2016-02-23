<?php
require './vendor/autoload.php';

// Change these three paths when moving to a production environment
// $fileroot = path used by PHP to write to folder holding original photos. Should be behind the web root
// $photoroot = path used by PHP to write to thumbnail folder
// $webroot = root of httpd file structure

$fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
$photoroot = '/Users/caseymcspadden/sites/photo-site/build/photos';
$webroot = '/photo-site/build';

$config = array();

$contents = file($fileroot . '/app.cfg');

foreach ($contents as $line) {
    $kv = explode('=', $line);
    $config[trim($kv[0])] = trim($kv[1]);
}

//$mysqli = mysqli_connect(NULL, 'web', 'taylor0619', 'crossriver');
$mysqli = mysqli_connect(NULL, $config['mysqluser'], $config['mysqlpwd'] , $config['mysqldb']);

if(!$mysqli) {
    echo "Can't connect to database";
    exit();
}

$app = new \Slim\App();


// Get container
$container = $app->getContainer();

// Register component on container
$container['view'] = function ($container) {
    $view = new \Slim\Views\Twig('./templates', [
        'cache' => false
        //'cache' => 'path/to/cache'
    ]);
    $view->addExtension(new \Slim\Views\TwigExtension(
        $container['router'],
        $container['request']->getUri()
    ));

    return $view;
};

$container['options'] = [
    'fileroot'=>$fileroot,
    'webroot'=>$webroot,
    'photoroot'=>$photoroot,
    'mysqli'=>$mysqli
];

// Define app routes
$app->get('/', function ($request, $response, $args) {
    return $this->view->render($response, 'main.html' , [
        'options'=>$this->options
	]);
})->setName('main');

$app->get('/portfolio', function ($request, $response, $args) {
    return $this->view->render($response, 'portfolio.html' , [
        'options'=>$this->options
    ]);
})->setName('portfolio');

$app->get('/about', function ($request, $response, $args) {
    return $this->view->render($response, 'about.html' , [
        'options'=>$this->options
    ]);
})->setName('about');

$app->get('/contact', function ($request, $response, $args) {
    return $this->view->render($response, 'contact.html' , [
        'options'=>$this->options
    ]);
})->setName('contact');

$app->get('/admin', function ($request, $response, $args) {
    $photos = array();
    $folders = array();
    $galleries = array();
    $mysqli = $this->options['mysqli'];
    $result = $mysqli->query("SELECT F.id AS fid, F.name AS fname, G.id as gid, G.name as gname, GP.idphoto as pid FROM folders F INNER JOIN foldergalleries FG On FG.idfolder = F.id INNER JOIN galleries G ON G.id=FG.idgallery LEFT JOIN galleryphotos GP ON GP.idgallery=G.id ORDER BY fid, gid, pid");

    $currentfolder=0;
    $currentgallery=0; 
    $findex=0;
    $gindex=0;

    while ($row = $result->fetch_assoc())
    {
      $fid = $row['fid'];
      $gid = $row['gid'];
      $fname = $row['fname'];
      $gname = $row['gname'];

      if ($currentfolder==0 || $currentfolder!=$fid) {
        $currentfolder = $fid;
        array_push($folders, ['id'=>$fid, 'Name'=>$fname, 'Galleries'=>array()]);
        $findex = count($folders)-1;
      }

      if ($currentgallery==0 || $currentgallery!=$gid) {
        $currentgallery = $gid;
        array_push($folders[$findex]['Galleries'], ['id'=>$gid, 'Name'=>$gname, 'Photos'=>[]]);
        $gindex = count($folders[$findex]['Galleries'])-1;
       }

      array_push($folders[$findex]['Galleries'][$gindex]['Photos'],$row['pid']);
    }

    $result = $mysqli->query("SELECT * FROM photos");

    while ($row = $result->fetch_assoc())
      array_push($photos, $row);

    return $this->view->render($response, 'admin.html' , [
        'options'=>$this->options,
        'folders'=>$folders,
        'photos'=> $photos
    ]);
})->setName('admin');

$app->post('/services/upload', function($request, $response, $args) {
    $fileSizes = [
      //'X3'=>[1600,1200],
      'X'=>[1280,960],
      //'X'=>[1024,768],
      'L'=>[800,600],
      'M'=>[600,450],
      'S'=>[400,300],
      'T'=>[150,150],
      //'TS'=>[100,100],
    ];


    $exifDefaults = [
        'ImageDescription' => '',
        'Make' => '',
        'Model' => '',
        'Artist' => '',
        'Copyright' => '',
        'ExposureTime' => '',
        'FNumber' => '',
        'ExposureProgram' => '0',
        'ISOSpeedRatings' => '',
        'DateTimeOriginal' => '',
        'MeteringMode' => '0',
        'Flash' => '0',
        'FocalLength' => '' 
    ];
    $mysqli = $this->options['mysqli'];

    $text = '';
    $fileroot = $this->options['fileroot'];
    $photoroot = $this->options['photoroot'];

    //$watermark = imagecreatefrompng($fileroot . '/watermark.png');
    //$wmsize = getimagesize($fileroot . '/watermark.png');

    $text .= "watermark w=$wmsize[0], h=$wmsize[1]\n";

    for ($i=0; $i<count($_FILES['file']['tmp_name']);$i++) {
        $tmp = $_FILES['file']['tmp_name'][$i];
        $name = $_FILES['file']['name'][$i];

        $text .=  "$tmp\n";

        $exif =  array_merge($exifDefaults, exif_read_data($tmp));
   
        $allowedTypes = array(IMAGETYPE_PNG, IMAGETYPE_JPEG, IMAGETYPE_GIF);
        $detectedType = exif_imagetype($tmp);
        $error = !in_array($detectedType, $allowedTypes);
        if ($error)
            $text .= "NOT AN IMAGE\n";
        else {
          $size = getimagesize($tmp);
          $extension = pathinfo($name,PATHINFO_EXTENSION);

          $mysqli->query("INSERT INTO photos 
           (FileName, FileSize, Width, Height, Extension, ExifImageDescription, ExifMake, ExifModel, ExifArtist, ExifCopyright, ExifExposureTime,
            ExifFNumber, ExifExposureProgram, ExifISOSpeedRatings, ExifDateTimeOriginal, ExifMeteringMode, ExifFlash, ExifFocalLength) VALUES ("
            ."'$name',"
            .filesize($tmp) . ','
            .$size[0] . ','
            .$size[1] . ','
            ."'$extension',"
            ."'$exif[ImageDescription]',"
            ."'$exif[Make]',"
            ."'$exif[Model]',"
            ."'$exif[Artist]',"
            ."'$exif[Copyright]',"
            ."'$exif[ExposureTime]',"
            ."'$exif[FNumber]',"
            ."'$exif[ExposureProgram]',"
            ."'$exif[ISOSpeedRatings]',"
            ."'$exif[DateTimeOriginal]',"
            ."'$exif[MeteringMode]',"
            ."'$exif[Flash]',"
            ."'$exif[FocalLength]')");

            $id = $mysqli->insert_id;

            $im=FALSE;
            
            switch($size["mime"]) {
              case "image/jpeg":
                $im = imagecreatefromjpeg($tmp); //jpeg file
                $text .= "jpg file\n";
                break;
              case "image/gif":
                $im = imagecreatefromgif($tmp); //gif file
                break;
              case "image/png":
                $im = imagecreatefrompng($tmp); //png file
                break;
              default: 
                $im=false;
                break;
              }

              $aspect = $size[1]/$size[0];  // height/width

              $imlarger=FALSE;
              $wlarger=0;
              $hlarger=0;
 
              foreach ($fileSizes as $postfix => $wh) {
                $w = $wh[0];
                $h = $w * $aspect;

                if ($h > $wh[1]) {
                  $h = $wh[1];
                  $w = $h/$aspect;
                }

                if ($w<=$size[0] || $h<=$size[1]) { // only make the image if smaller than the original
                  if ($imlarger===FALSE) {
                    $imlarger = $im;
                    $wlarger = $size[0];
                    $hlarger = $size[1];
                  }
                  if ($postfix=='T') {   //Make a square thumbnail
                    $srcx = ($hlarger > $wlarger) ? 0 : ($wlarger-$hlarger)/2;
                    $srcy = ($hlarger > $wlarger) ? ($hlarger-$wlarger)/2 : 0;
                    $srcw = ($hlarger > $wlarger) ? $wlarger : $hlarger;
                    $im2 = imagecreatetruecolor($wh[0], $wh[0]);
                    imagecopyresampled ($im2, $imlarger, 0, 0, $srcx, $srcy, $wh[0], $wh[0], $srcw, $srcw);
                  }
                  else {
                    $im2 = imagecreatetruecolor($w, $h);
                    imagecopyresampled ($im2, $imlarger, 0, 0, 0, 0, $w, $h, $wlarger, $hlarger);
                  }
                  imagejpeg($im2, $photoroot . '/' . $id . "_$postfix" . '.jpg');
                  $imlarger=$im2;
                  $wlarger = $w;
                  $hlarger = $h;
                }
              }
            move_uploaded_file( $tmp , $fileroot . '/photos/' . $id . "_$name");
        }
        $text .= "\n";
    }

    $response->getBody()->write($text);
    return $response;

    //return $response->withHeader('Content-type', 'application/json');
});

// Run app
$app->run();
?>
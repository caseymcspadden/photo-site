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
    return $this->view->render($response, 'admin.html' , [
        'options'=>$this->options,
    ]);
})->setName('admin');

$app->get('/services/photos/{id:[0-9]*}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $query = "SELECT * FROM photos WHERE " . ($args['id'] ? "id=$args[id]" : '1');

  $arr = array();

  $result = $mysqli->query($query);

  while ($row = $result->fetch_assoc())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode(count($arr)==1 && $args['id'] ? $arr[0] : $arr));
});


$app->get('/services/folders/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT id, idfolder, position, name, description FROM folders ORDER BY idfolder, position");

  while ($row = $result->fetch_assoc())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));    
});

$app->post('/services/folders/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $result = $mysqli->query("SELECT MAX(position) FROM folders WHERE idfolder=0");

  $row = $result->fetch_row();

  $position = 1 + $row[0];

  $mysqli->query("INSERT INTO folders (idfolder, position, name, description) VALUES (0, $position, '$vals[name]','$vals[description]')");

  $vals['id'] = $mysqli->insert_id;

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->put('/services/folders/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $mysqli->query("UPDATE folders SET idfolder=$vals[idfolder], position=$vals[position], name='$vals[name]', description='$vals[description]' WHERE id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->delete('/services/folders/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
 
  $mysqli->query("DELETE F.*, G.*, GP.* FROM FOLDERS F LEFT JOIN galleries G ON G.idfolder=F.id LEFT JOIN galleryphotos GP ON GP.idgallery= G.id WHERE F.id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});


$app->get('/services/folders/{id:[0-9]+}/galleries/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT id, idfolder, position, name, description, featuredPhoto FROM galleries WHERE idfolder=$args[id] ORDER BY position");

  while ($row = $result->fetch_assoc())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));    
});

$app->get('/services/galleries/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT id, idfolder, position, featuredPhoto, name, description FROM galleries ORDER BY idfolder, position");

  while ($row = $result->fetch_assoc())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));    
});

$app->post('/services/galleries/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $result = $mysqli->query("SELECT MAX(position) FROM galleries WHERE idfolder=$vals[idfolder]");

  $row = $result->fetch_row();

  $position = 1 + $row[0];

  $mysqli->query("INSERT INTO galleries (idfolder, position, name, description) VALUES ($vals[idfolder], $position, '$vals[name]','$vals[description]')");

  $vals['id'] = $mysqli->insert_id;

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->put('/services/galleries/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $mysqli->query("UPDATE galleries SET idfolder=$vals[idfolder], position=$vals[position], name='$vals[name]', description='$vals[description]', featuredPhoto=$vals[featuredPhoto] WHERE id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->delete('/services/galleries/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
 
  $mysqli->query("DELETE G.*, GP.* FROM galleries G LEFT JOIN galleryphotos GP ON GP.idgallery=G.id WHERE G.id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->get('/services/galleries/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT idphoto, position FROM galleryphotos WHERE idgallery=$args[id] ORDER BY position");

  while ($row = $result->fetch_row())
    array_push($arr,$row[0]);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));
});

$app->post('/services/galleries/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $result = $mysqli->query("SELECT MAX(position) FROM galleryphotos WHERE idgallery=$args[id]");

  $row = $result->fetch_row();

  $position = $row ? $row[0]+1 : 1;

  foreach($ids as $id) {
    $mysqli->query("INSERT INTO galleryphotos (idgallery,idphoto,position) VALUES ($args[id],$id,$position)");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->put('/services/galleries/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $position = 1;
  foreach($ids as $id) {
    $mysqli->query("UPDATE galleryphotos SET position=$position WHERE idgallery=$args[id] AND idphoto=$id");
    $position++;
  }
});

$app->delete('/services/galleries/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = $parsedBody['ids'];
  $mysqli->query("DELETE FROM galleryphotos WHERE idgallery=$args[id] AND idphoto IN (" . $ids . ')');

  $ids = array();
  $result = $mysqli->query ("SELECT idphoto FROM galleryphotos WHERE idgallery=$args[id] ORDER BY position");

  while ($row = $result->fetch_row())
    $ids[] = $row[0];

  $position = 1;
  foreach($ids as $id) {
    $mysqli->query("UPDATE galleryphotos SET position=$position WHERE idgallery=$args[id] AND idphoto=$id");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->get('/services/containers/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT id, type, idparent, position, featuredPhoto, name, description FROM containers ORDER BY idparent, position");

  while ($row = $result->fetch_assoc())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr,JSON_NUMERIC_CHECK));    
});

$app->post('/services/containers/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $result = $mysqli->query("SELECT MAX(position) FROM containers WHERE idparent=$vals[idparent]");

  $row = $result->fetch_row();

  $position = 1 + $row[0];

  $mysqli->query("INSERT INTO containers (type, idparent, position, name, description) VALUES ('$vals[type]', $vals[idparent], $position, '$vals[name]','$vals[description]')");

  $vals['id'] = $mysqli->insert_id;

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->put('/services/containers/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $vals = $request->getParsedBody();

  $mysqli->query("UPDATE containers SET idparent=$vals[idparent], position=$vals[position], name='$vals[name]', description='$vals[description]', featuredPhoto=$vals[featuredPhoto] WHERE id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->delete('/services/containers/{id}', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
 
  $mysqli->query("DELETE C.*, CP.* FROM containers C LEFT JOIN containerphotos CP ON CP.idcontainer=C.id WHERE C.id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->get('/services/containers/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];

  $arr = array();

  $result = $mysqli->query("SELECT idphoto, position FROM containerphotos WHERE idcontainer=$args[id] ORDER BY position");

  while ($row = $result->fetch_row())
    array_push($arr,$row[0]);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));
});

$app->post('/services/containers/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $result = $mysqli->query("SELECT MAX(position) FROM containerphotos WHERE idcontainer=$args[id]");

  $row = $result->fetch_row();

  $position = $row ? $row[0]+1 : 1;

  foreach($ids as $id) {
    $mysqli->query("INSERT INTO containerphotos (idcontainer,idphoto,position) VALUES ($args[id],$id,$position)");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->put('/services/containers/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $position = 1;
  foreach($ids as $id) {
    $mysqli->query("UPDATE containerphotos SET position=$position WHERE idcontainer=$args[id] AND idphoto=$id");
    $position++;
  }
});

$app->delete('/services/containers/{id:[0-9]+}/photos/', function($request, $response, $args) {
  $mysqli = $this->options['mysqli'];
  $parsedBody = $request->getParsedBody();
  $ids = $parsedBody['ids'];
  $mysqli->query("DELETE FROM containerphotos WHERE idcontainer=$args[id] AND idphoto IN (" . $ids . ')');

  $ids = array();
  $result = $mysqli->query ("SELECT idphoto FROM containerphotos WHERE idcontainer=$args[id] ORDER BY position");

  while ($row = $result->fetch_row())
    $ids[] = $row[0];

  $position = 1;
  foreach($ids as $id) {
    $mysqli->query("UPDATE containerphotos SET position=$position WHERE idcontainer=$args[id] AND idphoto=$id");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});


$app->post('/services/upload', function($request, $response, $args) {
    $fileSizes = [
      //'X3'=>[1600,1200],
      'X'=>960,
      //'X'=>[1024,768],
      'L'=>600,
      'M'=>450,
      'S'=>300,
      'T'=>150,
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

    $fileroot = $this->options['fileroot'];
    $photoroot = $this->options['photoroot'];

    //$watermark = imagecreatefrompng($fileroot . '/watermark.png');
    //$wmsize = getimagesize($fileroot . '/watermark.png');

    $insertIds = array();

    for ($i=0; $i<count($_FILES['file']['tmp_name']);$i++) {
        $tmp = $_FILES['file']['tmp_name'][$i];
        $name = $_FILES['file']['name'][$i];

        $exif =  array_merge($exifDefaults, exif_read_data($tmp));
   
        $allowedTypes = array(IMAGETYPE_PNG, IMAGETYPE_JPEG, IMAGETYPE_GIF);
        $detectedType = exif_imagetype($tmp);
        if (!in_array($detectedType, $allowedTypes))
          continue;

        $size = getimagesize($tmp);
        $hash = md5_file($tmp);
        $fileSize = filesize($tmp);

        $result = $mysqli->query("SELECT id FROM photos WHERE fileSize=$fileSize AND width=$size[0] AND height=$size[1] AND hash='$hash'");

        if ($result->fetch_row()) {
          continue;
        }
 
       $extension = pathinfo($name,PATHINFO_EXTENSION);
 
        $mysqli->query("INSERT INTO photos 
         (fileName, fileSize, width, height, hash, extension, exifImageDescription, exifMake, exifModel, exifArtist, exifCopyright, exifExposureTime,
          exifFNumber, exifExposureProgram, exifISOSpeedRatings, exifDateTimeOriginal, exifMeteringMode, exifFlash, exifFocalLength) VALUES ("
          ."'$name',"
          .$fileSize . ','
          .$size[0] . ','
          .$size[1] . ','
          ."'$hash',"
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
          array_push($insertIds, $id);

          $subdirectory = sprintf("%02d",$id%100);         
          if (!file_exists($photoroot . "/$subdirectory/"))
            mkdir($photoroot . "/$subdirectory");
          if (!file_exists($fileroot . "/photos/$subdirectory/"))
            mkdir($fileroot . "/photos/$subdirectory");

          $im=FALSE;
          
          switch($size["mime"]) {
            case "image/jpeg":
              $im = imagecreatefromjpeg($tmp); //jpeg file
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

            foreach ($fileSizes as $postfix => $h) {
              //$w = ($aspect<1) ? $sz : $sz/$aspect;
              //$h = ($aspect<1) ? $sz*$aspect : $sz;
              $w = $h/$aspect;

              if ($w<=$size[0] && $h<=$size[1]) { // only make the image if smaller than the original
                if ($imlarger===FALSE) {
                  $imlarger = $im;
                  $wlarger = $size[0];
                  $hlarger = $size[1];
                }
                if ($postfix=='T') {   //Make a square thumbnail
                  $srcx = ($hlarger > $wlarger) ? 0 : ($wlarger-$hlarger)/2;
                  $srcy = ($hlarger > $wlarger) ? ($hlarger-$wlarger)/2 : 0;
                  $srcw = ($hlarger > $wlarger) ? $wlarger : $hlarger;
                  $im2 = imagecreatetruecolor($h, $h);
                  imagecopyresampled ($im2, $imlarger, 0, 0, $srcx, $srcy, $h, $h, $srcw, $srcw);
                }
                else {
                  $im2 = imagecreatetruecolor($w, $h);
                  imagecopyresampled ($im2, $imlarger, 0, 0, 0, 0, $w, $h, $wlarger, $hlarger);
                }
                imagejpeg($im2, $photoroot . "/$subdirectory/" . $id . "_$postfix" . '.jpg');
                $imlarger=$im2;
                $wlarger = $w;
                $hlarger = $h;
              }
            }
            move_uploaded_file( $tmp , $fileroot . "/photos/$subdirectory/" . $id . "_$name");
    }
  
    $arr = array();

    if (count($insertIds)>0) {
      $query = 'SELECT * FROM photos WHERE id IN (' . implode(',', $insertIds) . ')';
      $result = $mysqli->query($query);
      while ($row = $result->fetch_assoc())
        array_push($arr,$row);
    }

    return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));
    //return $response->withHeader('Content-type', 'application/json');
});

// Run app
$app->run();
?>
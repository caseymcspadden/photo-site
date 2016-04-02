<?php
require './vendor/autoload.php';
require './classes/CrossRiver/Services.php';

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

$dbh = new PDO("mysql:host=localhost;dbname=$config[mysqldb]", $config['mysqluser'], $config['mysqlpwd']);

if(!$dbh) {
    echo "Can't connect to database";
    exit();
}

$cfg = new PHPAuth\Config($dbh);
$auth = new PHPAuth\Auth($dbh, $cfg);


// Get container
//$container = new \Slim\$app->getContainer();
$container = new \Slim\Container;
$app = new \Slim\App($container);


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

$container['services'] = function($container) {
    return new CrossRiver\Services();
};

/*
$container['cookies'] = function($container){
    $request = $container->get('request');
    return Dflydev\FigCookies\Cookies::fromRequest($request);   
};

$container['setCookies'] = function($container){
    $response = $container->get('response');
    return Dflydev\FigCookies\SetCookies::fromResponse($response);   
};
*/

$container['options'] = [
    'fileroot'=>$fileroot,
    'webroot'=>$webroot,
    'photoroot'=>$photoroot,
    'dbh'=>$dbh,
    'auth'=>$auth
];

// Define app routes
$app->get('/', function ($request, $response, $args) {
    return $this->view->render($response, 'home.html' , [
        'webroot'=>$this->services->webroot
  ]);
})->setName('home');

$app->get('/portfolio', function ($request, $response, $args) {
    return $this->view->render($response, 'portfolio.html' , [
        'webroot'=>$this->services->webroot
    ]);
})->setName('portfolio');

$app->get('/about', function ($request, $response, $args) {
    return $this->view->render($response, 'about.html' , [
        'webroot'=>$this->services->webroot
    ]);
})->setName('about');

$app->get('/admin', function ($request, $response, $args) {
    return $this->view->render($response, "admin.html" , [
        'webroot'=>$this->services->webroot
    ]);
})->setName('admin');

$app->get('/admin/{task}', function ($request, $response, $args) {
    return $this->view->render($response, "admin-$args[task].html" , [
        'webroot'=>$this->services->webroot
    ]);
})->setName('admin');

// SERVICES ROUTES

$app->get('/services/users', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM users");

  $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->post('/services/users', function($request, $response, $args) {
  $vals = $request->getParsedBody();

  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else {
    $result = $this->services->register($vals['email'], $vals['password'], $vals['repeat-password'], ['name'=>$vals['name'], 'company'=>$vals['company']]);
    if ($result['error']==true)
      $json = json_encode($result);
    else
      $json = $this->services->fetchJSON("SELECT * FROM users WHERE email='$vals[email]'",true);
  }
  return $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->get('/services/session', function($request, $response, $args) {
  $json = $this->services->getSessionUser();
  
  $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->put('/services/session', function($request, $response, $args) {
  $ret = $this->services->logout($this->services->getSessionHash());
  $result=array();
  $result['error'] = !$ret;
  $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($result,JSON_NUMERIC_CHECK));
});

$app->post('/services/session', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  $result = $this->services->login($vals['email'], $vals['password'], $vals['remember']);
  if ($result['error']==true)
    $json = json_encode($result);
  else 
    $json = $this->services->fetchJSON("SELECT S.hash, S.expiredate, U.id, U.isadmin, U.email, U.name, U.company FROM sessions S INNER JOIN users U ON U.id=S.uid WHERE S.hash='$result[hash]'",true);
  $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->get('/services/photos', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM photos");

  return $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->delete('/services/photos', function($request, $response, $args) {
  $dbh = $this->options['dbh'];

  $fileroot = $this->options['fileroot'];
  $photoroot = $this->options['photoroot'];

  $parsedBody = $request->getParsedBody();

  $dbh->query("DELETE P, CP FROM photos P INNER JOIN containerphotos CP ON CP.idphoto=P.id WHERE P.id IN (" . $parsedBody['ids'] . ")");

  $arr = explode(',', $parsedBody['ids']);

  foreach ($arr as $id) {
    $subdirectory = sprintf("%02d",$id%100);
    //error_log($fileroot . '/photos/' . $subdirectory .'/' . $id . '_*.jpg');      
    //error_log($photoroot . '/' . $subdirectory .'/' . $id . '_*.jpg');      
    array_map('unlink', glob($fileroot . '/photos/' . $subdirectory .'/' . $id . '_*.jpg'));      
    array_map('unlink', glob($photoroot . '/' . $subdirectory .'/' . $id . '_*.jpg'));      
    //array_map('unlink', glob($photoroot . '/' . $subdirectory .'/' . $id . '_*.jpg'));
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->get('/services/photos/{id:[0-9]*}', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM photos WHERE id=$args[id]",true);

  return $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->get('/services/featuredphotos', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT P.id, P.fileName, P.title, P.description FROM photos P INNER JOIN containerphotos CP ON CP.idphoto=P.id INNER JOIN containers C ON C.id=CP.idcontainer WHERE C.isfeatured=1 ORDER BY CP.idcontainer,CP.position");

  return $response->withHeader('Content-Type','application/json')->getBody()->write($json);
});

$app->get('/services/containers', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT id, type, idparent, position, featuredPhoto, name, description, watermark FROM containers ORDER BY idparent, position");

  return $response->withHeader('Content-Type','application/json')->getBody()->write($json);    
});

$app->post('/services/containers', function($request, $response, $args) {
  $vals = $request->getParsedBody();

  $result = $this->services->dbh->query("SELECT MAX(position) FROM containers WHERE idparent=$vals[idparent]");

  $row = $result->fetch();

  $position = $row ? 1 + $row[0] : 1;

  $this->services->dbh->query("INSERT INTO containers (type, idparent, position, name, description) VALUES ('$vals[type]', $vals[idparent], $position, '$vals[name]','$vals[description]')");

  $vals['id'] = $this->services->dbh->lastInsertId();

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

/*
$app->get('/services/containers/{id}', function($request, $response, $args) {
  $dbh = $this->options['dbh'];

  $arr = array();

  $result = $dbh->query("SELECT id, type, idparent, position, featuredPhoto, name, description, watermark FROM containers WHERE id = $args[id] ORDER BY position");

  while ($row = $result->fetchObject())
    array_push($arr,$row);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr,JSON_NUMERIC_CHECK));
});
*/

$app->put('/services/containers/{id}', function($request, $response, $args) {
  $dbh = $this->options['dbh'];
  $vals = $request->getParsedBody();

  $dbh->query("UPDATE containers SET idparent=$vals[idparent], position=$vals[position], name='$vals[name]', description='$vals[description]', featuredPhoto=$vals[featuredPhoto], isportfolio=$vals[isportfolio] WHERE id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($vals));
});

$app->delete('/services/containers/{id}', function($request, $response, $args) {
  $dbh = $this->options['dbh'];
  $parsedBody = $request->getParsedBody();
 
  $dbh->query("DELETE C.*, CP.* FROM containers C LEFT JOIN containerphotos CP ON CP.idcontainer=C.id WHERE C.id=$args[id]");

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->get('/services/containers/{id:[0-9]+}/photos', function($request, $response, $args) {
  $arr = array();

  $result = $this->services->dbh->query("SELECT idphoto FROM containerphotos WHERE idcontainer=$args[id] ORDER BY position");

  while ($row = $result->fetch())
    array_push($arr,$row[0]);

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr,JSON_NUMERIC_CHECK));
});

$app->post('/services/containers/{id:[0-9]+}/photos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $result = $this->services->dbh->query("SELECT MAX(position) FROM containerphotos WHERE idcontainer=$args[id]");

  $row = $result->fetch();

  $position = $row ? $row[0]+1 : 1;

  foreach($ids as $id) {
    $this->services->dbh->query("INSERT INTO containerphotos (idcontainer,idphoto,position) VALUES ($args[id],$id,$position)");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});

$app->put('/services/containers/{id:[0-9]+}/photos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);

  $position = 1;
  foreach($ids as $id) {
    $this->services->dbh->query("UPDATE containerphotos SET position=$position WHERE idcontainer=$args[id] AND idphoto=$id");
    $position++;
  }
});

$app->delete('/services/containers/{id:[0-9]+}/photos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  $ids = $parsedBody['ids'];
  $this->services->dbh->query("DELETE FROM containerphotos WHERE idcontainer=$args[id] AND idphoto IN (" . $ids . ')');

  $ids = array();
  $result = $this->services->dbh->query ("SELECT idphoto FROM containerphotos WHERE idcontainer=$args[id] ORDER BY position");

  while ($row = $result->fetch())
    $ids[] = $row[0];

  $position = 1;
  foreach($ids as $id) {
    $this->services->dbh->query("UPDATE containerphotos SET position=$position WHERE idcontainer=$args[id] AND idphoto=$id");
    $position++;
  }

  return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($parsedBody));
});


$app->post('/services/upload', function($request, $response, $args) {
    $dbh = $this->services->dbh;
    $fileroot = $this->services->fileroot;
    $photoroot = $this->services->photoroot;

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

    $watermark = NULL;
    $wmsize = NULL;

    $arr = $request->getHeader('Watermark');

    if (count($arr)>0 && $arr[0]=='1') {
      $watermark = imagecreatefrompng($fileroot . '/watermark.png');
      $wmsize = getimagesize($fileroot . '/watermark.png');
    }

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

        $result = $dbh->query("SELECT id FROM photos WHERE fileSize=$fileSize AND width=$size[0] AND height=$size[1] AND hash='$hash'");

        if ($result->fetch()) {
          continue;
        }
 
       $extension = pathinfo($name,PATHINFO_EXTENSION);
 
        $dbh->query("INSERT INTO photos 
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

          $id = $dbh->lastInsertId();
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
                  $imsave = $im2;
                  imagecopyresampled ($im2, $imlarger, 0, 0, $srcx, $srcy, $h, $h, $srcw, $srcw);
                }
                else {
                  $im2 = imagecreatetruecolor($w, $h);
                  $imsave = $im2;
                  imagecopyresampled ($im2, $imlarger, 0, 0, 0, 0, $w, $h, $wlarger, $hlarger);
                  if ($postfix=='X' && $watermark) {
                    $imsave = imagecreatetruecolor($w, $h);
                    imagecopy($imsave, $im2, 0, 0, 0, 0, $w, $h);
                    imagecopyresampled ($imsave , $watermark , 10 , $h-10-$wmsize[1], 0 , 0 , $wmsize[0] , $wmsize[1] , $wmsize[0] , $wmsize[1] );      
                  }

                }
                imagejpeg($imsave, $photoroot . "/$subdirectory/" . $id . "_$postfix" . '.jpg');
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
      $result = $dbh->query($query);
      while ($row = $result->fetchObject())
        array_push($arr,$row);
    }

    return $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($arr));
    //return $response->withHeader('Content-type', 'application/json');
});

// Run app
$app->run();
?>
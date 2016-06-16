<?php
require '../vendor/autoload.php';
require '../classes/CrossRiver/Services.php';
require '../classes/CrossRiver/Commerce.php';
/*
error_log("IN BAMENDA.PHP");
foreach ($_SERVER as $key => $value) {
  error_log("$key = $value");
}
error_log("\n\n");
*/
// Get admin and services paths
// Get container
$container = new \Slim\Container;
$app = new \Slim\App($container);
// Register component on container
$container['view'] = function ($container) {
    $view = new \Slim\Views\Twig('../templates', [
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

$container['commerce'] = function($container) {
    return new CrossRiver\Commerce();
};

$app->get('/bamenda/test', function($request, $response, $args) {
  $json = $this->commerce->makePayment(
    100, 
    'Test Transaction',
    'Casey McSpadden',
    'amex',
    '373284099616004',
    '07/2019',
    '8888',
    '123 Main St',
    NULL,
    'Leawood',
    'KS',
    '66206'
  );
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/orders[/{id:[0-9]*}]', function($request, $response, $args) {
  $str = $this->commerce->getOrders(isset($args['id']) ? $args['id'] : NULL);
  $response->getBody()->write($str);
  return $response->withHeader('Content-Type','application/json');
});

$app->post('/bamenda/orders', function($request, $response, $args) {
  $r = $request->getParsedBody();
  $error = FALSE;
  $result = $this->services->dbh->query("SELECT tracked FROM shipping WHERE id=$r[shipping]");
  $arr = $result->fetch(PDO::FETCH_NUM);
  $tracked = $arr ? $arr[0] : 0;
  $order = $this->commerce->createOrder($r['name'],$r['address'],$r['address2'],$r['city'],$r['state'],$r['zip'], $tracked);
  if ($order->errorMessage==null) {
      $guid = $this->services->getRandomKey();
      $this->services->dbh->query("INSERT INTO orders (guid, idpwinty, name, email, address, address2, city, state, zip) VALUES ('$guid', {$order->id}, '$r[name]', '$r[email]', '$r[address]', '$r[address2]', '$r[city]', '$r[state]', '$r[zip]')");
      $idorder = $this->services->dbh->lastInsertId();
      $cartitems = array();
      $result = $this->services->dbh->query("SELECT CI.*, P.idapi FROM cartitems CI INNER JOIN products P ON P.id=CI.idproduct where idcart='$r[cart]'");
      while ($item = $result->fetchObject())
        array_push($cartitems, $item);
      foreach ($cartitems as $item) {
        $photo = $this->commerce->addItemToOrder($order->id, $guid, $this->services->remoteUrlBase, $item);
        if ($photo->errorMessage==null)
           $this->services->dbh->query("INSERT INTO orderitems (idorder, idpwinty, idcontainer, idphoto, idproduct, price, quantity, attrs, cropx, cropy, cropwidth, cropheight) VALUES ($idorder, {$photo->id}, {$item->idcontainer}, {$item->idphoto}, {$item->idproduct}, {$item->price}, {$item->quantity}, '{$item->attrs}', {$item->cropx}, {$item->cropy}, {$item->cropwidth}, {$item->cropheight})");
        else {
          error_log("PWINTY Order create photo error: " . $photo->errorMessage);
          $error = TRUE;
        }
      }
   }
   else {
      error_log("PWINTY Order error: " . $order->errorMessage);
      $error = TRUE;
   }
   if (!$error && $this->commerce->isOrderValid($order->id))
     $this->commerce->submitOrder($order->id);
  $response->getBody()->write(json_encode($order));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/catalog', function($request, $response, $args) {
  $str = $this->commerce->getProductCatalog('US','Pro');
  $response->getBody()->write($str);
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/catalog', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else {
    $str = $this->commerce->getProductCatalog('US','Pro');
    $json = json_decode($str,true);
    foreach ($json['items'] as $item) {
      $result = $this->services->dbh->query("SELECT id FROM products WHERE idapi='$item[name]'");
      if ($result->fetch()) {
        $query = "UPDATE products SET price=$item[priceUSD] WHERE idapi='$item[name]'";
      }
      //else {
        //$query = "INSERT INTO products (id, type, description, hsize, vsize, hsizeprod, vsizeprod, hres, vres, price, shippingtype, attributes) VALUES ('$item[name]', '$item[itemType]', '$item[description]', $item[imageHorizontalSize], $item[imageVerticalSize], $item[fullProductHorizontalSize], $item[fullProductVerticalSize], $item[recommendedHorizontalResolution], $item[recommendedVerticalResolution], $item[priceUSD], '$item[shippingBand]', '" . json_encode($item['attributes']) . "')";
      //}
      $this->services->dbh->query($query);
    }
  }
  $response->getBody()->write(json_encode($json,JSON_NUMERIC_CHECK));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/shipping', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT * FROM shipping");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/products', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT id, api, idapi, type, description, hsize, vsize, hsizeprod, vsizeprod, hres, vres, price, shippingtype, active FROM products ORDER BY type, id");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/products/{id:[0-9]*}', function($request, $response, $args) {
   $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) 
    $this->services->updateTable('products', "id=$args[id]", $parsedBody, array('api', 'idapi', 'type', 'description', 'hsize', 'vsize', 'hsizeprod', 'vsizeprod', 'hres', 'vres', 'price', 'shippingtype', 'active'));
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/productattributes', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT PA.idproduct, PA.idattribute , A.name, A.title, A.validvalues, A.defaultvalue FROM productattributes PA INNER JOIN attributes A ON A.id=PA.idattribute ORDER BY idproduct, idattribute");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/test2[/{path:.*}]', function($request, $response, $args) {
  $json = $this->commerce->getPayments(isset($args['path']) ? $args['path'] : NULL);
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/settings/{id:[0-9]*}', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM settings WHERE iduser=$args[id]", true);
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/settings/{id:[0-9]*}', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) 
    $this->services->updateTable('settings', "iduser=$args[id]", $parsedBody, array('portfoliofolder', 'featuredgallery'));
  $response->getBody()->write(json_encode($parsedBody,JSON_NUMERIC_CHECK));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/users', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT id, email, isactive, dt, isadmin, name, company, idcontainer FROM users");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/users/{id:[0-9]*}', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else {
    //if (isset($vals['password']) && isset($vals['repeat-password']))
      //$result = $this->services->changePassword($args['id'],  $vals['email'], $vals['password'], $vals['repeat-password'], 
    //else {
      $rslt = $this->services->dbh->query("UPDATE users SET name='$vals[name]', company='$vals[company]', email='$vals[email]', idcontainer=$vals[idcontainer], isadmin=$vals[isadmin], isactive=$vals[isactive] WHERE id=$args[id]");
      $result = array('error'=>false);
    //}
   if ($result['error']==true)
      $json = json_encode($result);
    else
      $json = $this->services->fetchJSON("SELECT * FROM users WHERE id=$args[id]",true);
  }
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->post('/bamenda/users', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else {
    $result = $this->services->register($vals['email'], $vals['password'], $vals['repeat-password'], 
      ['name'=>$vals['name'], 
       'company'=>$vals['company'],
       'isactive'=>$vals['isactive'],
       'iadmin'=>$vals['isadmin'],
       'idcontainer'=>$vals['idcontainer']
      ]);
    if ($result['error']==true)
      $json = json_encode($result);
    else
      $json = $this->services->fetchJSON("SELECT * FROM users WHERE email='$vals[email]'",true);
  }
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/session', function($request, $response, $args) {
  $user = $this->services->getSessionUser();
  
  $response->withHeader('Content-Type','application/json')->getBody()->write(json_encode($user,JSON_NUMERIC_CHECK));
});

$app->put('/bamenda/session', function($request, $response, $args) {
  $ret = $this->services->logout($this->services->getSessionHash());
  if ($ret)
    setcookie($this->services->cookie_name, '', time()-3600, $this->services->cookie_path, $this->services->cookie_domain, $this->services->cookie_secure, $this->services->cookie_http);
  $result=array();
  $result['error'] = !$ret;
  $response->getBody()->write(json_encode($result,JSON_NUMERIC_CHECK));
  return $response->withHeader('Content-Type','application/json');
});

$app->post('/bamenda/session', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  $result = $this->services->login($vals['email'], $vals['password'], $vals['remember']);
  if ($result['error']==true)
    $json = json_encode($result);
  else {
    setcookie($this->services->cookie_name, $result['hash'], $result['expire'], $this->services->cookie_path, $this->services->cookie_domain, $this->services->cookie_secure, $this->services->cookie_http);
    $json = $this->services->fetchJSON("SELECT S.hash, S.expiredate, U.id, U.isadmin, U.email, U.name, U.company FROM {$this->services->table_sessions} S INNER JOIN users U ON U.id=S.uid WHERE S.hash='$result[hash]'",true);
  }
  
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/photos', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM photos");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->delete('/bamenda/photos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    $fileroot = $this->services->fileroot;
    $photoroot = $this->services->photoroot;
    $this->services->dbh->query("DELETE P, CP FROM photos P INNER JOIN containerphotos CP ON CP.idphoto=P.id WHERE P.id IN (" . $parsedBody['ids'] . ")");
    $arr = explode(',', $parsedBody['ids']);
    foreach ($arr as $id) {
      $subdirectory = sprintf("%02d",$id%100);
      array_map('unlink', glob($fileroot . '/photos/' . $subdirectory .'/' . $id . '_*.jpg'));      
      array_map('unlink', glob($photoroot . '/' . $subdirectory .'/' . $id . '_*.jpg'));      
    }
  }
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/photos/{id:[0-9]*}', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) 
    $this->services->updateTable('photos', "id=$args[id]", $parsedBody, array('fileName', 'title', 'description', 'keywords'));
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/photos/{id:[0-9]*}', function($request, $response, $args) {
  if (!$this->services->isAdmin())
    $json = $this->services->unauthorizedJSON;
  else
    $json = $this->services->fetchJSON("SELECT * FROM photos WHERE id=$args[id]",true);
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/featuredphotos', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT P.id, P.fileName, P.title, P.description FROM photos P INNER JOIN containerphotos CP ON CP.idphoto=P.id INNER JOIN settings S ON S.featuredgallery=CP.idcontainer WHERE S.iduser=1 ORDER BY CP.position");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containerfrompath/[{path:.*}]', function($request, $response, $args) {
    $container = $this->services->getContainer($args['path']);
    if (!$container)
      $container = array('error'=>'gallery not found');
    $response->getBody()->write(json_encode($container,JSON_NUMERIC_CHECK));
    return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/pathfromcontainer/{id:[0-9]+}', function($request, $response, $args) {
    $path = $this->services->getContainerPath($args['id']);
    $response->getBody()->write(json_encode(array('path'=>$path)));
    return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT id, type, idparent, position, featuredphoto, name, description, url, urlsuffix, access, watermark, maxdownloadsize, downloadgallery, downloadfee, paymentreceived, buyprints, markup FROM containers ORDER BY idparent, position");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');    
});

$app->post('/bamenda/containers', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    $result = $this->services->dbh->query("SELECT MAX(position) FROM containers WHERE idparent=$vals[idparent]");
    $row = $result->fetch();
    $position = $row ? 1 + $row[0] : 1;
    $vals['urlsuffix'] = $this->services->getRandomKey(6);
    $this->services->dbh->query("INSERT INTO containers (type, idparent, position, name, description, url, urlsuffix, access, maxdownloadsize, downloadgallery, downloadfee, paymentreceived, buyprints, markup) VALUES ('$vals[type]', $vals[idparent], $position, '$vals[name]','$vals[description]', '$vals[url]', '$vals[urlsuffix]', $vals[access], $vals[maxdownloadsize], $vals[downloadgallery], $vals[downloadfee], $vals[paymentreceived], $vals[buyprints], $vals[markup])");
    $vals['id'] = $this->services->dbh->lastInsertId();
  }
  $response->getBody()->write(json_encode($vals));
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/containers', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    error_log("adjusting container ownership");
  }
  $response->getBody()->write(json_encode($vals));
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/containers/{id}', function($request, $response, $args) {
  $vals = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    $this->services->dbh->query("UPDATE containers SET idparent=$vals[idparent], position=$vals[position], name='$vals[name]', description='$vals[description]', url='$vals[url]', access=$vals[access], featuredphoto=$vals[featuredphoto], maxdownloadsize=$vals[maxdownloadsize], downloadgallery=$vals[downloadgallery], downloadfee=$vals[downloadfee], paymentreceived=$vals[paymentreceived], buyprints=$vals[buyprints], markup=$vals[markup] WHERE id=$args[id]");
  }
  $response->getBody()->write(json_encode($vals));
  return $response->withHeader('Content-Type','application/json');
});

$app->delete('/bamenda/containers/{id}', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    function doDelete($obj, $id) {
      //$master[] = $id;
      $obj->services->dbh->query("DELETE C.*, CP.* FROM containers C LEFT JOIN containerphotos CP ON CP.idcontainer=C.id WHERE C.id=$id");
      $result = $obj->services->dbh->query("SELECT id FROM containers where idparent=$id");
      $arr = array();
      while($row = $result->fetch())
        $arr[] = $row[0];
      foreach ($arr as $child)
        doDelete($obj, $child);
    }
    doDelete($this, $args['id']);
  }
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers/{id:[0-9]+}/products', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT P.id, P.api, P.idapi, P.type, P.description, P.hsize, P.vsize, P.hres, P.vres, P.price*(100+C.markup)/100 AS price FROM products P INNER JOIN containers C ON C.id=$args[id] WHERE P.active=1");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers/{idcontainer:[0-9]+}/photos/{idphoto:[0-9]+}/products', function($request, $response, $args) {
  $arr = array();
  $result = $this->services->dbh->query("SELECT P.id, P.api, P.idapi, P.type, P.description, P.hsize, P.vsize, P.hres, P.vres, PH.width, PH.height, P.price*(100+C.markup)/100 AS price FROM products P INNER JOIN containers C ON C.id=$args[idcontainer] INNER JOIN photos PH ON PH.id=$args[idphoto] WHERE P.active=1");
  
  while ($row = $result->fetchObject())
    if ($row->hres <= min($row->width,$row->height) && $row->vres <= max($row->width,$row->height))
      array_push($arr,$row);
  $json = json_encode($arr,JSON_NUMERIC_CHECK);
 
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers/{id:[0-9]+}/containers', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT * FROM containers WHERE idparent = $args[id] ORDER BY position");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers/{id:[0-9]+}/photos', function($request, $response, $args) {
  $json = $this->services->fetchJSON("SELECT P.id, P.title, P.description FROM photos P INNER JOIN containerphotos CP ON CP.idphoto=P.id WHERE CP.idcontainer=$args[id] ORDER BY CP.position");
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');
});

$app->get('/bamenda/containers/{id:[0-9]+}/containerphotos', function($request, $response, $args) {
  $result = $this->services->dbh->query("SELECT idphoto FROM containerphotos WHERE idcontainer=$args[id] ORDER BY position");
  $arr = array();
  while ($row = $result->fetch())
    array_push($arr, $row[0]);
  $response->getBody()->write(json_encode($arr,JSON_NUMERIC_CHECK));
  return $response->withHeader('Content-Type','application/json');
});

$app->post('/bamenda/containers/{id:[0-9]+}/containerphotos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  
  if ($this->services->isAdmin()) {
    $ids = explode(',', $parsedBody['ids']);
    $result = $this->services->dbh->query("SELECT MAX(position) FROM containerphotos WHERE idcontainer=$args[id]");
    $row = $result->fetch();
    $position = $row ? $row[0]+1 : 1;
    foreach($ids as $id) {
      $this->services->dbh->query("INSERT INTO containerphotos (idcontainer,idphoto,position) VALUES ($args[id],$id,$position)");
      $position++;
    }
  }
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/containers/{id:[0-9]+}/containerphotos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody();
  if ($this->services->isAdmin()) {
    $ids = explode(',', $parsedBody['ids']);
    $position = 1;
    foreach($ids as $id) {
      $this->services->dbh->query("UPDATE containerphotos SET position=$position WHERE idcontainer=$args[id] AND idphoto=$id");
      $position++;
    }
  }
  $response->getBody()->write(json_encode($parsedBody,JSON_NUMERIC_CHECK));
  return $response->withHeader('Content-Type','application/json');
});

$app->delete('/bamenda/containers/{id:[0-9]+}/containerphotos', function($request, $response, $args) {
  $parsedBody = $request->getParsedBody(); 
  if ($this->services->isAdmin()) {
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
  }
  $response->getBody()->write(json_encode($parsedBody));
  return $response->withHeader('Content-Type','application/json');
});

$app->post('/bamenda/containers/{id:[0-9]+}/archive', function($request, $response, $args) {
  $sizemap = array(1=>'S', 2=>'M', 3=>'L', 4=>'X');
  $ret = new stdClass();
  $ret->error = FALSE;
  // Check to see if user has permission to create an archive
  $result = $this->services->dbh->query("SELECT type, access, downloadgallery, maxdownloadsize FROM containers WHERE id=$args[id]");
  $obj = $result->fetchObject();
  if (!$obj || $obj->type!='gallery' || $obj->downloadgallery==0)
    $ret->error = TRUE;
  else if ($obj->access>1) {
    $user = $this->services->getSessionUser();
    if ($user->id==0)
      $ret->error = TRUE;
    else if (!$user->isadmin && !$this->services->userOwnsContainer($user->id,$args['id']))
     $ret->error = TRUE;
  }
  if ($ret->error==TRUE) {
    $ret->message = "Permission denied";
    $response->getBody()->write(json_encode($ret));
    return $response->withHeader('Content-Type','application/json');
  }
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);
  $galleryname = $parsedBody['name'];
  $imagesize = min($obj->maxdownloadsize , $parsedBody['imagesize']);
  $files = array();
  foreach ($ids as $id) {
    if ($imagesize==5) // full-resolution
      $arr = glob($this->services->fileroot . '/photos/' . sprintf("%02d",$id%100) . '/' . $id . '_*.jpg');
    else
      $arr = glob($this->services->photoroot . '/' . sprintf("%02d",$id%100) . '/' . $id . '_' . $sizemap[$imagesize] . '.jpg');
    if (count($arr)>0)
      $files[] = $arr[0];
  }
  try {
    $archive = $this->services->addFilesToArchive(NULL,$galleryname,$files);
    $ret->archive = $archive;
    $ret->count = count($ids);
    $ret->imagesize = $imagesize;
    $this->services->dbh->query("INSERT INTO archives (id, idcontainer, imagesize) VALUES ('$archive', $args[id], $imagesize)");
  }
  catch (Exception $e) {
    $ret->error = TRUE;
    $ret->message = $e->getMessage();
  }
  $response->getBody()->write(json_encode($ret));
  return $response->withHeader('Content-Type','application/json');
});

$app->put('/bamenda/containers/{id:[0-9]+}/archive/{archive}', function($request, $response, $args) {
  $sizemap = array(1=>'S', 2=>'M', 3=>'L', 4=>'X');  
  $ret = new stdClass();
  $ret->error = FALSE;
  $parsedBody = $request->getParsedBody();
  $ids = explode(',', $parsedBody['ids']);
  $galleryname = $parsedBody['name'];
  $imagesize = $parsedBody['imagesize'];
  $files = array();
  foreach ($ids as $id) {
    if ($imagesize==5) // full-resolution
      $arr = glob($this->services->fileroot . '/photos/' . sprintf("%02d",$id%100) . '/' . $id . '_*.jpg');
    else
      $arr = glob($this->services->photoroot . '/' . sprintf("%02d",$id%100) . '/' . $id . '_' . $sizemap[$imagesize] . '.jpg');
    if (count($arr)>0)
      $files[] = $arr[0];
  }
  try {
    $this->services->addFilesToArchive($args['archive'], $galleryname, $files);
    $ret->archive = $args['archive'];
    $ret->count = count($ids);
  }
  catch (Exception $e) {
    $ret->error = TRUE;
    $ret->message = $e->getMessage();
  }
  $response->getBody()->write(json_encode($ret));
  return $response->withHeader('Content-Type','application/json');
});

$app->any('/bamenda/cart[/{path:.*}]', function($request, $response, $args) {
  session_name('cart');
  session_start();
  $idcart = session_id();
  if (!$idcart) {
    $err = array('error'=>'cannot create shopping cart');
    $response->getBody()->write(json_encode($err));
    return $response->withHeader('Content-Type','application/json');
  }
  $this->services->dbh->query("INSERT IGNORE INTO carts (id) VALUES ('$idcart')");
  switch ($request->getMethod()) {
    case 'GET':
      $json = $this->services->fetchJSON("SELECT CI.id, CI.idcart, CI.idphoto, CI.idcontainer, CI.idproduct, PH.width, PH.height, CI.price, CI.quantity, CI.attrs, CI.cropx, CI.cropy, CI.cropwidth, CI.cropheight, P.api, P.idapi, P.type, P.description, P.hsize, P.vsize, P.hsizeprod, P.vsizeprod, P.hres, P.vres, p.shippingtype FROM cartitems CI INNER JOIN products P ON P.id=CI.idproduct INNER JOIN photos PH ON PH.id=CI.idphoto WHERE CI.idcart='$idcart'");
      break;
    case 'POST':
      $cropx = $cropy = 0;
      $cropwidth = $cropheight = 100; 
      $json = $request->getParsedBody();
      
      $vals = $this->services->initializeCartItem($json['idcontainer'], $json['idproduct'], $json['idphoto'], 0);
      $json['price'] = $vals->price;
      $json['cropx'] = $vals->cropx;
      $json['cropy'] = $vals->cropy;
      $json['cropwidth'] = $vals->cropwidth;
      $json['cropheight'] = $vals->cropheight;
      $json['attrs'] = $vals->attrs;
      $this->services->dbh->query("INSERT INTO cartitems (idcart, idphoto, idcontainer, idproduct, price, quantity, attrs, cropx, cropy, cropwidth, cropheight) VALUES ('$idcart', $json[idphoto], $json[idcontainer], $json[idproduct], $json[price], $json[quantity], '$json[attrs]', $json[cropx], $json[cropy], $json[cropwidth], $json[cropheight])");
      $json['id'] = $this->services->dbh->lastInsertId();
      $json = json_encode($json,JSON_NUMERIC_CHECK);
      break;
    case 'PUT':
      $json = $request->getParsedBody();
      $vals = $this->services->initializeCartItem($json['idcontainer'], $json['idproduct'], $json['idphoto'], $args['path']);
      if ($json['idproduct']!=$vals->idproduct) {
        $json['description'] = $vals->description;
        $json['price'] = $vals->price;
        $json['hsize'] = $vals->hsize;
        $json['vsize'] = $vals->vsize;
        $json['hres'] = $vals->hres;
        $json['vres'] = $vals->vres;
        $json['cropx'] = $vals->cropx;
        $json['cropy'] = $vals->cropy;
        $json['cropwidth'] = $vals->cropwidth;
        $json['cropheight'] = $vals->cropheight;
      }
      $this->services->dbh->query("UPDATE cartitems SET idproduct=$json[idproduct], price=$json[price], quantity=$json[quantity], attrs='$json[attrs]', cropx=$json[cropx], cropy=$json[cropy], cropwidth=$json[cropwidth], cropheight=$json[cropheight] WHERE id=$args[path]");
      $json = json_encode($json,JSON_NUMERIC_CHECK);
      break;
    case 'DELETE':
      $json = $request->getParsedBody();
      $this->services->dbh->query("DELETE FROM cartitems WHERE id=$args[path]");
      $json = json_encode($json,JSON_NUMERIC_CHECK);
      break;
    default:
      $json = array('error'=>'unrecognized request');
      break;
  }
  $response->getBody()->write($json);
  return $response->withHeader('Content-Type','application/json');    
});

$app->post('/bamenda/upload', function($request, $response, $args) {
    if (!$this->services->isAdmin())
      return;
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
    error_log(json_encode($arr));
    $response->getBody()->write(json_encode($arr));
    return $response->withHeader('Content-Type','application/json');
    //return $response->withHeader('Content-type', 'application/json');
});
// Run app
$app->run();
?>  
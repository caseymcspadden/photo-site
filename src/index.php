<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require './vendor/autoload.php';
require './classes/CrossRiver/Services.php';

// Get container
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

$container['notFoundHandler'] = function ($container) {
    return function ($request, $response) use ($container) {
        return $container['view']->render($response, '404.html', [])->withStatus(404);
    };
};

$container['services'] = function($container) {
    return new CrossRiver\Services('/Users/Casey/Projects/caseymcspadden/CaseyMcSpaddenSite/fileroot',
        '/Users/Casey/Projects/caseymcspadden/CaseyMcSpaddenSite/build/photos');
    //return new CrossRiver\Services('/Users/caseymcspadden/sites/photo-site/fileroot','/Users/caseymcspadden/sites/photo-site/build/photos');
    //return new CrossRiver\Services('/fileroot','/var/www/html/photos');
};

// Define app routes

$app->get('/', function (Request $request, Response $response, $args) {
   return $this->view->render($response, 'home.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
  ]);
})->setName('home');

$app->get('/authorize', function (Request $request, Response $response, $args) {
  $request2 = \OAuth2\Request::createFromGlobals();
  $response2 = new \OAuth2\Response();

  if (!$this->services->oauth2->validateAuthorizeRequest($request2, $response2)) {
    $response2->send();
    die;
  }
  
  return $this->view->render($response, 'authorize.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged(),
        'clientId'=>$request->getQueryParam('client_id'),
        'badCredentials'=>false
  ]);
})->setName('authorize');

$app->post('/authorize', function (Request $request, Response $response, $args) {
  $request2 = \OAuth2\Request::createFromGlobals();
  $response2 = new \OAuth2\Response();

  $authorized = ($request->getParam('authorized')=='Yes');

  if ($authorized && !$this->services->isLogged()) {
    $ret = $this->services->login($request->getParam('email'), $request->getParam('password'));
    if ($ret['error']===true) {
       return $this->view->render($response, 'authorize.html' , [
            'webroot'=>$this->services->webroot,
            'islogged'=>$this->services->isLogged(),
            'clientId'=>$request->getQueryParam('client_id'),
            'badCredentials'=>true
      ]);
    }
  }

  $this->services->oauth2->handleAuthorizeRequest($request2, $response2, $authorized);

  //$code = substr($response2->getHttpHeader('Location'), strpos($response2->getHttpHeader('Location'), 'code=')+5, 40);
  
  //return $response2->send();
  return $response->withRedirect($response2->getHttpHeader('Location'));
});

$app->get('/galleries/[{path:.*}]', function($request, $response, $args) {
    $container = $this->services->getContainer($args['path']);
    if (!$container)
      return $response->withRedirect($this->get('router')->pathFor('home'));

    if ($container->type=='folder') {
      return $this->view->render($response, 'folder.html' , [
          'webroot'=>$this->services->webroot,
          'container'=>$container,
          'islogged'=>$this->services->isLogged()
      ]);
    } else {
      return $this->view->render($response, 'gallery.html' , [
          'webroot'=>$this->services->webroot,
          'container'=>$container,
          'islogged'=>$this->services->isLogged()
      ]);
    }
});

$app->get('/realestate', function ($request, $response, $args) {
    return $this->view->render($response, 'realestate.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/about', function ($request, $response, $args) {
    return $this->view->render($response, 'about.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/contact', function ($request, $response, $args) {
    return $this->view->render($response, 'contact.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/profile', function ($request, $response, $args) {
    return $this->view->render($response, 'profile.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/cart', function ($request, $response, $args) {
    return $this->view->render($response, 'cart.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/orders/{orderid}', function ($request, $response, $args) {
    return $this->view->render($response, 'order.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/checkout', function ($request, $response, $args) {
    return $this->view->render($response, 'checkout.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/mamfe', function ($request, $response, $args) {
    if (!$this->services->isAdmin())
      return $response->withRedirect($this->get('router')->pathFor('home'));

    return $this->view->render($response, "admin.html" , [
        'webroot'=>$this->services->webroot,
        'adminroot'=>$this->services->adminroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get('/mamfe/{task}', function ($request, $response, $args) {
    if (!$this->services->isAdmin())
     return $response->withRedirect($this->get('router')->pathFor('home'));

    return $this->view->render($response, "admin-$args[task].html" , [
        'webroot'=>$this->services->webroot,
        'adminroot'=>$this->services->adminroot
    ]);
});

// Run app
$app->run();
?>
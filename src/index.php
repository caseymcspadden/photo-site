<?php
require './vendor/autoload.php';
require './classes/CrossRiver/Services.php';

// Get admin and services paths

/*
error_log("IN INDEX.PHP");
foreach ($_SERVER as $key => $value) {
  error_log("$key = $value");
}
error_log("\n\n");
*/

$contents = file('/Users/caseymcspadden/sites/photo-site/fileroot/paths.cfg');
$paths = array();

foreach ($contents as $line) {
  $kv = explode('=', $line);
  $paths[trim($kv[0])] = trim($kv[1]);
}

$paths = (object)$paths;

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
    return new CrossRiver\Services();
};

// Define app routes

$app->get('/', function ($request, $response, $args) {
    return $this->view->render($response, 'home.html' , [
        'webroot'=>$this->services->webroot,
        'islogged'=>$this->services->isLogged()
  ]);
})->setName('home');


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

$app->get('/about', function ($request, $response, $args) {
    return $this->view->render($response, 'about.html' , [
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

$app->get($paths->adminpath, function ($request, $response, $args) {
    if (!$this->services->isAdmin())
      return $response->withRedirect($this->get('router')->pathFor('home'));

    return $this->view->render($response, "admin.html" , [
        'webroot'=>$this->services->webroot,
        'adminroot'=>$this->services->adminroot,
        'islogged'=>$this->services->isLogged()
    ]);
});

$app->get($paths->adminpath . '/{task}', function ($request, $response, $args) {
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
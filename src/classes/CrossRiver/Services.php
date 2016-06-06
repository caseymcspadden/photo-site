<?php

namespace CrossRiver;

class Services
{
	private $auth;
	private $config;
	private $crid; // SESSION ID

	public $fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
	public $photoroot = '/Users/caseymcspadden/sites/photo-site/build/photos';
	public $adminroot = '/mamfe';
	public $webroot = '';
	public $dbh;
	public $error = false;
	public $unauthorizedJSON = '{"error": "unauthorized"}';

	public function __construct()
	{
		$contents = file($this->fileroot . '/app.cfg');
		$config = array();

		foreach ($contents as $line) {
			$kv = explode('=', $line);
			$config[trim($kv[0])] = trim($kv[1]);
		}

		$this->dbh = new \PDO("mysql:host=localhost;dbname=" . $config['mysqldb'],  $config['mysqluser'] , $config['mysqlpwd']);

		if(!$this->dbh) {
    		$this->error = true;
    		return;
    	}

		$this->config = new \PHPAuth\Config($this->dbh);
		$this->auth = new \PHPAuth\Auth($this->dbh, $this->config);
	}

	public function __get($setting)
    {
        return $this->config->__get($setting);
    }

	/***
	* Logs a user in
	* @param string $email
	* @param string $password
	* @param int $remember
    * @param string $captcha = NULL
	* @return array $return
	*/

	public function login($email, $password, $remember = 0, $captcha = NULL)
	{
		return $this->auth->login($email, $password, $remember, $captcha);
	}

	/***
	* Creates a new user, adds them to database
	* @param string $email
	* @param string $password
	* @param string $repeatpassword
    * @param array  $params
    * @param string $captcha = NULL
	* @param bool $sendmail = NULL
	* @return array $return
	*/

	public function register($email, $password, $repeatpassword, $params = Array(), $captcha = NULL, $sendmail = NULL)
	{
		return $this->auth->register($email, $password, $repeatpassword, $params, $captcha, $sendmail);
	}

	/***
	* Activates a user's account
	* @param string $key
	* @return array $return
	*/

	public function activate($key)
	{
		return $this->auth->activate($key);
	}

	/***
	* Creates a reset key for an email address and sends email
	* @param string $email
	* @return array $return
	*/

	public function requestReset($email, $sendmail = NULL)
	{
		return $this->auth->requestReset($email, $sendmail);
	}

	/***
	* Logs out the session, identified by hash
	* @param string $hash
	* @return boolean
	*/

	public function logout($hash)
	{
		return $this->auth->logout($hash);
	}

	/***
	* Hashes provided password with Bcrypt
	* @param string $password
	* @param string $password
	* @return string
	*/

	public function getHash($password)
	{
		return $this->auth->getHash($password);
	}

	/***
	* Gets UID for a given email address and returns an array
	* @param string $email
	* @return array $uid
	*/


	public function getUID($email)
	{
		return $this->auth->getUID($email);
	}

	/***
	* Function to check if a session is valid
	* @param string $hash
	* @return boolean
	*/

	public function checkSession($hash)
	{
		return $this->auth->checkSession($hash);
	}

	/***
	* Retrieves the UID associated with a given session hash
	* @param string $hash
	* @return int $uid
	*/

	public function getSessionUID($hash)
	{
		return $this->auth->getSessionUID($hash);
	}

	/***
	* Checks if an email is already in use
	* @param string $email
	* @return boolean
	*/

	public function isEmailTaken($email)
	{
		return $this->auth->isEmailTaken($email);
	}

	/***
	* Gets public user data for a given UID and returns an array, password is not returned
	* @param int $uid
	* @return array $data
	*/

	public function getUser($uid)
	{
		return $this->auth->getUser($uid);
	}	

	/***
	* Allows a user to delete their account
	* @param int $uid
	* @param string $password
    * @param string $captcha = NULL
	* @return array $return
	*/

	public function deleteUser($uid, $password, $captcha = NULL)
	{
		return $this->auth->deleteUser($uid, $password, $captcha = NULL);
	}


	/***
	* Returns request data if key is valid
	* @param string $key
	* @param string $type
	* @return array $return
	*/

	public function getRequest($key, $type)
	{
		return $this->auth->getRequest($key, $type);
	}

	/***
	* Allows a user to reset their password after requesting a reset key.
	* @param string $key
	* @param string $password
	* @param string $repeatpassword
    * @param string $captcha = NULL
	* @return array $return
	*/

	public function resetPass($key, $password, $repeatpassword, $captcha = NULL)
	{
		return $this->auth->resetPass($key, $password, $repeatpassword, $captcha);
	}

	/***
	* Recreates activation email for a given email and sends
	* @param string $email
	* @return array $return
	*/

	public function resendActivation($email, $sendmail = NULL)
	{
		return $this->auth->resendActivation($email, $sendmail);
	}

	/***
	* Changes a user's password
	* @param int $uid
	* @param string $currpass
	* @param string $newpass
    * @param string $repeatnewpass
    * @param string $captcha = NULL
	* @return array $return
	*/
    public function changePassword($uid, $currpass, $newpass, $repeatnewpass, $captcha = NULL)
	{
		return $this->auth->changePassword($uid, $currpass, $newpass, $repeatnewpass, $captcha);
	}

	/***
	* Changes a user's email
	* @param int $uid
	* @param string $email
	* @param string $password
    * @param string $captcha = NULL
	* @return array $return
	*/

	public function changeEmail($uid, $email, $password, $captcha = NULL)
	{
		return $this->auth->changeEmail($uid, $email, $password, $captcha);
	}

	/***
	* Informs if a user is locked out
	* @return string
	*/

	public function isBlocked()
	{
		return $this->auth->isBlocked();
	}

	/***
	* Returns a random string of a specified length
	* @param int $length
	* @return string $key
	*/
	public function getRandomKey($length = 20)
	{
		return $this->auth->getRandomKey($length);
	}
	
	/***
	* Returns is user logged in
	* @return boolean
	*/

	public function isLogged() 
	{
		return $this->auth->isLogged();
	}

    /***
     * Returns current session hash
     * @return string
     */
    public function getSessionHash()
    {
		return $this->auth->getSessionHash();
    }

    /***
     * Compare user's password with given password
     * @param int $userid
     * @param string $password_for_check
     * @return bool
     */
    public function comparePasswords($userid, $password_for_check)
    {
    	return $this->auth->comparePasswords($userid, $password_for_check);
    }

    /***
     * Retrieves data for logged-in user
     * @return JSON
     */
    public function getSessionUser()
    {
    	if (!$this->auth->isLogged())
    		return (object) ['id'=>0, 'isadmin'=>0];
    	$hash = $this->auth->getSessionHash();
    	$result = $this->dbh->query("SELECT S.hash, U.id, U.isadmin, U.email, U.name, U.company, U.idcontainer FROM {$this->table_sessions} S INNER JOIN users U ON U.id=S.uid WHERE S.hash='$hash'");
    	return $result->fetchObject();
    }

    /***
     * Retrieve true if user is logged in and is an administrator
     * @return JSON
     */
    public function isAdmin()
    {
    	if (!isset($_COOKIE['auth']))
    		return false;
    	$hash = $this->auth->getSessionHash();
    	if (!$hash || !$this->auth->checkSession($hash))
    		return false;
  		$uid = $this->auth->getSessionUID($hash);
    	$result = $this->dbh->query("SELECT isadmin FROM users WHERE id=$uid");
    	$obj = $result->fetchObject();
    	return $obj ? ($obj->isadmin==1) : false;
    }

    /***
     * Query the database and return an array (or object if fetch count is 1 and $returnSingletonAsObject is true)
     * @param bool $returnSingletonAsObject
     * @return JSON
     */
    public function fetchJSON($query, $returnSingletonAsObject = false)
    {
  		$arr = array();
    	$result = $this->dbh->query($query);

  		while ($row = $result->fetchObject())
    		array_push($arr,$row);

    	if ($returnSingletonAsObject && count($arr)==1)
    		return json_encode($arr[0],JSON_NUMERIC_CHECK);
    	return json_encode($arr,JSON_NUMERIC_CHECK);
    }

    public function updateTable($table, $where, $data, $allowedFields=NULL)
    {
	    $set = array();
    	foreach ($data as $k=>$v) {
      		if ($allowedFields==NULL || in_array($k,$allowedFields))
				array_push($set,"$k='$v'");
    	}
    	if (count($set)>0)
    		$this->dbh->query("UPDATE $table SET " . implode(',',$set) . " WHERE $where");

    }

    public function getContainerPath($idcontainer)
    {
    	$pathArray = array();

    	while (1) {
    		$result = $this->dbh->query("SELECT idparent, url FROM containers WHERE id=$idcontainer");
    		$container = $result->fetchObject();
    		if (!$container)
    			break;
    		$pathArray[] = $container->url;
    		if ($container->idparent==0)
    			break;
    		$idcontainer = $container->idparent;
    	}
    	return implode('/',array_reverse($pathArray));
    }

    public function userOwnsContainer($iduser, $idcontainer)
    {
   		$result = $this->dbh->query("SELECT isadmin, idcontainer FROM users WHERE id=$iduser");

   		$user = $result->fetchObject();

   		if (!$user || $user->idcontainer==0)
   			return FALSE;

   		while (TRUE) {
	   		if ($user->idcontainer==$idcontainer)
   				return TRUE;
   			$result = $this->dbh->query("SELECT idparent FROM containers WHERE id=$idcontainer");
   			$row = $result->fetch();
   			if (!$row || $row[0]==0)
   				return FALSE;
   			$idcontainer =$row[0];
   		}
   		return FALSE;
    }

   	public function addFilesToArchive($archive, $galleryname, $files)
    {
	    $zip = new \ZipArchive();

	   	$name = $archive==NULL ? $this->getRandomKey(20) : $archive;

	 	$filename = $this->fileroot . '/downloads/' . $name .'.zip';

	 	if ($archive==NULL) {
	 		$open = $zip->open($filename, \ZipArchive::CREATE);
	 		$zip->addEmptyDir($galleryname);
	 	}
	 	else
	 		$open = $zip->open($filename);

		if ($open!==TRUE) {
    		error_log("Cannot open $filename");
    		return FALSE;
		}
		else {
			$i = $zip->numFiles;
			foreach ($files as $file) {
				$zip->addFile($file, '/' . $galleryname .'/' . $galleryname . '-' . $i . '.jpg');
				$i++;
			}
			$zip->close();
		}

		return $name;
    }

    public function getContainer($path)
    {
    	$pathArray = explode('/',$path);
    	$user = $this->getSessionUser();
    	$onUserBranch = FALSE;

    	$currentContainer = (object) ['id'=>0, 'type'=>'folder', 'idparent'=>0, 'name'=>'', 'url'=>'', 'urlsuffix'=>'', 'access'=>0, 'featuredphoto'=>0, 'maxdownloadsize'=>0, 'downloadgallery'=>0, 'buyprints'=>0];
    	for ($i=0;$i<count($pathArray);$i++) {
    		$result = $this->dbh->query("SELECT id, type, idparent, name, url, urlsuffix, access, featuredphoto, maxdownloadsize, downloadgallery, buyprints FROM containers WHERE url='$pathArray[$i]' AND idparent=" . $currentContainer->id);
    		$currentContainer = $result->fetchObject();

    		if (!$currentContainer)
    			return FALSE;

    		//error_log("current container id =" . $currentContainer->id . " user container =" . $user->idcontainer . " on user branch = " . $onUserBranch);

    		if (!$onUserBranch && $user->id!=0 && $user->idcontainer!=0) 
    			$onUserBranch = $currentContainer->id == $user->idcontainer;
    		
    		$canAccess = $user->isadmin || $onUserBranch;

    		if ($i==count($pathArray)-1)
    			return ($canAccess || $currentContainer->access==0) ? $currentContainer : FALSE;

    		if ($i==count($pathArray)-2 && $pathArray[$i+1]==$currentContainer->urlsuffix)
				return ($canAccess || $currentContainer->access<=1) ? $currentContainer : FALSE;
    	}
    	return FALSE;
    }

    public function initializeCartItem($idcontainer, $idproduct, $idphoto, $idoriginal)
    {
		$ret = new \stdClass();
    	if ($idoriginal) {
    		$result = $this->dbh->query("SELECT CI.idproduct, CI.price, CI.cropx, CI.cropy, CI.cropwidth, CI.cropheight, P.hsize, P.vsize FROM cartitems CI INNER JOIN products P ON P.id=CI.idproduct WHERE CI.id=$idoriginal");
			$original = $result->fetchObject();
			$ret->idproduct = $original->idproduct;
		}
		else {
			$original = NULL;
			$ret->idproduct = $idproduct;
		}

		$ret->cropx = $ret->cropy = 0;
		$ret->cropwidth = $ret->cropheight = 100;
		$result = $this->dbh->query("SELECT P.price * (100 + C.markup)/100 AS price, P.hsize, P.vsize FROM products P INNER JOIN containers C ON C.id=$idcontainer WHERE P.id=$idproduct");
      	$product = $result->fetchObject();
		$ret->price = $product ? $product->price : 0;
	
	  	$attrs = array();
    	$result = $this->dbh->query("SELECT A.name, A.defaultvalue FROM productattributes PA INNER JOIN attributes A ON A.id=PA.idattribute WHERE PA.idproduct=$idproduct");
      	while ($pa=$result->fetchObject())
      		$attrs[$pa->name] = $pa->defaultvalue;
		$ret->attrs = json_encode($attrs,JSON_FORCE_OBJECT);      

		$prodaspect = $product->vsize / $product->hsize;

		if ($original==NULL || $original->vsize/$original->hsize != $prodaspect) {
			$result = $this->dbh->query("SELECT width, height FROM photos WHERE id=$idphoto");
			$photo = $result->fetchObject();
			if ($photo->width > $photo->height) { //landscape
				if ($photo->height * $prodaspect < $photo->width) {
				  $ret->cropwidth = 100 * ($photo->height * $prodaspect)/$photo->width;
				  $ret->cropx = (100 - $ret->cropwidth)/2;
				}
				else {
				  $ret->cropheight = 100 * ($photo->width / $prodaspect)/$photo->height;
				  $ret->cropy = (100 - $ret->cropheight)/2;
				}
			}
			else { //portrait
				if ($photo->width * $prodaspect < $photo->height) {
				  $ret->cropheight = 100 * ($photo->width * $prodaspect)/$photo->height;
				  $ret->cropy = (100 - $ret->cropheight)/2;
				}
				else {
				  $ret->cropwidth = 100 * ($photo->height / $prodaspect)/$photo->width;
				  $ret->cropx = (100 - $ret->cropwidth)/2;
				}
			}
		}
		else {
			$ret->cropx = $original->cropx;
			$ret->cropy = $original->cropy;
			$ret->cropwidth = $original->cropwidth;
			$ret->cropheight = $original->cropheight;
		}
		return $ret;
    }
}
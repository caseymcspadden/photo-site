<?php

namespace CrossRiver;


class Services
{
	private $auth;
	private $config = array();

	public $fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
	public $photoroot = '/Users/caseymcspadden/sites/photo-site/build/photos';
	public $webroot = '/photo-site/build';
	public $dbh;
	public $error = false;
	public $unauthorizedJSON = '{"error": "unauthorized"}';

	public function __construct()
	{
		$contents = file($this->fileroot . '/app.cfg');

		foreach ($contents as $line) {
			$kv = explode('=', $line);
			$this->config[trim($kv[0])] = trim($kv[1]);
		}

		$this->dbh = new \PDO("mysql:host=localhost;dbname=" . $this->config['mysqldb'],  $this->config['mysqluser'] , $this->config['mysqlpwd']);

		if(!$this->dbh) {
    		$this->error = true;
    		return;
    	}

		$cfg = new \PHPAuth\Config($this->dbh);
		$this->auth = new \PHPAuth\Auth($this->dbh, $cfg);
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
    	$hash = $this->auth->getSessionHash();
    	if (!$hash || !$this->auth->checkSession($hash))
    		return '{"id":0}';
  		$uid = $this->auth->getSessionUID($hash);
    	return $this->fetchJSON("SELECT S.hash, U.id, U.isadmin, U.email, U.name, U.company FROM sessions S INNER JOIN users U ON U.id=S.uid WHERE S.uid=$uid",true);
    }

    /***
     * Retrieve true if user is logged in and is an administrator
     * @return JSON
     */
    public function isAdmin()
    {
    	if (!isset($_COOKIE['session']))
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
}
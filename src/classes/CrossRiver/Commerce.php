<?php
namespace CrossRiver;

class Commerce {
	
	public $fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
	private $live = FALSE;

	public function __construct() 
	{	
		$contents = file($this->fileroot . '/app.cfg');
		$config = array();

		foreach ($contents as $line) {
			$kv = explode('=', $line);
			$config[trim($kv[0])] = trim($kv[1]);
		}

    	$this->config = (object)$config;
	}

	private function get_paypal_properties()
	{
		$clientId = ($this->live ? $this->config->clientId_live : $this->config->clientId_sandbox);
		$secret = ($this->live ? $this->config->secret_live : $this->config->secret_sandbox);

		$ret = new \stdClass();
		$ret->endpoint = ($this->live ? $this->config->endpoint_paypal_live : $this->config->endpoint_paypal_sandbox);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $ret->endpoint . "/oauth2/token"); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_HEADER, FALSE);
		curl_setopt($ch, CURLOPT_POST, TRUE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Accept: application/json', 'Accept-Language: en_US'));
		curl_setopt($ch, CURLOPT_USERPWD, $clientId . ':' . $secret);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
     
		$results = curl_exec($ch);
		curl_close($ch);   
		$arr = json_decode($results,TRUE);
		$ret->access_token = $arr['access_token'];
		
		return $ret;
	}

	private function initialize_paypal($call)
	{
		$clientId = ($this->live ? $this->config->clientId_live : $this->config->clientId_sandbox);
		$secret = ($this->live ? $this->config->secret_live : $this->config->secret_sandbox);

		$ret = new \stdClass();
		$endpoint = ($this->live ? $this->config->endpoint_paypal_live : $this->config->endpoint_paypal_sandbox);

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $endpoint . "/oauth2/token"); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_HEADER, FALSE);
		curl_setopt($ch, CURLOPT_POST, TRUE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Accept: application/json', 'Accept-Language: en_US'));
		curl_setopt($ch, CURLOPT_USERPWD, $clientId . ':' . $secret);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
     
		$results = curl_exec($ch);
		curl_close($ch);   
		$access = json_decode($results,TRUE);
	
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $endpoint . $call);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_HEADER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Authorization:Bearer " . $access['access_token']));

		return $ch;
	}

	private function get_pwinty_properties()
	{
		$ret = new \stdClass();
		$ret->endpoint = ($this->live ? $this->config->endpoint_pwinty_live : $this->config->endpoint_pwinty_sandbox);		
		$ret->merchantId = $this->config->pwinty_merchantId;
		$ret->apiKey = $this->config->pwinty_apiKey;

		return $ret;
	}

	public function getPayments($id=NULL)
	{
		$ch = $this->initialize_paypal('/payments/payment' . ($id ? "/$id" : ""));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return $results;			
	}

	public function makePayment($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1=NULL, $address2=NULL, $city=NULL, $state=NULL, $zip=NULL)
	{
		$payload = $this->create_paypal_payload($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip);
					
		$ch = $this->initialize_paypal('/payments/payment');
		curl_setopt($ch, CURLOPT_POST, TRUE);
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
			
		$results = curl_exec($ch);
		curl_close($ch);
  
		return $results;
	}

	public function makePayment2($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip)
	{
		$paypal = $this->get_paypal_properties();

		$payload = $this->create_paypal_payload($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip);
					
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $paypal->endpoint . "/payments/payment"); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_HEADER, FALSE);
		curl_setopt($ch, CURLOPT_POST, TRUE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Authorization:Bearer " . $paypal->access_token));
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
			
		$results = curl_exec($ch);
		curl_close($ch);
  
		return $results;
	}

	private function initialize_pwinty($call)
	{
		$pwinty = $this->get_pwinty_properties();

		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $pwinty->endpoint . $call);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Accept: application/json", "X-Pwinty-MerchantId: " . $pwinty->merchantId, "X-Pwinty-REST-API-Key: " . $pwinty->apiKey));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      

		return $ch;
	}

	public function createOrder($name, $address1, $address2, $city, $state, $zip, $tracked)
	{	
		$data = array(
			'countryCode'=>'US',
			'destinationCountryCode'=>'US',
			'qualityLevel'=>'Pro',
			'recipientName'=>$name,
			'address1'=>$address1,
			'address2'=>$address2,
			'addressTownOrCity'=>$city,
			'stateOrCounty'=>$state,			
			'postalOrZipCode'=>$zip,
			'useTrackedShipping'=>($tracked ? true : false),
			'payment'=>'InvoiceMe'
		);

		error_log(json_encode($data));

		$ch = $this->initialize_pwinty('/Orders');
		curl_setopt($ch, CURLOPT_POST, TRUE);		
		curl_setopt($ch, CURLOPT_POSTFIELDS,  json_encode($data));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return json_decode($results);		
	}

	public function getOrders($id)
	{
		$ch = $this->initialize_pwinty('/Orders' . ($id ? "/$id" : ''));		
 		
		$results = curl_exec($ch);
		curl_close($ch);
	 	return $results;				
	}

	public function isOrderValid($id)
	{
		$ch = $this->initialize_pwinty('/Orders/' . $id . '/SubmissionStatus');		
 		
		$results = curl_exec($ch);
		curl_close($ch);

		$json = json_decode($results);
	 	return $json->isValid;				
	}

	public function submitOrder($id)
	{
		$ch = $this->initialize_pwinty('/Orders/' . $id . '/Status');		
 		
		curl_setopt($ch, CURLOPT_POST, TRUE);		
		curl_setopt($ch, CURLOPT_POSTFIELDS,  '{"status":"Submitted"}');

		$results = curl_exec($ch);

		curl_close($ch);

		return $results;
	}

	public function addItemToOrder($id, $guid, $remoteUrlBase, $item)
	{
		$data = new \stdClass;
		$data->type=$item->idapi;
			//'url'=>$remoteUrlBase . '/orders/' . $guid . '/photos/' . $item->idphoto . '.jpg',
		$data->url=$remoteUrlBase . '/orders/' . $guid . '/photos/test.jpg';
		$data->copies=$item->quantity;
		$data->sizing='Crop';
		$data->attributes=json_decode($item->attrs);

		error_log(json_encode($data));
 		
		$ch = $this->initialize_pwinty('/Orders/' . $id . '/Photos');		

		curl_setopt($ch, CURLOPT_POST, TRUE);		
		curl_setopt($ch, CURLOPT_POSTFIELDS,  json_encode($data));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return json_decode($results);				
	}

	public function getProductCatalog($country, $quality)
	{		
		$ch = $this->initialize_pwinty('/Catalogue/$country/$quality');	
		$results = curl_exec($ch);
		curl_close($ch);
	 	return $results;		
	}

	private function get_card_type($number)
	{
		if (strlen($number)<2)
			return '';
			
		if ($number[0]=='4')
			return 'visa';

		$sub2 = substr($number,0,2);
					
		if ($sub2=='51' || $sub2=='52' || $sub2=='53' || $sub2=='54' || $sub2=='55')
			return 'mastercard';
			
		if ($sub2=='34' || $sub2=='37')
			return 'amex';
			
		if ($sub2=='60' || $sub42='64' || $sub2=='65')
			return 'discover';

		return '';
	}		
		
	private function create_paypal_payload($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip)
	{
		// ADDRESS

		$address = new \stdClass();	
		if ($address1) $address->line1 = $address1;
		if ($address2) $address->line2 = $address2;
		if ($city) $address->city = $city;
		if ($state) $address->state = $state;
		if ($zip) $address->postal_code = $zip;
		$address->country_code = 'US';

		// CARD

		$card = new \stdClass();	
		$name = explode(' ', $card_name);
		$expires = explode('/', $card_expires);
		$card->first_name = $name[0];
		$card->last_name  = array_pop($name);
		$card->type = $card_type;
		$card->number = $card_number;
		$card->expire_month = $expires[0];
		$card->expire_year = $expires[1];
		$card->cvv2 = $cvv2;
		if ($address1) $card->billing_address = $address;

		// TRANSACTIONS

		$transactions = array();		

		$transaction = new \stdClass();	
		$transaction->description = $description;
		$transaction->amount = new \stdClass();
		$transaction->amount->total = sprintf('%0.2f', $amount);
		$transaction->amount->currency = 'USD';
		$transactions[] = $transaction;
	
		// PAYER

		$payer = new \stdClass();	
		$payer->payment_method = 'credit_card';
		$funding_instrument = new \stdClass();
		$funding_instrument->credit_card = $card;
		$payer->funding_instruments = array($funding_instrument);
			
		// PAYLOAD

		$payload = new \stdClass();	
		$payload->intent = 'sale';
		$payload->payer = $payer;
		$payload->transactions = $transactions;

		return $payload;
	}
};
?>
<?php
namespace CrossRiver;

class Commerce {
	
	public $fileroot = '/Users/caseymcspadden/sites/photo-site/fileroot';
	private $paypal_live = false;

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
		$clientId = ($this->paypal_live ? $this->config->clientId_live : $this->config->clientId_sandbox);
		$secret = ($this->paypal_live ? $this->config->secret_live : $this->config->secret_sandbox);

		$ret = new \stdClass();
		$ret->endpoint = ($this->paypal_live ? $this->config->endpoint_live : $this->config->endpoint_sandbox);

		error_log("Client id = $clientId");
		error_log("secret = $secret");

		$ch = curl_init(); 

		curl_setopt($ch, CURLOPT_URL, $ret->endpoint . "/v1/oauth2/token"); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HEADER, false);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);       
		curl_setopt($ch, CURLOPT_HTTPHEADER, array('Accept: application/json', 'Accept-Language: en_US'));
		curl_setopt($ch, CURLOPT_USERPWD, $clientId . ':' . $secret);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "grant_type=client_credentials");
     
		$results = curl_exec($ch);
		curl_close($ch);   
		error_log($results);
		$arr = json_decode($results,TRUE);
		$ret->access_token = $arr['access_token'];
		
		return $ret;
	}

	private function get_payments($id=NULL)
	{
		$paypal = $this->get_paypal_properties();
		
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $paypal->endpoint ."/v1/payments/payment" . ($id!==NULL ? "/$id" : "")); 
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Authorization:Bearer " . $paypal->access_token));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return $results;			
	}

	public function makePayment($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip)
	{
		$paypal = $this->get_paypal_properties();
		$payload = $this->create_paypal_payload($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip);

		error_log("endpoint = " . $paypal->endpoint);
		error_log("access token = " . $paypal->access_token);
					
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $paypal->endpoint . "/v1/payments/payment"); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HEADER, false);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);       
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Authorization:Bearer " . $paypal->access_token));
		curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
			
		$results = curl_exec($ch);
		curl_close($ch);   
  
		return json_decode($results,TRUE);
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

		$address = array();
		$address['line1'] = $address1;
		if ($address2)
			$address['line2'] = $address2;
		$address['city'] = $city;
		$address['state'] = $state;
		$address['postal_code'] = $zip;
		$address['country_code'] = 'US';

		// CARD

		$card = array();
		$name = explode(' ', $card_name);
		$expires = explode('/', $card_expires);
		$card['first_name'] = $name[0];
		$card['last_name']  = array_pop($name);
		$card['type'] = $card_type;
		$card['card_number'] = $card_number;
		$card['expire_month'] = $expires[0];
		$card['expire_year'] = $expires[1];
		$card['cvv2'] = $cvv2;
		$card['billing_address'] = $address;

		// TRANSACTIONS
		
		$transaction = array();
		$transaction['description'] = $description;
		$transaction['amount'] = array();
		$transaction['amount']['total'] = sprintf('%0.2f',$amount);
		$transaction['amount']['currency'] = 'USD';

		// PAYER

		$payer = array();
		$payer['payment_method'] = 'credit_card';
		$payer['funding_instruments'][] = array('credit_card'=>$card);
			
		// PAYLOAD

		$payload = array();		
		$payload['intent'] = 'sale';
		$payload['payer'] = $payer;
		$payload['transactions'] = array($transaction);

		return json_encode($payload);
	}
};
?>
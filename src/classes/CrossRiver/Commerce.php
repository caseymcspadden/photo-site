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
		$ret->endpoint = ($this->live ? $this->config->endpoint_live : $this->config->endpoint_sandbox);

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
		$paypal = $this->get_paypal_properties();
		
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $paypal->endpoint ."/payments/payment" . ($id ? "/$id" : ""));
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);		      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "Authorization:Bearer " . $paypal->access_token));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return $results;			
	}

	public function makePayment($amount, $description, $card_name, $card_type, $card_number, $card_expires, $cvv2, $address1, $address2, $city, $state, $zip)
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

	public function getProductCatalog()
	{
		$pwinty = $this->get_pwinty_properties();
		
		$ch = curl_init(); 
		curl_setopt($ch, CURLOPT_URL, $pwinty->endpoint ."/Catalogue/US/Pro");
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Accept: application/json", "X-Pwinty-MerchantId: " . $pwinty->merchantId, "X-Pwinty-REST-API-Key: " . $pwinty->apiKey));
		$results = curl_exec($ch);
		curl_close($ch);
	 	return substr($results,1);		
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
		$address->line1 = $address1;
		if ($address2)
			$address->line2 = $address2;
		$address->city = $city;
		$address->state = $state;
		$address->postal_code = $zip;
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
		$card->billing_address = $address;

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
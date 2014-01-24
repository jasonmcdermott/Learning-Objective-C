<?php
require_once 'decodeBrightheartsXml.php';
// define constants that we will be expecting from Page
define('UUID', 'uuid');
define ('XML_DATA', 'datalog');
define ('DEBUG', 'debug');
define ('SUCCESS_OUTPUT', 'Success');
// Note that we must only display the text "Success" at the end to return to iPad that we have a succes so it can delete the file on its storage
function sendfile($to, $from, $cc_list, $subject, $body_message, $input, $filename_sent_as = "") 
{
	if ($filename_sent_as == "")
	{
		$filename_sent_as = basename($input);
	}
	/* PREPARE MAIL HEADERS */
	$headers = "From: $from";
  if ($cc_list)
  {
    for ($i = 0; $i < count ($cc_list); $i++)
    {
      $cc = $cc_list[$i];
      if ($i == 0)
      {
        $headers .= "\r\nCc: $cc";
      }
      else
      {
        $headers .= ", $cc";
      }
    }
  }
	$semi_rand = md5(time());
	$mime_boundary = "==Multipart_Boundary_x{$semi_rand}x";
	$headers .= "\nMIME-Version: 1.0\n" .
	            "Content-Type: multipart/mixed;\n" .
	            " boundary=\"{$mime_boundary}\"";
	$email_message = "This is a multi-part message in MIME format.\n\n" .
	                "--{$mime_boundary}\n" .
	               "Content-Type:text/plain; charset=\"iso-8859-1\"\n" .
	               "Content-Transfer-Encoding: 7bit\n\n" .
		$body_message . "\n\n";
	/* PREPARE ATTACHMENT */
	$fileatt = $filename_sent_as ;
	$fileatt_type = "application/octet-stream";
	$file = fopen($input, "rb");
	$data = fread($file, filesize($input));
	fclose($file);
	$data = chunk_split(base64_encode($data));
	$email_message .= "--{$mime_boundary}\n" .
		"Content-Type: {$fileatt};\n" .
		" name=\"{$fileatt}\"\n" .
		"Content-Transfer-Encoding: base64\n\n" .
		$data . "\n\n" .
		"--{$mime_boundary}--\n";
	/* SEND FILE */
	$ok = @mail($to, $subject, $email_message, $headers);
	if($ok) {		
		//logsend();
	} else {
		echo('<p class="error"><b>ERROR</b> : could not send email.</p>');
	}
}
 $hide_output = !isset($_REQUEST[DEBUG]);
 if ($hide_output)
 {
   // we will stop all output - otherwise the iPad app will not know we have a success
   ob_start();
 }
 //$to = 'angelo@smartcontroller.com.au';
 $to = 'research@sensoriumhealth.com';
 echo "<h2>Debug Info </h2>";
 $file_uuid = trim(stripslashes($_POST[UUID]));
 echo "File UUID $file_uuid <br />";
 //$location  = $_POST['location'];
 //$datetime = $_POST['datetime'];
 $filename = str_replace(' ', '_', $file_uuid . "_". time() . ".xml");
 if (isset($_POST[XML_DATA]))
 {
  $datalog = trim(stripslashes($_POST[XML_DATA]));
  //error_log("Name = '" . $name . "', location = '" . $location . "'.");
  //EMAIL TO SOMEWHERE 
  $msg = $datalog;
  //mail('jason@sensoriumhealth.com','Bright Hearts', $msg);
  $subject = "Brighthearts XML Data";
  $from = "noreply@sensoriumhealth.com";
  $cc_list = array();
  file_put_contents($filename, $datalog);
  // Now load the xml data and parse
  $xml = simplexml_load_file($filename);
  $username = "";
  $device_id = "";
  $timezone = "";
  if ($xml)
  {
   $decoded_data = decodeXMLElements($xml);
   $username = $decoded_data[USERNAME];
   $device_id = $decoded_data[DEV_ID];
   $timezone = $decoded_data[TIMEZONE];
   $start_time = $decoded_data[SESSION_START][TIME];
   $start_date = $decoded_data[SESSION_START][DATE];
   $end_time = $decoded_data[SESSION_END][TIME];
   $end_date = $decoded_data[SESSION_END][DATE];
   echo "Username: $username <br />
   Device Id: $device_id <br />
   Session Start: $start_date $start_time <br />
   Session End: $end_date $end_time <br />
   Timezone: $timezone <br />";
   $time_text = str_replace(array(".", ":"), '_', $start_time);
   $file_send_as_name = $username . "_" . $start_date . "_". $time_text;
   sendfile($to, $from, $cc_list, $subject, $datalog, $filename, $file_send_as_name . ".xml");
   // Now iterate through Beats and make a text list
   $ibi_text = "";
   // we won't see this text unless we are debugging
   echo "<h2>IBI Times</h2>";
   for ($i = 0; $i < count($decoded_data[IBI][BEAT]); $i++)
   {
     // this is what we will be sending to the file
     $ibi_text .= "\n" . $decoded_data[IBI][BEAT][$i][VALUE];
     // we will just display this data
     echo "<br />" . "Count: " . $decoded_data[IBI][BEAT][$i][COUNT] .
     " Timestamp: " . $decoded_data[IBI][BEAT][$i][TIMESTAMP] .
     " IBI Value: " . $decoded_data[IBI][BEAT][$i][VALUE];
   }
   $text_file = $filename . ".txt";
   file_put_contents($text_file, $ibi_text);
   $subject .= " IBI Data";
   sendfile($to, $from, $cc_list, $subject, $ibi_text, $text_file, $file_send_as_name . ".ibi");
   // display reliability
   echo "<h2>Reliability</h2>";
   for ($i = 0; $i < count($decoded_data[STATUS][RELIABILITY]); $i++)
   {
     echo "<br />Timestamp: " . $decoded_data[STATUS][RELIABILITY][$i][TIMESTAMP] . " Value: " . $decoded_data[STATUS][RELIABILITY][$i][VALUE];
   }   
   echo "<h2>XML Data</h2>";
   echo "<pre>";
   print_r($xml);
   echo "</pre>";
   unlink($text_file);
  }
  unlink ($filename);
  echo "<h2>End Debug Info </h2>";
  if ($hide_output)
  {
    ob_clean();
  }
  echo SUCCESS_OUTPUT;
 }
 else 
 {
   if ($hide_output)
   {
     ob_clean();
   }
   echo "No Input Data"; 
 }
?>
ÿðKw0002
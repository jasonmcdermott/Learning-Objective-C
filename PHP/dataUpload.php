<?php
if(isset($_POST['first_name'])) {

    // EDIT THE 2 LINES BELOW AS REQUIRED
    $email_to = "research+hpv@sensoriumhealth.com";
    $email_subject = "HPV Research Data";


    function died($error) {
        // your error code can go here
        echo "We are very sorry, but there were error(s) found with the form you submitted. ";
        echo "These errors appear below.<br /><br />";
        echo $error."<br /><br />";
        echo "Please go back and fix these errors.<br /><br />";
        die();
    }

    // validation expected data exists
    if(!isset($_POST['school']) ||
        !isset($_POST['questionnaireID']) ||
        !isset($_POST['appID'])) {
        died('We are sorry, but there appears to be a problem with the form you submitted.');       
    }

    $appID = $_POST['appID'];
    $questionnaireID = $_POST['questionnaireID'];
    $school = $_POST['school'];
    $vaccineTaken = $_POST['vaccineTaken'];
    $didTakeVaccine = $_POST['didTakeVaccine'];
    $didTakeOtherVaccine = $_POST['didTakeOtherVaccine'];
    $gender = $_POST['gender'];
    $birthDate = $_POST['birthDate'];
    $submittedDateTime = $_POST['submittedDateTime'];

    $error_message = "";
    $string_exp = "/^[A-Za-z .'-]+$/";
  if(!preg_match($string_exp,$school)) {
    $error_message .= 'The Name you entered does not appear to be valid.<br />';
  }

    $email_message = "Form details below.\n\n";

    function clean_string($string) {
      $bad = array("content-type","bcc:","to:","cc:","href");
      return str_replace($bad,"",$string);
    }

    $email_message .= "appID: ".clean_string($appID)."\n";
    $email_message .= "questionnaireID: ".clean_string($questionnaireID)."\n";
    $email_message .= "school: ".clean_string($school)."\n";

// create email headers
$headers = 'From: '.$email_from."\r\n".
'Reply-To: '.$email_from."\r\n" .
'X-Mailer: PHP/' . phpversion();
echo (int) mail($email_to, $email_subject, $email_message, $headers);  

?>

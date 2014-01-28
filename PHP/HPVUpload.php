<?php 

	// header('Content-type: text/html');
	// define('AID', 'appID');
	// define ('DATA', 'datalog');
	// define ('SUCCESS_OUTPUT', 'Success');
	// define ('HPV_IPAD', 'iPad');
	// if ($_POST["appID"]<>'') { 
	//    $ToEmail = 'research@sensoriumhealth.com'; 
	//    $EmailSubject = 'HPV Research Data'; 
	//    $mailheader = "From: ".$ToEmail."\r\n"; 
	//    $mailheader .= "Reply-To: ".$ToEmail."\r\n"; 
	//    $mailheader .= "Content-type: text/html; charset=iso-8859-1\r\n"; 
    $MESSAGE_BODY = "AppID: ".$_POST["appID"]."\r\n";
	$MESSAGE_BODY .= "questionnaireID: ".$_POST["questionnaireID"]."\r\n";
	$MESSAGE_BODY .= "school: ".$_POST["school"]."\r\n";
	$MESSAGE_BODY .= "gender: ".$_POST["gender"]."\r\n";
	$MESSAGE_BODY .= "birthDate: ".$_POST["birthDate"]."\r\n";
	$MESSAGE_BODY .= "didTakeVaccine: ".$_POST["didTakeVaccine"]."\r\n";
	$MESSAGE_BODY .= "didTakeOtherVaccine: ".$_POST["didTakeOtherVaccine"]."\r\n";
	$MESSAGE_BODY .= "vaccineTaken: ".$_POST["vaccineTaken"]."\r\n";
	$MESSAGE_BODY .= "questionnaire submitted: ".$_POST["submittedDateTime"]."\r\n";
	
    mail('research+hpv@sensoriumhealth.com', 'HPV research Data', $MESSAGE_BODY) or die ("Failure"); 


	$con=mysqli_connect("localhost","sensoriu_root","rootpass","sensoriu_HPV");
	// Check connection
	if (mysqli_connect_errno())
	  {
	  echo "Failed to connect to MySQL: " . mysqli_connect_error();
	  }

	$sql="INSERT INTO pageA (appID, questionnaireID, school, gender, birthDate, didTakeVaccine, didTakeOtherVaccine, vaccineTaken, submittedDateTime)
	VALUES
	('$_POST[appID]','$_POST[questionnaireID]','$_POST[school]','$_POST[gender]','$_POST[birthDate]','$_POST[didTakeVaccine]','$_POST[didTakeOtherVaccine]','$_POST[vaccineTaken]','$_POST[submittedDateTime]')";


	if (!mysqli_query($con,$sql))
	  {
	  die('Error: ' . mysqli_error($con));
	  }
	echo "1 record added";

	mysqli_close($con);

?>
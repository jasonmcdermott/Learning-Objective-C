<?php
$con=mysqli_connect("localhost","sensoriu_root","rootpass","sensoriu_HPV");
// Check connection
if (mysqli_connect_errno())
  {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

$sql="INSERT INTO pageA (appID, questionnaireID, school, gender, birthDate, didTakeVaccine, didTakeOtherVaccine, vaccineTaken, submittedDateTime)
VALUES
('$_POST[appID]','$_POST[questionnaireID]','$_POST[school]','$_POST[gender]','$_POST[birthDate]','$_POST[didTakeVaccine]','$_POST[didTakeOtherVaccine]','$_POST[submittedDateTime]')";


if (!mysqli_query($con,$sql))
  {
  die('Error: ' . mysqli_error($con));
  }
echo "1 record added";

mysqli_close($con);
?>
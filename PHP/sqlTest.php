<?php
$con=mysqli_connect("localhost","sensoriu_root","rootpass","pageA");
// Check connection
if (mysqli_connect_errno())
  {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

$sql="INSERT INTO pageA (appID, questionnaireID, school, gender, birthDate, didTakeVaccine, didTakeOtherVaccine, vaccineTaken, submittedDateTime)
VALUES
('2334','abcdefg','Somewhere','Male','June 22','YES','NO','Today')";

if (!mysqli_query($con,$sql))
  {
  die('Error: ' . mysqli_error($con));
  }
echo "1 record added";

mysqli_close($con);
?>
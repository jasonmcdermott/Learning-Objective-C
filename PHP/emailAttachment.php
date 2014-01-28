<?php
    // Email address to which you want to send email
    $to = "research@sensoriumhealth.com";

    $subject = $_POST["fieldSubject"];
    $message = nl2br($_POST["fieldDescription"]);

    /*********Creating Uniqid Session*******/

    $txtSid = md5(uniqid(time()));

    $headers = "";
    $headers .= "From: ".$_POST["fieldFormName"]."<".$_POST["fieldFormEmail"].">\nReply-To: ".$_POST["fieldFormEmail"]."";

    $headers .= "MIME-Version: 1.0\n";
    $headers .= "Content-Type: multipart/mixed; boundary=\"".$txtSid."\"\n\n";
    $headers .= "This is a multi-part message in MIME format.\n";

    $headers .= "--".$txtSid."\n";
    $headers .= "Content-type: text/html; charset=utf-8\n";
    $headers .= "Content-Transfer-Encoding: 7bit\n\n";
    $headers .= $message."\n\n";

    /***********Email Attachment************/
    if($_FILES["attachment"]["name"] != "")
    {
        $txtFilesName = $_FILES["attachment"]["name"];
        $txtContent = chunk_split(base64_encode(file_get_contents($_FILES["attachment"]["tmp_name"]))); 
        $headers .= "--".$txtSid."\n";
        $headers .= "Content-Type: application/octet-stream; name=\"".$txtFilesName."\"\n"; 
        $headers .= "Content-Transfer-Encoding: base64\n";
        $headers .= "Content-Disposition: attachment; filename=\"".$txtFilesName."\"\n\n";
        $headers .= $txtContent."\n\n";
    }

    // @ is for skiping Errors //
    $flgSend = @mail($to,$subject,null,$headers);  

    if($flgSend)
    {
        echo "Email Sent SuccessFully.";
    }
    else
    {
        echo "Error in Sending Email.";
    }
?>
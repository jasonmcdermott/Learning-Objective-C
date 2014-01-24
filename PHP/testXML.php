<?php
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
require_once 'decodeBrightheartsXml.php';
$filename = 'sampleSession.xml';
$xml = simplexml_load_file($filename);
//var_dump($xml);
$data = decodeXMLElements($xml);
var_dump($data);
?>
·s
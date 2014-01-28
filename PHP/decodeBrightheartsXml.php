<?php
// Define our XML elements
define ('DEV_ID', 'dev_id');
define ('USERNAME', 'username');
define ('TIMEZONE', 'timezone');
define('SESSION_START', 'session_start');
define ('SESSION_END', 'session_end');
define ('DATE', 'date');
define('TIME', 'time');
define ('IBI', 'ibi');
define ('BEAT', 'beat');
define ('STATUS', 'status');
define ('RELIABILITY', 'sensor_reliability');
define ('VALUE', 'value');
define('TIMESTAMP', 'timestamp');
define ('COUNT', 'count');
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function decodeXMLChilden($xml)
{
  $ret = array();
   foreach ($xml->children() as $child)
   {
     $child_val = "";
     if ($child->children()->count() == 0)
     {
       $child_val = $child;
       settype($child_val, 'string');
       $ret[$child->getName()] = $child_val;       
     }
     else
     {
       if (strcasecmp(BEAT, $child->getName()) == 0)
       {
         $beat_data = decodeXMLChilden($child);
         $ret[BEAT][] = $beat_data;
       }
       elseif (strcasecmp(RELIABILITY, $child->getName()) == 0)
       {
         $beat_data = decodeXMLChilden($child);
         $ret[RELIABILITY][] = $beat_data;
       }
       else
       {
          $ret[$child->getName()]=  decodeXMLChilden($child);
       }
     }
   }
  return $ret;;
}
function decodeXMLElements($xml)
{
  $ret = array();
   foreach ($xml->children() as $child)
   {
     $child_val = "";
     if ($child->children()->count() == 0)
     {
       $child_val = $child;
       settype($child_val, 'string');
       $ret[$child->getName()] = $child_val;       
     }
     else
     {
       $ret[$child->getName()]=  decodeXMLChilden($child);
     }
   }
  return $ret;
}
?>
·s
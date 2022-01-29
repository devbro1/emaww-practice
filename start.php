<?php

require 'vendor/autoload.php';

use Masterminds\HTML5;

$file_name = 'config.xml';
$xml = new SimpleXMLElement(file_get_contents($file_name));

$subdomains = [];
foreach($xml->subdomains->subdomain as $elem)
{
    $subdomains[] = (string)$elem;
}

$cookies = [];
foreach($xml->cookies->cookie as $elem)
{
    $cookies['cookie:' . $elem['name'] . ':' . $elem['host']] = (string)$elem;
}

var_dump($cookies);
//var_dump($subdomains);
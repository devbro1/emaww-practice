<?php

require 'vendor/autoload.php';

$redis = new Redis(); 
$redis->connect('redis', 6379); 
echo "Redis server is running: ".$redis->ping();

$file_name = 'config.xml';
$xml = new SimpleXMLElement(file_get_contents($file_name));

$subdomains = [];
foreach($xml->subdomains->subdomain as $elem)
{
    $subdomains[] = (string)$elem;
}

$redis->set("subdomains", json_encode($subdomains)); 

$cookies = [];
foreach($xml->cookies->cookie as $elem)
{
    $cookies['cookie:' . $elem['name'] . ':' . $elem['host']] = (string)$elem;
    $redis->set('cookie:' . $elem['name'] . ':' . $elem['host'], (string)$elem);
}

//var_dump($cookies);
//var_dump($subdomains);
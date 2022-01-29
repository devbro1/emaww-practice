<?php

require 'vendor/autoload.php';

$verbose = array_search('-v',$argv);

$file_name = end($argv);
if(!file_exists(($file_name)))
{
    echo "File not found";
    exit;
}
$xml = new SimpleXMLElement(file_get_contents($file_name));

$redis = new Redis(); 
$redis->connect(getenv('REDIS_URL'), 6379); 
echo "Redis server is running: ".$redis->ping();

$subdomains = [];
foreach($xml->subdomains->subdomain as $elem)
{
    $subdomains[] = (string)$elem;
}

$redis->set("subdomains", json_encode($subdomains)); 
if($verbose)
{
    echo "subdomains\n";
}

foreach($xml->cookies->cookie as $elem)
{
    $key = 'cookie:' . $elem['name'] . ':' . $elem['host'];
    $redis->set($key, (string)$elem);
    if($verbose)
{
    echo "$key\n";
}
}


echo "Execution completed successfully";
//var_dump($cookies);
//var_dump($subdomains);
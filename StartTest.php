<?php declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class StartTest extends TestCase
{
    public function testCanConnectToRedis(): void
    {
        $redis = new Redis();
        $redis->connect(getenv('REDIS_URL'), 6379);
        var_dump($redis->ping());
        $this->assertTrue(
            $redis->ping()
        );
    }

    public function testSubdomainsIsJSON(): void
    {
        $redis = new Redis();
        $redis->connect(getenv('REDIS_URL'), 6379);
        $redis->flushAll();
        file_put_contents("test.xml", <<< AAA
<config>
    <subdomains>
        <subdomain>http://secureline.tools.avast.com</subdomain>
    </subdomains>
</config>
AAA
    );
        shell_exec("php start.php -v test.xml");
        $subdomains = $redis->get('subdomains');
        $this->assertTrue(is_array(json_decode($subdomains, true)));
    }

    public function testCookieIsValid(): void
    {
        $redis = new Redis();
        $redis->connect(getenv('REDIS_URL'), 6379);
        $redis->flushAll();
        file_put_contents("test.xml", <<< AAA
<config>
<cookies>
<cookie name="dlp-avast" host="amazon">MEOWMEOWMEOWMEOW</cookie>
</cookies>
</config>
AAA
    );
        shell_exec("php start.php -v test.xml");
        $this->assertEquals(
            $redis->get('cookie:dlp-avast:amazon'),
            'MEOWMEOWMEOWMEOW'
        );
    }
}
<?hh // strict

use type PHPUnit\Framework\TestCase;
use type Nazg\HSession\SessionManager;
use type Nazg\HSession\Repository;
use type Nazg\HCache\CacheProvider;
use type Nazg\HCache\Driver\MemcachedCache;

final class MemcachedDriverTest extends TestCase {

  private ?Repository $repository;

  <<__Override>>
  protected function setUp(): void {
    $manager = new SessionManager('hsessionhsessionhsessionhsessionhsession');
    $manager->configInjector('memcached', (CacheProvider $cacheProvider) ==> {
      if($cacheProvider instanceof MemcachedCache) {
        $mc = new \Memcached('mc');
        $mc->addServers([['127.0.0.1', 11211]]);
        $cacheProvider->setMemcached($mc);
      }
      return $cacheProvider;
    });
    $this->repository = $manager->create('memcached', 0);
  }

  public function testShouldReturnValues(): void {
    $this->repository?->start();
    $this->assertFalse($this->repository?->has('testing'));
    $this->repository?->put('testing', 'memcached-test');
    $this->assertTrue($this->repository?->has('testing'));
    $this->assertSame('memcached-test', $this->repository?->get('testing'));
    $this->repository?->save();
    $this->assertTrue($this->repository?->has('testing'));
    $this->assertSame('memcached-test', $this->repository?->get('testing'));
  }

  <<__Override>>
  protected function tearDown(): void {
    $this->repository?->flush();
    $this->repository?->save();
  }
}

<?hh // strict

use type PHPUnit\Framework\TestCase;
use type Nazg\HSession\CacheSessionHandler;
use type Nazg\HCache\Driver\VoidCache;

class CacheSessionHandlerTest extends TestCase {

  public function testShouldReturn(): void {
    $manager = new CacheSessionHandler(new VoidCache(), 0);
    $this->assertInstanceOf(CacheSessionHandler::class, $manager);
  }
}

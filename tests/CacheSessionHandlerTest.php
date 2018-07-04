<?hh // strict

use PHPUnit\Framework\TestCase;
use Nazg\HSession\SessionManager;
use Nazg\HSession\CacheSessionHandler;
use Nazg\HCache\Driver\VoidCache;
use Nazg\HSession\CacheSession;

class CacheSessionHandlerTest extends TestCase {
  
  public function testShouldReturn(): void {
    $manager = new CacheSessionHandler(new VoidCache(), 0);
    $this->assertInstanceOf(CacheSessionHandler::class, $manager);
  }
}

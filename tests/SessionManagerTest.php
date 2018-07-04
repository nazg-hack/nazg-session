<?hh // strict

use PHPUnit\Framework\TestCase;
use Nazg\HSession\SessionManager;
use Nazg\HSession\Repository;

class SessionManagerTest extends TestCase {
  
  public function testShouldReturn(): void {
    $manager = new SessionManager();
    $repository = $manager->create('map', 0);
    $this->assertInstanceOf(Repository::class, $repository);
  }
}

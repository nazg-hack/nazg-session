<?hh // strict

use type PHPUnit\Framework\TestCase;
use type Nazg\HSession\SessionManager;
use type Nazg\HSession\Store;

class SessionManagerTest extends TestCase {

  public function testShouldReturnSessionProvider(): void {
    $manager = new SessionManager();
    $repository = $manager->create('map', 0);
    $this->assertInstanceOf(Store::class, $repository);
  }

  public function testShouldReturnValues(): void {
    $manager = new SessionManager();
    $repository = $manager->create('map', 0);
    $this->assertFalse($repository->has('testing'));

    $repository->start();
    $repository->put('testing', 'hhvm');
    $this->assertTrue($repository->has('testing'));
    $this->assertSame('hhvm', $repository->get('testing'));
    $repository->save();
    $this->assertTrue($repository->has('testing'));
    $this->assertSame('hhvm', $repository->get('testing'));
  }

  public function testShouldReturnNull(): void {
    $manager = new SessionManager();
    $repository = $manager->create('map', 0);
    $this->assertFalse($repository->has('testing'));
    $repository->start();
    $repository->put('testing', 'hhvm');
    $this->assertTrue($repository->has('testing'));
    $this->assertSame('hhvm', $repository->get('testing'));
    $repository->flush();
    $this->assertFalse($repository->has('testing'));
    $this->assertNull($repository->get('testing'));
  }
}

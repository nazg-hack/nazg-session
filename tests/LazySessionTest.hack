use type Ytake\Hungrr\ServerRequestFactory;
use type Nazg\Session\LazySession;
use type Nazg\Session\Exception\NotInitializableException;
use type Nazg\HCache\Driver\MapCache;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class LazySessionTest extends HackTest {

  public async function testShouldStoreValue(): Awaitable<void> {
    $request = ServerRequestFactory::fromGlobals();
    $lazy = new LazySession(
      new CachePersistence(new MapCache(), 'hello'),
      $request
    );
    $lazy->set<int>('user', 1);
    expect($lazy->has('user'))->toBeTrue();
    expect($lazy->get('user'))->toBeSame(1);
  }

  public async function testShouldThrowException(): Awaitable<void> {
    $request = ServerRequestFactory::fromGlobals();
    $lazy = new LazySession(
      new CachePersistence(new MapCache(), 'hello'),
      $request
    );
    expect(() ==> $lazy->initializeId())
      ->toThrow(NotInitializableException::class);
  }

  public async function testShouldReturnDefaultLifetime(): Awaitable<void> {
    $request = ServerRequestFactory::fromGlobals();
    $lazy = new LazySession(
      new CachePersistence(new MapCache(), 'hello'),
      $request
    );
    expect($lazy->getSessionLifetime())->toBeSame(0);
  }

  public async function testShouldReturnEmptyGetId(): Awaitable<void> {
    $request = ServerRequestFactory::fromGlobals();
    $lazy = new LazySession(
      new CachePersistence(new MapCache(), 'hello'),
      $request
    );
    expect($lazy->getId())->toBeEmpty();
  }
}

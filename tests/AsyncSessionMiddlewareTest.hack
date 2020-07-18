use type Nazg\HCache\Driver\MapCache;
use type Nazg\Session\AsyncSessionMiddleware;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class AsyncSessionMiddlewareTest extends HackTest {

  public async function testShouldReturnInstance(): Awaitable<void> {
    $middleware = new AsyncSessionMiddleware(
      new CachePersistence(new MapCache(), 'hello')
    );
    expect($middleware)->toBeInstanceOf(AsyncSessionMiddleware::class);
  }
}

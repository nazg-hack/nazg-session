namespace Nazg\Session;

use type Nazg\Session\LazeSession;
use type HH\Lib\IO\CloseableWriteHandle;
use type Facebook\Experimental\Http\Message\ResponseInterface;
use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use namespace Nazg\Http\Server;

class AsyncSessionMiddleware implements Server\AsyncMiddlewareInterface {

  const string SESSION_ATTRIBUTE = 'session';

  public function __construct(
    private SessionPersistenceInterface $persistence
  ) {}

  public async function processAsync(
    CloseableWriteHandle $writeHandle,
    ServerRequestInterface $request,
    Server\AsyncRequestHandlerInterface $handler
  ): Awaitable<ResponseInterface> {
    $session = new LazySession($this->persistence, $request);
    $response = await $handler->handleAsync(
      $writeHandle,
      $request->withServerParams(dict[self::SESSION_ATTRIBUTE => \serialize($session)])
    );
    return $this->persistence->persistSession($session, $response);
  }
}

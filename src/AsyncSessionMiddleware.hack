namespace Nazg\Session;

use type HH\Lib\IO\CloseableWriteHandle;
use type Facebook\Experimental\Http\Message\{ResponseInterface, ServerRequestInterface};
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
    if ($request is \Ytake\Extended\HttpMessage\ServerRequestInterface) {
      $request = $request->withAttribute(self::SESSION_ATTRIBUTE, $session);
    }
    $response = await $handler->handleAsync(
      $writeHandle,
      $request
    );
    return await $this->persistence->persistSessionAsync($session, $response);
  }
}

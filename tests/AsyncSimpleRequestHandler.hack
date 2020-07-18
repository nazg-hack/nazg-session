use type Nazg\Http\Server\AsyncRequestHandlerInterface;
use type Facebook\Experimental\Http\Message\{
  ResponseInterface,
  ServerRequestInterface,
};
use type Ytake\Hungrr\{Response, StatusCode};
use namespace HH\Lib\IO;

final class AsyncSimpleRequestHandler implements AsyncRequestHandlerInterface {

  public async function handleAsync(
    IO\WriteHandle $handle,
    ServerRequestInterface $request
  ): Awaitable<ResponseInterface> {
    if($handle is IO\CloseableWriteHandle) {
      $handle->close();
    }
    return new Response($handle, StatusCode::OK);
  }
}

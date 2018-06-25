<?hh // strict

namespace Nazg\HSession;

use SessionHandlerInterface;
use Nazg\HCache\Element;
use Nazg\HCache\CacheProvider;

class CacheSessionHandler implements SessionHandlerInterface {

  public function __construct(
    protected CacheProvider $cache, 
    protected int $minutes
  ) {}

  public function open(string $savePath, string $sessionName): bool {
    return true;
  }

  public function close(): bool {
    return true;
  }

  public function read(string $sessionId): string {
    $result = $this->cache->fetch($sessionId);
    if(!\is_null($result)) {
      return \strval($result);
    }
    return '';
  }

  public function write(string $sessionId, Element $data): bool {
    return $this->cache->save($sessionId, $data);
  }

  public function destroy(string $sessionId): bool {
    return $this->cache->delete($sessionId);
  }

  public function gc(string $lifetime): bool {
    return $this->cache->flushAll();
  }

  public function getCache(): CacheProvider {
    return $this->cache;
  }
}

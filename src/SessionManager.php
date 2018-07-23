<?hh // strict

/**
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * This software consists of voluntary contributions made by many individuals
 * and is licensed under the MIT license.
 *
 * Copyright (c) 2018 Yuuki Takezawa
 *
 */

namespace Nazg\HSession;

use type Nazg\HCache\CacheProvider;
use type Nazg\HSession\Exception\SessionDriverNameExistsException;
use type SessionHandlerInterface;

use function is_null;
use function call_user_func_array;

<<__ConsistentConstruct>>
class SessionManager {

  protected Map<string, classname<CacheProvider>> $cacheHandler = Map {
    'apc' => \Nazg\HCache\Driver\ApcCache::class,
    'void' => \Nazg\HCache\Driver\VoidCache::class,
    'map' => \Nazg\HCache\Driver\MapCache::class,
    'file' => \Nazg\HCache\Driver\FileSystemCache::class,
    'memcached' => \Nazg\HCache\Driver\MemcachedCache::class,
    'redis' => \Nazg\HCache\Driver\RedisCache::class,
  };

  protected Map<string, (function(CacheProvider): CacheProvider)> $cacheConfigure = Map{};
  protected Map<string, (function():SessionHandlerInterface)> $userSession = Map{};

  public function __construct(
    protected ?string $sessionId = null
  ) { }

  public function create(string $namedSession, int $minutes): Repository {
    $handler = $this->setHandler(
      $this->buildSession($namedSession, $minutes)
    );
    return new Repository($namedSession, $handler, $this->sessionId);
  }

  public function configInjector(
    string $name,
    (function(CacheProvider): CacheProvider) $callback
  ): void {
    $this->cacheConfigure->add(Pair{$name, $callback});
  }

  protected function buildSession(string $namedSession, int $minutes): SessionHandlerInterface {
    if($this->cacheHandler->contains($namedSession)) {
      $session = $this->cacheHandler->at($namedSession);
      $instance = new $session();
      if($this->cacheConfigure->contains($namedSession)) {
        $callback = $this->cacheConfigure->get($namedSession);
        if(!is_null($callback)) {
          $instance = $this->callbackCacheInstance($instance, $callback);
        }
      }
      return new CacheSessionHandler($instance, $minutes);
    }
    if($this->userSession->contains($namedSession)) {
      $session = $this->userSession->at($namedSession);
      return $session();
    }
    throw new SessionDriverNameExistsException();
  }

  protected function callbackCacheInstance<T>(
    T $provider,
    (function(CacheProvider): CacheProvider) $callback
  ): T {
    return call_user_func_array($callback, [$provider]);
  }

  public function addCustomSession(
    string $name,
    (function():SessionHandlerInterface) $session
  ): void {
    $this->userSession->add(Pair{$name, $session});
    if($this->userSession->contains($name)) {
      $this->userSession->remove($name);
    }
  }

  protected function setHandler(SessionHandlerInterface $handler): SessionHandlerInterface {
    if (!\headers_sent()) {
      \session_set_save_handler(
        [$handler, 'open'],
        [$handler, 'close'],
        [$handler, 'read'],
        [$handler, 'write'],
        [$handler, 'destroy'],
        [$handler, 'gc'],
      );
    }
    return $handler;
  }
}

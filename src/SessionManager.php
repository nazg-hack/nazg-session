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

use Nazg\HCache\CacheProvider;
use Nazg\HSession\Exception\SessionDriverNameExistsException;
use SessionHandlerInterface;

class SessionManager {
  
  protected Map<string, classname<CacheProvider>> $cacheHandler = Map {
    'apc' => \Nazg\HCache\Driver\ApcCache::class,
    'void' => \Nazg\HCache\Driver\VoidCache::class,
    'map' => \Nazg\HCache\Driver\MapCache::class,
    'file' => \Nazg\HCache\Driver\FileSystemCache::class,
    'memcached' => \Nazg\HCache\Driver\MemcachedCache::class,
    'redis' => \Nazg\HCache\Driver\RedisCache::class,
  };

  protected Map<string, (function():SessionHandlerInterface)> $userSession = Map{};

  
  public function create(string $namedSession, int $minutes): Repository {
    $handler = $this->setHandler(
      $this->buildSession($namedSession, $minutes)
    );
    return new Repository($namedSession, $handler);
  }

  protected function buildSession(string $namedSession, int $minutes): SessionHandlerInterface {
    if($this->cacheHandler->contains($namedSession)) {
      $session = $this->cacheHandler->at($namedSession);
      return new CacheSessionHandler(new $session(), $minutes);
    }
    if($this->userSession->contains($namedSession)) {
      $session = $this->userSession->at($namedSession);
      return $session();
    }
    throw new SessionDriverNameExistsException();
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

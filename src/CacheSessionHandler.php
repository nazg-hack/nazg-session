<?hh

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

use type Nazg\HCache\Element;
use type Nazg\HCache\CacheProvider;
use type SessionHandlerInterface;

class CacheSessionHandler implements \SessionHandlerInterface {

  public function __construct(
    protected CacheProvider $cache,
    protected int $minutes
  ) {}

  public function open($_savePath, $_sessionName): bool {
    return true;
  }

  public function close(): bool {
    return true;
  }

  public function read($sessionId): string {
    $result = $this->cache->fetch($sessionId);
    if(!\is_null($result)) {
      return \strval($result);
    }
    return '';
  }

  public function write($sessionId, $data): bool {
    return $this->cache->save($sessionId, new Element($data, $this->minutes));
  }

  public function destroy($sessionId): bool {
    return $this->cache->delete($sessionId);
  }

  public function gc($_lifetime): bool {
    return $this->cache->flushAll();
  }

  public function getCache(): CacheProvider {
    return $this->cache;
  }
}

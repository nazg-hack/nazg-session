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

use type SessionHandlerInterface;
use function unserialize;
use function serialize;
use function is_null;
use function is_array;

type SessionAttributes = Map<string, mixed>;

class Repository {

  protected SessionAttributes $attributes = Map {};

  protected bool $started = false;

  public function __construct(
    protected string $name,
    protected SessionHandlerInterface $handler,
    protected ?string $id = null
  ) {
    $this->setId($id);
  }

  public function start(): bool {
    $this->loadSession();
    return $this->started = true;
  }

  protected function loadSession(): void {
    $this->attributes = $this->readFromHandler();
  }

  protected function readFromHandler(): Map<string, mixed> {
    if ($data = $this->handler->read($this->getId())) {
      $data = @unserialize($this->prepareForUnserialize($data));
      if ($data !== false && ! is_null($data) && is_array($data)) {
        return new Map($data);
      }
    }
    return Map{ };
  }

  protected function prepareForUnserialize(string $data): string {
    return $data;
  }

  public function save(): void {
    $this->handler->write(
      $this->getId(),
      $this->prepareForStorage(
        serialize($this->attributes->toArray())
      )
    );
    $this->started = false;
  }

  protected function prepareForStorage(string $data): string {
    return $data;
  }

  /**
   * all session data
   */
  public function all(): SessionAttributes {
    return $this->attributes;
  }

  public function has(string $key): bool {
    return $this->attributes->containsKey($key);
  }

  public function get(string $key, mixed $default = null): mixed {
    if($this->has($key)) {
      return $this->attributes->get($key);
    }
    return $default;
  }

  public function pull(string $key, mixed $default = null): mixed {
    if($this->has($key)) {
      $value = $this->attributes->get($key);
      $this->attributes->removeKey($key);
      return $value;
    }
    return $default;
  }

  public function replace(Map<string, mixed> $attributes): void {
    foreach ($attributes as $key => $value) {
      $this->put($key, $value);
    }
  }

  /**
   * put a key / value pair
   */
  public function put(string $key, mixed $value): void {
    $this->attributes->add(Pair{$key, $value});
  }

  public function remove(string $key): SessionAttributes {
    return $this->attributes->removeKey($key);
  }

  /**
   * Remove many items from session.
   */
  public function forget(array<string> $keys): void {
    foreach($keys as $key) {
      $this->remove($key);
    }
  }

  public function flush(): void {
    $this->attributes->clear();
  }

  public function invalidate(): bool {
    $this->flush();
    return $this->migrate(true);
  }

  public function migrate(bool $destroy = false): bool {
    if ($destroy) {
      $this->handler->destroy($this->getId());
    }
    $this->setId($this->generateSessionId());
    return true;
  }

  public function isStarted(): bool {
    return $this->started;
  }

  public function getName(): string {
    return $this->name;
  }

  public function setName(string $name): void {
    $this->name = $name;
  }

  public function getId(): ?string {
    return $this->id;
  }

  /**
   * Set the session ID.
   */
  public function setId(?string $id): void {
    $this->id = $this->isValidId($id) ? $id : $this->generateSessionId();
  }


  public function isValidId(?string $id): bool {
    return \is_string($id) && \ctype_alnum($id) && \strlen($id) === 40;
  }

  protected function generateSessionId(): string {
    return $this->random(40);
  }

  protected function random(int $length = 16): string {
    $string = '';
    while (($len = \strlen($string)) < $length) {
      $size = $length - $len;
      $bytes = \random_bytes($size);
      $string .= \substr(\str_replace(['/', '+', '='], '', \base64_encode($bytes)), 0, $size);
    }
    return $string;
  }

  public function getHandler(): SessionHandlerInterface {
    return $this->handler;
  }
}

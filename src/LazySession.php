<?hh // strict

namespace Nazg\HSession;

use Nazg\HCache\Element;
use SessionHandlerInterface;
use Psr\Http\Message\ServerRequestInterface;

class LazySession implements SessionInterface {
  
  protected Map<string, Element> $map = Map{};

  public function __construct(
    protected SessionHandlerInterface $sessionProvider
  ) {}

  // 
  public function get(string $name, mixed $default = null): mixed {
    if($this->has($name)) {
      return $this->map->at($name);
    }
    return null;
  }

  public function has(string $name) : bool {
    return $this->map->contains($name);
  }
  
  public function set(string $name, mixed $value) : void {
    $this->map->set($name, new Element($value));
  }

  public function unset(string $name) : void {
    $this->map->remove($name);
  }

  public function clear() : void {
    $this->sessionProvider->
    return;
  }
}

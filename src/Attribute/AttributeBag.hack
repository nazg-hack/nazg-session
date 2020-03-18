namespace Nazg\Session\Attribute;

use namespace HH\Lib\C;
use function array_key_exists;

class AttributeBag implements AttributeBagInterface, \IteratorAggregate<mixed>, \Countable {

  private string $name = 'attributes';
  protected dict<arraykey, mixed> $attributes = dict[];

  public function __construct(
    private string $storageKey = '_nazg_attributes'
  ) {}

  public function getName(): string {
    return $this->name;
  }

  public function setName(string $name): void {
    $this->name = $name;
  }

  public function initialize(
    inout dict<arraykey, mixed> $dict
  ): void {
    $this->attributes = $dict;
  }

  public function getStorageKey(): string {
    return $this->storageKey;
  }

  public function has(arraykey $name): bool {
    return array_key_exists($name, $this->attributes);
  }

  public function get(
    arraykey $name,
    mixed $default = null
  ): mixed {
    return array_key_exists($name, $this->attributes) ? $this->attributes[$name] : $default;
  }

  public function set(arraykey $name, mixed $value): void {
    $this->attributes[$name] = $value;
  }

  public function all(): dict<arraykey, mixed> {
    return $this->attributes;
  }

  public function replace(
    dict<arraykey, mixed> $attributes
  ): void {
    $this->attributes = dict[];
    foreach ($attributes as $key => $value) {
      $this->set($key, $value);
    }
  }

  public function remove(string $name): mixed {
    $retval = null;
    if (array_key_exists($name, $this->attributes)) {
      $retval = $this->attributes[$name];
      unset($this->attributes[$name]);
    }
    return $retval;
  }

  public function clear(): mixed {
    $return = $this->attributes;
    $this->attributes = dict[];
    return $return;
  }

  public function getIterator(): \ArrayIterator<mixed> {
    return new \ArrayIterator($this->attributes);
  }

  <<__Rx>>
  public function count(): int {
    return C\count($this->attributes);
  }
}

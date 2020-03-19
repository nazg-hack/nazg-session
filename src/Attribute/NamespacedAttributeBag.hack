namespace Nazg\Session\Attribute;

use namespace HH\Lib\{C, Dict, Str};
use function array_key_exists;

class NamespacedAttributeBag extends AttributeBag {

  public function __construct(
    string $storageKey = '_nazg_attributes',
    private string $namespaceCharacter = '/'
  ) {
    parent::__construct($storageKey);
  }

  protected function resolveAttributePath(
    inout dict<arraykey, mixed> $attributes,
    string $name,
    bool $writeContext = false
  ): ?dict<arraykey, mixed> {
    //
    $array = $attributes;
    $name = (0 === Str\search($name, $this->namespaceCharacter)) ? Str\slice($name, 1) : $name;
    if (!$name) {
      return $array;
    }
    $parts = Str\split($this->namespaceCharacter, $name);
    if (C\count($parts) < 2) {
      if (!$writeContext) {
        return $array;
      }
      $array[$parts[0]] = dict[];
      return $array;
    }
    $parts = Dict\drop($parts, C\count($parts) - 1);

    foreach ($parts as $part) {
      if ($array is dict<_, _>) {
        if (!array_key_exists($part, $array)) {
          if (!$writeContext) {
            return null;
          }
        }
        $array[$part] = dict[];
      }
      if ($array is dict<_, _>) {
        $array = $array[$part];
      }
    }
    $array as dict<_, _>;
    return $array;
  }

  <<__Rx>>
  protected function resolveKey(string $name): string {
    $pos = Str\search_last($name, $this->namespaceCharacter);
    if ($pos is nonnull) {
      $name = Str\slice($name, $pos + 1);
    }
    return $name;
  }

  <<__Override>>
  public function has(string $name): bool {
    $att = $this->attributes;
    $attributes = $this->resolveAttributePath(inout $att, $name);
    $name = $this->resolveKey($name);
    if (null === $attributes) {
      return false;
    }
    return array_key_exists($name, $attributes);
  }

  <<__Override>>
  public function get(string $name, mixed $default = null): mixed {
    $att = $this->attributes;
    $attributes = $this->resolveAttributePath(inout $att, $name);
    $name = $this->resolveKey($name);
    if (null === $attributes) {
      return $default;
    }
    return array_key_exists($name, $attributes) ? $attributes[$name] : $default;
  }

  <<__Override>>
  public function set(string $name, mixed $value): void {
    $att = $this->attributes;
    $attributes = $this->resolveAttributePath(inout $att, $name, true);
    if ($attributes is dict<_, _>) {
      $name = $this->resolveKey($name);
      $attributes[$name] = $value;
    }
  }
}

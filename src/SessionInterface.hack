namespace Nazg\Session;

interface SessionInterface {

  public function toDict(): dict<arraykey, mixed>;

  public function get(
    string $name,
    mixed $default = null
  ): mixed;

  public function has(
    string $name
  ): bool;

  public function set<T>(
    string $name,
    T $value
  ): void;

  public function unset(
    string $name
  ): void;

  public function clear(): void;

  public function hasChanged(): bool;

  public function regenerate(): SessionInterface;

  public function isRegenerated(): bool;
}

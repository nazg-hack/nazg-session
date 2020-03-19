namespace Nazg\Session\Attribute;

use type Nazg\Session\SessionBagInterface;

interface AttributeBagInterface extends SessionBagInterface {

  /**
   * Checks if an attribute is defined.
   */
  public function has(string $name): bool;

  /**
   * Returns an attribute.
   */
  public function get(string $name, mixed $default = null): mixed;

  /**
   * Sets an attribute.
   */
  public function set(string $name, mixed $value): void;

  /**
   * Returns attributes.
   */
  public function all(): dict<arraykey, mixed>;

  public function replace(
    dict<string, mixed> $attributes
  ): void;

  /**
   * Removes an attribute.
   */
  public function remove(string $name): mixed;
}

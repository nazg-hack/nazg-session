namespace Nazg\Session\Attribute;

use type Nazg\Session\SessionBagInterface;

interface AttributeBagInterface extends SessionBagInterface {

  /**
   * Checks if an attribute is defined.
   */
  public function has(arraykey $name): bool;

  /**
   * Returns an attribute.
   */
  public function get(arraykey $name, mixed $default = null): mixed;

  /**
   * Sets an attribute.
   */
  public function set(arraykey $name, mixed $value): void;

  /**
   * Returns attributes.
   */
  public function all(): dict<arraykey, mixed>;

  public function replace(
    dict<arraykey, mixed> $attributes
  ): void;

  /**
   * Removes an attribute.
   */
  public function remove(string $name): mixed;
}

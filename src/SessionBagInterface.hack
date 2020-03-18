namespace Nazg\Session;

interface SessionBagInterface {
  /**
   * Gets this bag's name.
   */
  public function getName(): string;

  /**
   * Initializes the Bag.
   */
  public function initialize(
    inout dict<arraykey, mixed> $dict
  ): void;

  /**
   * Gets the storage key for this bag.
   */
  public function getStorageKey(): string;

  /**
   * Clears out data from bag.
   */
  public function clear(): mixed;
}

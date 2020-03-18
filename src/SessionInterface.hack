namespace Nazg\Session;

use type Nazg\Session\Storage\MetadataBag;

interface SessionInterface {
  /**
   * Starts the session storage.
   * @throws \RuntimeException if session fails to start
   */
  public function start(): bool;

  /**
   * Returns the session ID.
   */
  public function getId(): string;

  /**
   * Sets the session ID.
   */
  public function setId(string $id): void;

  /**
   * Returns the session name.
   */
  public function getName(): string;

  /**
   * Sets the session name.
   */
  public function setName(string $name): void;

  /**
   * Clears all session attributes and flashes and regenerates the
   * session and deletes the old session from persistence.
   */
  public function invalidate(int $lifetime = 0): bool;

    /**
     * Migrates the current session to a new session id while maintaining all
     * session attributes.
     */
  public function migrate(
    bool $destroy = false,
    int $lifetime = 0
  ): bool;

  /**
   * Force the session to be saved and closed.
   */
  public function save(): void;

  /**
   * Checks if an attribute is defined.
   */
  public function has(string $name): bool;

  /**
   * Returns an attribute.
   */
  public function get(
    string $name,
    mixed $default = null
  ): mixed;

  /**
   * Sets an attribute.
   */
  public function set(
    string $name,
    mixed $value
  ): void;

  /**
   * Returns attributes.
   */
  public function all(): dict<arraykey, mixed>;

  /**
   * Sets attributes.
   */
  public function replace(
    dict<arraykey, mixed> $attributes
  ): void;

  /**
   * Removes an attribute.
   */
  public function remove(string $name): mixed;

  /**
   * Clears all attributes.
   */
  public function clear(): void;

  /**
   * Checks if the session was started.
   */
  public function isStarted(): bool;

  /**
   * Registers a SessionBagInterface with the session.
   */
  public function registerBag(
    SessionBagInterface $bag
  ): void;

  /**
   * Gets a bag instance by name.
   */
  public function getBag(
    string $name
  ): SessionBagInterface;

  /**
   * Gets session meta.
   */
  public function getMetadataBag(): MetadataBag;
}

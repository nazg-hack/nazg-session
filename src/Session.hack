namespace Nazg\Session;

use namespace HH\Lib\Dict;
use function array_key_exists;
use function json_decode;
use function json_encode;

use const JSON_PRESERVE_ZERO_FRACTION;

class Session implements SessionCookiePersistenceInterface,
  SessionIdentifierAwareInterface,
  SessionInterface {

  private dict<arraykey, mixed> $data;
  private bool $isRegenerated = false;
  private dict<arraykey, mixed> $originalData = dict[];
  private int $sessionLifetime = 0;

  public function __construct(
    dict<arraykey, mixed> $data,
    private string $id = ''
  ) {
    $this->originalData = $data;
    $this->data = $data;
    $this->id = $id;

    if(array_key_exists(SessionCookiePersistenceInterface::SESSION_LIFETIME_KEY, $data)) {
      $persistence = $data[SessionCookiePersistenceInterface::SESSION_LIFETIME_KEY];
      $persistence as int;
      $this->sessionLifetime = $persistence;
    }
  }

  <<__Rx>>
  public static function extractSerializableValue(mixed $value): mixed {
    return json_decode(json_encode($value, JSON_PRESERVE_ZERO_FRACTION), true);
  }

  <<__Rx>>
  public function toDict(): dict<arraykey, mixed> {
    return $this->data;
  }

  <<__Rx>>
  public function get(string $name, mixed $default = null): mixed {
    return $this->data[$name] ?? $default;
  }

  <<__Rx>>
  public function has(string $name): bool {
    return array_key_exists($name, $this->data);
  }

  public function set<T>(string $name, T $value): void {
    $this->data[$name] = self::extractSerializableValue($value);
  }

  public function unset(string $name): void {
    $this->data = Dict\filter_with_key($this->data, ($k, $_) ==> $k !== $name);
  }

  public function clear(): void {
    $this->data = dict[];
  }

  public function hasChanged(): bool {
    if ($this->isRegenerated) {
      return true;
    }
    return $this->data !== $this->originalData;
  }

  public function regenerate(): SessionInterface {
    $session = clone $this;
    $session->isRegenerated = true;
    return $session;
  }

  public function isRegenerated(): bool {
    return $this->isRegenerated;
  }

  public function getId(): string {
    return $this->id;
  }

  public function persistSessionFor(
    int $duration
  ): void {
    $this->sessionLifetime = $duration;
    $this->set(SessionCookiePersistenceInterface::SESSION_LIFETIME_KEY, $duration);
  }

  public function getSessionLifetime(): int {
    return $this->sessionLifetime;
  }
}

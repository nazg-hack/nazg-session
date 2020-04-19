namespace Nazg\Session;

interface SessionCookiePersistenceInterface {

  const string SESSION_LIFETIME_KEY = '__SESSION_TTL__';

  public function persistSessionFor(int $duration): void;

  public function getSessionLifetime(): int;
}

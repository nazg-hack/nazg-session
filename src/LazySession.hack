namespace Nazg\Session;

use type Facebook\Experimental\Http\Message\ServerRequestInterface;
use type Nazg\Session\Exception\NotInitializableException;

final class LazySession implements
  SessionCookiePersistenceInterface,
  SessionIdentifierAwareInterface,
  SessionInterface,
  InitializeSessionIdInterface {

  <<__LateInit>> private ?SessionInterface $proxiedSession;

  public function __construct(
    private SessionPersistenceInterface $persistence,
    private ServerRequestInterface $request
  ) {}

  public function regenerate(): SessionInterface {
    $this->proxiedSession = $this->getProxiedSession()->regenerate();
    return $this;
  }

  public function isRegenerated(): bool {
    if (!$this->proxiedSession) {
      return false;
    }
    return $this->proxiedSession->isRegenerated();
  }

  public function toDict(): dict<arraykey, mixed> {
    return $this->getProxiedSession()->toDict();
  }

  public function get(
    string $name,
    mixed $default = null
  ): mixed {
    return $this->getProxiedSession()->get($name, $default);
  }

  public function has(
    string $name
  ): bool {
    return $this->getProxiedSession()->has($name);
  }

  public function set<T>(
    string $name,
    T $value
  ) : void {
    $this->getProxiedSession()->set($name, $value);
  }

  public function unset(
    string $name
  ): void {
    $this->getProxiedSession()->unset($name);
  }

  public function clear(): void {
    $this->getProxiedSession()->clear();
  }

  public function hasChanged(): bool {
    if (!$this->proxiedSession) {
      return false;
    }

    if ($this->proxiedSession->isRegenerated()) {
      return true;
    }
    /* HH_FIXME[4064] */
    return $this->proxiedSession->hasChanged();
  }

  <<__Memoize>>
  private function getProxiedSession(): SessionInterface {
    $this->proxiedSession = $this->persistence->initializeSessionFromRequest($this->request);
    return $this->proxiedSession;
  }

  public function getId(): string {
    $proxiedSession = $this->getProxiedSession();
    return $proxiedSession is SessionIdentifierAwareInterface ? $proxiedSession->getId() : '';
  }

  public function persistSessionFor(
    int $duration
  ): void {
    $proxiedSession = $this->getProxiedSession();
    if ($proxiedSession is SessionCookiePersistenceInterface) {
      $proxiedSession->persistSessionFor($duration);
    }
  }

  public function getSessionLifetime(): int {
    $proxiedSession = $this->getProxiedSession();
    return $proxiedSession is SessionCookiePersistenceInterface 
      ? $proxiedSession->getSessionLifetime() : 0;
  }

  public function initializeId(): string {
    if (!$this->persistence is InitializePersistenceIdInterface) {
      throw NotInitializableException::invalidPersistence($this->persistence);
    }
    $this->proxiedSession = $this->persistence->initializeId($this->getProxiedSession());
    /* HH_FIXME[4053] */
    return $this->proxiedSession->getId();
  }
}

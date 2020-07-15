use type Nazg\HCache\{CacheProvider, Element};
use type Nazg\Session\{Session, SessionCookiePersistenceInterface, SessionIdentifierAwareInterface, SessionInterface, SessionPersistenceInterface};
use type Facebook\Experimental\Http\Message\{ResponseInterface, ServerRequestInterface};
use type Ytake\HackCookie\{RequestCookies, ResponseCookies, SameSite, SetCookie};

use function bin2hex;
use function file_exists;
use function filemtime;
use function getcwd;
use function gmdate;
use function in_array;
use function random_bytes;
use function sprintf;
use function time;

class CachePersistence implements SessionPersistenceInterface {

  const string CACHE_PAST_DATE  = 'Thu, 19 Nov 1981 08:52:00 GMT';

  const string HTTP_DATE_FORMAT = 'D, d M Y H:i:s T';

  private vec<string> $supportedCacheLimiters = vec[
    'nocache',
    'public',
    'private',
    'private_no_expire',
  ];

  private string $cacheLimiter;
  private string $lastModified;

  public function __construct(
    private CacheProvider $cache,
    private string $cookieName,
    private string $cookiePath = '/',
    string $cacheLimiter = 'nocache',
    private int $cacheExpire = 10800,
    ?int $lastModified = null,
    private bool $persistent = false,
    private string $cookieDomain = '',
    private bool $cookieSecure = false,
    private bool $cookieHttpOnly = false,
    private string $cookieSameSite = 'Lax'
  ) {

    $this->cacheLimiter = in_array($cacheLimiter, $this->supportedCacheLimiters, true)
        ? $cacheLimiter
        : 'nocache';

    $this->lastModified = $lastModified ? gmdate(self::HTTP_DATE_FORMAT, $lastModified)
      : $this->determineLastModifiedValue();
  }


  public function initializeSessionFromRequest(
    ServerRequestInterface $request
  ): SessionInterface {
    $id = $this->getCookieFromRequest($request);
    $sessionData = $id ? $this->getSessionDataFromCache($id) : dict[];
    return new Session($sessionData, $id);
  }

  public async function persistSessionAsync(
    SessionInterface $session,
    ResponseInterface $response
  ): Awaitable<ResponseInterface> {
    $id = '';
    if ($session is SessionIdentifierAwareInterface) {
      $id = $session->getId();
    }
    // New session? No data? Nothing to do.
    if ('' === $id
            && (dict[] === $session->toDict() || ! $session->hasChanged())
    ) {
      return $response;
    }

    if ('' === $id || $session->isRegenerated() || $session->hasChanged()) {
      $id = $this->regenerateSession($id);
    }

    await $this->persistSessionDataToCacheAsync($id, $session->toDict());

    $sessionCookie = SetCookie::create($this->cookieName)
      ->withValue($id)
      ->withDomain($this->cookieDomain)
      ->withPath($this->cookiePath)
      ->withSecure($this->cookieSecure)
      ->withHttpOnly($this->cookieHttpOnly)
      ->withSameSite(SameSite::assert($this->cookieSameSite));

    $persistenceDuration = $this->getPersistenceDuration($session);
    if ($persistenceDuration) {
      $sessionCookie = $sessionCookie->withExpires(
        (new DateTimeImmutable())->add(new DateInterval(sprintf('PT%dS', $persistenceDuration)))
      );
    }
    $response = ResponseCookies::set($response, $sessionCookie);
    if ($this->responseAlreadyHasCacheHeaders($response)) {
      return $response;
    }

    foreach ($this->generateCacheHeaders() as $name => $value) {
      $response = $response->withHeader($name, vec[$value]);
    }
    return $response;
  }

  private function regenerateSession(string $id) : string {
    if ('' !== $id && $this->cache->contains($id)) {
      $this->cache->delete($id);
    }
    return $this->generateSessionId();
  }

  private function generateSessionId() : string {
    return bin2hex(random_bytes(16));
  }

  private function generateCacheHeaders() : dict<string, string> {
    if ('nocache' === $this->cacheLimiter) {
      return dict[
        'Expires'       => self::CACHE_PAST_DATE,
        'Cache-Control' => 'no-store, no-cache, must-revalidate',
        'Pragma'        => 'no-cache',
      ];
    }

    // cache_limiter: 'public'
    if ('public' === $this->cacheLimiter) {
      return dict[
        'Expires'       => gmdate(self::HTTP_DATE_FORMAT, time() + $this->cacheExpire),
        'Cache-Control' => sprintf('public, max-age=%d', $this->cacheExpire),
        'Last-Modified' => $this->lastModified,
      ];
    }

    // cache_limiter: 'private'
    if ('private' === $this->cacheLimiter) {
      return dict[
        'Expires'       => self::CACHE_PAST_DATE,
        'Cache-Control' => sprintf('private, max-age=%d', $this->cacheExpire),
        'Last-Modified' => $this->lastModified,
      ];
    }

    return dict[
      'Cache-Control' => sprintf('private, max-age=%d', $this->cacheExpire),
      'Last-Modified' => $this->lastModified,
    ];
  }

  private function determineLastModifiedValue() : string {
    $cwd = getcwd();
    foreach (vec['public/index.php', 'index.php'] as $filename) {
      $path = sprintf('%s/%s', $cwd, $filename);
      if (! file_exists($path)) {
        continue;
      }
      return gmdate(self::HTTP_DATE_FORMAT, filemtime($path));
    }
    return gmdate(self::HTTP_DATE_FORMAT, filemtime($cwd));
  }

  private function getCookieFromRequest(
    ServerRequestInterface $request
  ): string {
    if ('' !== $request->getHeaderLine('Cookie')) {
      return RequestCookies::get($request, $this->cookieName)->getValue() ?? '';
    }
    return $request->getCookieParams()[$this->cookieName] ?? '';
  }

  private function getSessionDataFromCache(string $id): dict<arraykey, mixed> {
    $item = $this->cache->contains($id);
    if (!$item){
      return dict[];
    }
    $data = $this->cache->fetch($id);
    $data as dict<_, _>;
    return $data ?: dict[];
  }

  private async function persistSessionDataToCacheAsync(
    string $id,
    dict<arraykey, mixed> $data
  ) : Awaitable<void> {
    $this->cache->save($id, new Element($data, $this->cacheExpire));
  }

  private function responseAlreadyHasCacheHeaders(ResponseInterface $response) : bool {
    return (
      $response->hasHeader('Expires')
      || $response->hasHeader('Last-Modified')
      || $response->hasHeader('Cache-Control')
      || $response->hasHeader('Pragma')
    );
  }

  private function getPersistenceDuration(SessionInterface $session) : int {
    $duration = $this->persistent ? $this->cacheExpire : 0;
    if ($session is SessionCookiePersistenceInterface
      && $session->has(SessionCookiePersistenceInterface::SESSION_LIFETIME_KEY)
    ) {
      $duration = $session->getSessionLifetime();
    }
    return $duration < 0 ? 0 : $duration;
  }
}

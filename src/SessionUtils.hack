namespace Nazg\Session;

use namespace HH\Lib\Str;

use function urlencode;
use function headers_list;
use function header_remove;
use function header;

final class SessionUtils {

  public static function popSessionCookie(
    string $sessionName,
    string $sessionId
  ): ?string {
    $sessionCookie = null;
    $sessionCookiePrefix = Str\format(' %s=', urlencode($sessionName));
    $sessionCookieWithId = Str\format('%s%s;', $sessionCookiePrefix, urlencode($sessionId));
    $otherCookies = vec[];
    foreach (headers_list() as $h) {
      if (0 !== Str\search_ci($h, 'Set-Cookie:')) {
        continue;
      }
      if (11 === Str\search($h, $sessionCookiePrefix, 11)) {
        $sessionCookie = $h;
        if (11 !== Str\search($h, $sessionCookieWithId, 11)) {
          $otherCookies[] = $h;
        }
      } else {
        $otherCookies[] = $h;
      }
    }
    if (null === $sessionCookie) {
      return null;
    }

    header_remove('Set-Cookie');
    foreach ($otherCookies as $h) {
      header($h, false);
    }
    return $sessionCookie;
  }
}

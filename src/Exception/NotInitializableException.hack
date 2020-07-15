namespace Nazg\Session\Exception;

use namespace HH\Lib\Str;
use type Nazg\Session\{
  InitializePersistenceIdInterface,
  SessionPersistenceInterface,
};
use type RuntimeException;
use function get_class;

final class NotInitializableException extends RuntimeException implements ExceptionInterface {

  public static function invalidPersistence(
      SessionPersistenceInterface $persistence
  ): this {
    return new self(
      Str\format(
        "Persistence '%s' does not implement '%s'",
        get_class($persistence),
        InitializePersistenceIdInterface::class
      )
    );
  }
}

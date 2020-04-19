namespace Nazg\Session;

interface InitializePersistenceIdInterface {

  public function initializeId(
    SessionInterface $session
  ): SessionInterface;
}

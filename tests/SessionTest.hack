use type Nazg\Session\Session;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class SessionTest extends HackTest {

  public function testImplementsSessionInterface(): void {
    $session = new Session(dict[]);
    expect($session)->toBeInstanceOf(Session::class);
  }

  public function testIsNotChangedAtInstantiation(): void {
    $session = new Session(dict[]);
    expect($session->hasChanged())->toBeFalse();
  }

  public function testIsNotRegeneratedByDefault(): void {
    $session = new Session(dict[]);
    expect($session->isRegenerated())->toBeFalse();
  }

  public function testRegenerateProducesANewInstance(): void {
    $session = new Session(dict[]);
    $regenerated = $session->regenerate();
    expect($session)->toNotBeSame($regenerated);
    expect($regenerated->isRegenerated())->toBeTrue();
    expect($regenerated->hasChanged())->toBeTrue();
  }

  public function testSettingDataInSessionMakesItAccessible(): void {
    $session = new Session(dict[]);
    expect($session->has('foo'))->toBeFalse();
    $session->set<string>('foo', 'bar');
    expect($session->has('foo'))->toBeTrue();
    expect($session->get('foo'))->toBeSame('bar');
    expect($session->hasChanged())->toBeTrue();
    expect($session->toDict())->toBeSame(dict['foo' => 'bar']);
    $session->unset('foo');
    expect($session->has('foo'))->toBeFalse();
  }

  public function testClearingSessionRemovesAllData(): void {
    $original = dict[
      'foo' => 'bar',
      'baz' => 'bat',
    ];
    $session = new Session($original);
    expect($original)->toBeSame($session->toDict());
    $session->clear();
    expect($original)->toNotBeSame($session->toDict());
    expect(dict[])->toBeSame($session->toDict());
  }
}

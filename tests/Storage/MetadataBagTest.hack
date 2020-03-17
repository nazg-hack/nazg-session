
use type Nazg\Session\Metadata;
use type Nazg\Session\Storage\MetadataBag;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;
use function time;
use function sleep;

final class MetadataBagTest extends HackTest {

  <<__LateInit>> protected MetadataBag $bag;
  protected dict<Metadata, int> $dict = dict[];

  <<__Override>>
  public async function beforeEachTestAsync(): Awaitable<void> {
    $this->bag = new MetadataBag();
    $this->dict = dict[
      Metadata::CREATED => 1234567,
      Metadata::UPDATED => 12345678,
      Metadata::LIFETIME => 0
    ];
    $dict = $this->dict;
    $this->bag->initialize(inout $dict);
  }

  <<__Override>>
  public async function afterEachTestAsync(): Awaitable<void> {
    $this->dict = dict[];
  }

  public async function testInitialize(): Awaitable<void> {
    $sessionMetadata = dict[];
    $bag1 = new MetadataBag();
    $bag1->initialize(inout $sessionMetadata);
    expect($bag1->getCreated())
      ->toEqual($bag1->getLastUsed());
    expect(time())
      ->toBeGreaterThanOrEqualTo($bag1->getCreated());
    sleep(1);
    $bag2 = new MetadataBag();
    $bag2->initialize(inout $sessionMetadata);
    expect($bag1->getCreated())->toEqual($bag2->getCreated());
    expect($bag1->getLastUsed())->toEqual($bag2->getLastUsed());
    expect($bag2->getCreated())->toEqual($bag2->getLastUsed());

    sleep(1);
    $bag3 = new MetadataBag();
    $bag3->initialize(inout $sessionMetadata);
    expect($bag1->getCreated())->toEqual($bag3->getCreated());
    expect($bag3->getLastUsed())->toBeGreaterThan($bag2->getLastUsed());
    expect($bag3->getCreated())->toNotEqual($bag3->getLastUsed());
  }
  
  public async function testGetSetName(): Awaitable<void> {
    expect($this->bag->getName())->toEqual('__metadata');
    $this->bag->setName('foo');
    expect($this->bag->getName())->toEqual('foo');
  }

  public async function testGetStorageKey(): Awaitable<void> {
    expect($this->bag->getStorageKey())
      ->toEqual('_nazg_meta');
  }

  public async function testGetLifetime(): Awaitable<void> {
    $bag = new MetadataBag();
    $dict = dict[Metadata::CREATED => 1234567, Metadata::UPDATED => 12345678, Metadata::LIFETIME => 1000];
    $bag->initialize(inout $dict);
    expect($bag->getLifetime())->toEqual(1000);
  }

  public async function testGetCreated(): Awaitable<void> {
    expect($this->bag->getCreated())
      ->toEqual(1234567);
  }

  public async function testGetLastUsed(): Awaitable<void> {
    expect($this->bag->getLastUsed())
      ->toBeLessThanOrEqualTo(time());
  }

  public async function testSkipLastUsedUpdate(): Awaitable<void> {
    $bag = new MetadataBag('', 30);
    $timeStamp = time();
    $created = $timeStamp - 15;
    $sessionMetadata = dict[
      Metadata::CREATED => $created,
      Metadata::UPDATED => $created,
      Metadata::LIFETIME => 1000,
    ];
    $bag->initialize(inout $sessionMetadata);
    expect($sessionMetadata[Metadata::UPDATED])
      ->toEqual($created);
  }

  public async function testDoesNotSkipLastUsedUpdate(): Awaitable<void> {
    $bag = new MetadataBag('', 30);
    $timeStamp = time();
    $created = $timeStamp - 45;
    $sessionMetadata = dict[
      Metadata::CREATED => $created,
      Metadata::UPDATED => $created,
      Metadata::LIFETIME => 1000,
    ];
    $bag->initialize(inout $sessionMetadata);
    expect($sessionMetadata[Metadata::UPDATED])
      ->toEqual($timeStamp);
  }
}

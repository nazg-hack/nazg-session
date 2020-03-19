use type Nazg\Session\Attribute\NamespacedAttributeBag;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;

final class NamespacedAttributeBagTest extends HackTest {
  private dict<arraykey, mixed> $dict = dict[];
  <<__LateInit>> private NamespacedAttributeBag $bag;

  <<__Override>>
  public async function beforeEachTestAsync(): Awaitable<void> {
    $this->dict = dict[
      'hello' => 'world',
      'always' => 'be happy',
      'user.login' => 'drak',
      'csrf.token' => dict[
        'a' => '1234',
        'b' => '4321',
      ],
      'category' => dict[
        'fishing' => dict[
          'first' => 'cod',
          'second' => 'sole',
        ],
      ],
    ];
    $this->bag = new NamespacedAttributeBag('_nazg');
    $dict = $this->dict;
    $this->bag->initialize(inout $dict);
  }

  <<__Override>>
  public async function afterEachTestAsync(): Awaitable<void> {
    $this->dict = dict[];
  }

  public async function testInitialize(): Awaitable<void> {
    $bag = new NamespacedAttributeBag();
    $dict = $this->dict;
    $bag->initialize(inout $dict);
    expect($this->bag->all())->toEqual($this->dict);
    $array = dict['should' => 'not stick'];
    $bag->initialize(inout $array);
    expect($this->bag->all())->toEqual($this->dict);
  }

  public async function testGetStorageKey(): Awaitable<void>{
    expect($this->bag->getStorageKey())
      ->toEqual('_nazg');
    $attributeBag = new NamespacedAttributeBag('test');
    expect($attributeBag->getStorageKey())
      ->toEqual('test');
  }
}

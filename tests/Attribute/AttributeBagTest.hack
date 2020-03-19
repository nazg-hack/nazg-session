use type Nazg\Session\Attribute\AttributeBag;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;

final class AttributeBagTest extends HackTest {

  private dict<arraykey, mixed> $dict = dict[];
  <<__LateInit>> private AttributeBag $bag;

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
    $this->bag = new AttributeBag('_sf');
    $dict = $this->dict;
    $this->bag->initialize(inout $dict);
  }

  <<__Override>>
  public async function afterEachTestAsync(): Awaitable<void> {
    $this->dict = dict[];
  }

  public async function testInitialize(): Awaitable<void> {
    $bag = new AttributeBag();
    $dict = $this->dict;
    $bag->initialize(inout $dict);
    expect($bag->all())->toEqual($this->dict);
    $array = dict['should' => 'change'];
    $bag->initialize(inout $array);
    expect($bag->all())->toEqual($array);
  }

  public async function testGetStorageKey(): Awaitable<void> {
    expect($this->bag->getStorageKey())->toEqual('_sf');
    $attributeBag = new AttributeBag('test');
    expect($attributeBag->getStorageKey())->toEqual('test');
  }

  public async function testGetSetName(): Awaitable<void> {
    expect($this->bag->getName())->toEqual('attributes');
    $this->bag->setName('foo');
    expect($this->bag->getName())->toEqual('foo');
  }

  public function attributesProvider(): vec<vec<mixed>> {
    return vec[
      vec['hello', 'world', true],
      vec['always', 'be happy', true],
      vec['user.login', 'drak', true],
      vec['csrf.token', dict['a' => '1234', 'b' => '4321'], true],
      vec['category', dict['fishing' => dict['first' => 'cod', 'second' => 'sole']], true],
      vec['user2.login', null, false],
      vec['never', null, false],
      vec['bye', null, false],
      vec['bye/for/now', null, false],
    ];
  }

  <<DataProvider('attributesProvider')>>
  public function testHas(string $key, mixed $_, bool $exists): void {
    expect($this->bag->has($key))->toEqual($exists);
  }

  <<DataProvider('attributesProvider')>>
  public function testGet(string $key, mixed $value, bool $_): void {
    expect($this->bag->get($key))->toEqual($value);
  }

  <<DataProvider('attributesProvider')>>
  public function testSet(string $key, mixed $value, bool $_): void {
    $this->bag->set($key, $value);
    expect($this->bag->get($key))->toEqual($value);
  }

  public async function testAll(): Awaitable<void> {
    expect($this->dict)->toEqual($this->bag->all());
    $this->bag->set('hello', 'ytake');
    $array = $this->dict;
    $array['hello'] = 'ytake';
    expect($array)->toEqual($this->bag->all());
  }

  public async function testReplace(): Awaitable<void> {
    $array = dict[];
    $array['name'] = 'jack';
    $array['foo.bar'] = 'beep';
    $this->bag->replace($array);
    expect($array)->toEqual($this->bag->all());
    expect($this->bag->get('hello'))->toBeNull();
    expect($this->bag->get('always'))->toBeNull();
    expect($this->bag->get('user.login'))->toBeNull();
  }

  public async function testRemove(): Awaitable<void> {
    expect($this->bag->get('hello'))->toEqual('world');
    $this->bag->remove('hello');
    expect($this->bag->get('hello'))->toBeNull();
    expect($this->bag->get('always'))->toEqual('be happy');
    $this->bag->remove('always');
    expect($this->bag->get('always'))->toBeNull();
    expect($this->bag->get('user.login'))->toEqual('drak');
    $this->bag->remove('user.login');
    expect($this->bag->get('user.login'))->toBeNull();
  }

  public async function testClear(): Awaitable<void> {
    $this->bag->clear();
    expect($this->bag->all())->toEqual(dict[]);
  }

  public async function testGetIterator(): Awaitable<void> {
    $i = 0;
    $interation = $this->bag->getIterator();
    while ($interation->valid()) {
      expect($interation->current())
        ->toEqual($this->dict[$interation->key()]);
      $interation->next();
      ++$i;
    }
    expect(count($this->dict))->toEqual($i);
  }

  public async function testCount(): Awaitable<void> {
    expect($this->bag->count())->toEqual(count($this->dict));
  }
}

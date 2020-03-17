namespace Nazg\Session\Storage;

use type Nazg\Session\SessionBagInterface;
use type Nazg\Session\Metadata;

use function time;
use function array_key_exists;

class MetadataBag implements SessionBagInterface {

  private string $name = '__metadata';
  private int $lastUsed = 0;

  protected dict<Metadata, int> $meta = dict[
    Metadata::CREATED => 0,
    Metadata::UPDATED => 0,
    Metadata::LIFETIME => 0,
  ];

  public function __construct(
    private string $storageKey = '_nazg_meta',
    private int $updateThreshold = 0
  ) {}

  public function initialize(
    inout dict<Metadata, int> $dict
  ): void {
    $this->meta = $dict;
    if (array_key_exists(Metadata::CREATED, $dict)) {
        $this->lastUsed = $this->meta[Metadata::UPDATED];
        $timeStamp = time();
        if ($timeStamp - $dict[Metadata::UPDATED] >= $this->updateThreshold) {
          $this->meta[Metadata::UPDATED] = $timeStamp;
        }
        $dict = $this->meta;
        return;
    }
    $this->stampCreated();
    $dict = $this->meta;
  }

  public function getLifetime(): int {
    return $this->meta[Metadata::LIFETIME];
  }

  public function stampNew(int $lifetime = 0): void {
    $this->stampCreated($lifetime);
  }

  public function getStorageKey(): string {
    return $this->storageKey;
  }

  public function getCreated(): int {
    return $this->meta[Metadata::CREATED];
  }

  public function getLastUsed(): int {
    return $this->lastUsed;
  }

  public function clear(): void {}

  public function getName(): string {
    return $this->name;
  }

  public function setName(string $name): void {
    $this->name = $name;
  }

  private function stampCreated(
    int $lifetime = 0
  ): void {
    $timeStamp = time();
    $this->lastUsed = $timeStamp;
    $this->meta[Metadata::CREATED] = $timeStamp;
    $this->meta[Metadata::UPDATED] = $timeStamp;
    $this->meta[Metadata::LIFETIME] = $lifetime;
  }
}

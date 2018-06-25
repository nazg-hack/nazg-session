<?hh // strict

namespace Nazg\HSession;

interface SessionInterface {

  public function get(string $name, mixed $default = null): mixed;

  public function has(string $name) : bool;
  
  public function set(string $name, mixed $value) : void;

  public function unset(string $name) : void;

  public function clear() : void;
}

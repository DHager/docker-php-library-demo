<?php

namespace Technofovea\DockerPhpUnitDemo\Test;

use PHPUnit\Framework\TestCase;
use Technofovea\DockerPhpUnitDemo\Calc;

/**
 * A stupid-simple class to demonstrate basic unit-testing.
 * @package Technofovea\DockerPhpUnitDemo\Test
 */
class ExampleTest extends TestCase
{

    public function test()
    {
        $c = new Calc();
        $this->assertEquals(0, $c->add(0, 0));
        $this->assertEquals(11, $c->add(4, 7));
    }
}

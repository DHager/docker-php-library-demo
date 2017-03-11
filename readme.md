### Introduction

The basic ideas behind this project are to provide a demo and test-bed for:

* PHP 7.X
* Use [Composer](https://getcomposer.org) for PHP dependencies
* Provide a [Docker](https://www.docker.com/) container so that developers without PHP on their local machines can 
  contribute too.
* Use the Docker container to run [PHPUnit](https://phpunit.de/) tests and interactive debugging with 
  [Xdebug](https://xdebug.org/) 
* Work in a way that *can* be integrated with [PHPStorm](https://www.jetbrains.com/phpstorm/), but does not require it.

### Setting up Docker

Follow [Docker's own documentation](https://docs.docker.com/engine/getstarted/) for an installer and walk-through for setting up Docker on your computer.
 
## Working with this demo

If you want to use plain old command line tools, please consult `bin/readme.md` for instructions on how to use the bash scripts in that folder.
 
If you want to use PHPStorm's integrated tools to do things through your IDE, look in the `phpstorm/` folder for instructions.
 
To change PHP code and test-cases in the `src/` and `test/` folders, just make sure anything you add is compatible with PHP 7.1, and that you follow the [PSR-4 standard](http://www.php-fig.org/psr/psr-4/) for naming classes. You *can* use a different autooading technique, but you'll need to customize `composer.json`.

## Known issues

### Composer "corrupt"

If the image can't be built and you see something like this:

    2017-03-08 07:09:47 URL:https://getcomposer.org/installer [305728/305728] -> "composer-setup.php" [1]
    Installer corrupt
    Could not open input file: composer-setup.php
    
That means that the Composer team have updated their installer, and the local `docker/Dockerfile` is out of date. It
 needs to be edited to match the hash shown on [the Composer download page](https://getcomposer.org/download/). (And if 
 you've forked the original project, send a pull request!) 

### FAQ & Commentary

#### Why not use `docker-compose` ?

Perhaps in a future project, where it's a whole LAMP stack being tested. For now, it seems like it would only confuse
things to have an additional layer of orchestration.
   
### Introduction

The basic ideas behind this project are to provide a demo and test-bed for:

* PHP 7.X
* Use [Composer](https://getcomposer.org) for PHP dependencies
* Provide a [Docker](https://www.docker.com/) container so that developers without PHP on their local machines can 
  contribute too.
* Use the Docker container to run [PHPUnit](https://phpunit.de/) tests and interactive debugging with 
  [Xdebug](https://xdebug.org/) 
* Work in a way that *can* be integrated with [PHPStorm](https://www.jetbrains.com/phpstorm/), but does not require it.

## Working with this demo

### Setting up

First, you'll need to install Docker on your computer. Please consult 
[Docker's documentation](https://docs.docker.com/engine/getstarted/) for more information and walk-throughs.
 
Second, you'll need to open a terminal to run most of these commands. On a linux machine, it'll probably be just your
 regular command-line, but on Windows you may need to launch "Docker Quickstart Terminal".

Finally, run `docker/server-up.sh` will attempt to build the image,  start in in the background, and install composer 
dependencies.` This can be done without PHPStorm or an IDE. 

Take a quick look at `docker/config.sh`, you don't have to change anything immediately, but you might want to customize
things later, when the Docker-container is no longer running.

### Running tests

`docker/phpunit.sh` will run unit tests. Look inside the `build` folder for reports.

If PHPStorm is running, you should be able to enable debugging, the docker image will try to connect back outwards to
the host to give you information.

The file `phpunit.xml` contains additional settings, which are detailed in the 
[PHPUnit documentation](https://phpunit.de/manual/current/en/appendixes.configuration.html). 

### Configuring PHPStorm

The `$SERVER_NAME` variable in `docker/config.sh` will be the name that PHPStorm looks for in its own `Servers`
section. If your debugger is set to "listening", PHPStorm will probably prompt you for this with a message like:

    Can't find a source position. Server with name 'my-test-server' doesn't exist.
    [Configure servers]
    
You can click the `Configure servers` link to create an entry for `my-test-server`. Since it's actually a command-line
run, don't worry about IPs and ports, you can just use `127.0.0.1:80` as long as you pick `Xdebug` as the debugger.

Next, PHPStorm will probably say something like:

    Cannot find a local copy of the file on server /var/php/vendor/phpunit/phpunit/phpunit
    Local path is /var/php/vendor/phpunit/phpunit/phpunit
    [Click to set up path mappings]

All you need to do is enable a path-mapping where your project root lives "remotely" (in the Docker container) as 
`/var/php`

### Writing more PHP

All you need to do is put your new PHP into the `src/` and `test/` folders. Just make sure it's compatible with PHP 7.1,
and that you follow the [PSR-4 standard](http://www.php-fig.org/psr/psr-4/) for naming classes. You *can* use a
different autooading technique, but you'll need to customize `composer.json`.

### Tinkering with the docker environment

`docker/prompt.sh` can be used if you want to manually tinker, or to run commands like `composer update` when you've 
changed the dependencies.

### Cleaning up and shutting down

`docker/server-down.sh` will try to stop the docker container and remove it. The `build` and `vendor` folders can be
safely deleted, but it does no harm to leave them around.

## Known issues

### IP addresses

The `server-up.sh` script makes a little effort to guess the right IP address for the debugger to use to "call out" of
the docker container, but this process isn't very refined, and doens't work on Windows machines using Docker Quickstart 
Terminal. You may need to edit the `config.sh` script and set a value for `$HOST_IP`.

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
   
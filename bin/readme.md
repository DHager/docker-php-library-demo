## The purpose of these scripts

The bash scripts in this folder are to demonstrate how you can use Docker to manage a PHP project even if you don't have PHP installed or are on Windows. Please consider them an example of what can be done, rather than a finished product that you need to use or extend.

**Note:** If you wish to use a GUI, PHPStorm has its own separate way of handling a lot of the same tasks and responsibilities, so instead of these scripts you will want to follow the instructions inside the `phpstorm/` folder.

## Basic lifecycle

### Starting up

Assuming you already have Docker installed, you just need to open a terminal to run these commands. On a linux machine, it'll probably be just your regular command-line, but on Windows you may need to launch "Docker Quickstart Terminal".

Finally, run `bin/server-up.sh` will attempt to build the image,  start in in the background, and install composer dependencies.` This can be done without PHPStorm or an IDE. 

Take a quick look at `bin/config.sh`, you don't have to change anything immediately, but you might want to customize things later, when the Docker-container is no longer running.

### Running tests

`bin/phpunit.sh` will run unit tests. You can look inside the `build/` folder for HTML code-coverage reports.

The php environment in the docker image will automatically attempt to connect back outwards to the host to provide debugging-control.

The file `phpunit.xml` contains additional settings, which are detailed in the 
[PHPUnit documentation](https://phpunit.de/manual/current/en/appendixes.configuration.html). 

### Debugging in PHPStorm

**Note**: This section is only necessary if you are using `bin/phpunit.sh` to launch debugging. If you are launching it from the integrated debugging buttons in PHPStorm, please refer to the `phpstorm/` folder instead.

The `$SERVER_NAME` variable in `bin/config.sh` will be the name that PHPStorm looks for in its own `Servers`
section. If your debugger is set to "listening", PHPStorm will probably prompt you for this with a message like:

    Can't find a source position. Server with name 'my-test-server' doesn't exist.
    [Configure servers]
    
You can click the `Configure servers` link to create an entry for `my-test-server`. Since it's actually a command-line run, don't worry about IPs and ports, you can just use `127.0.0.1:80` as long as you pick `Xdebug` as the debugger-software.

Next, PHPStorm will probably say something like:

    Cannot find a local copy of the file on server /var/php/vendor/phpunit/phpunit/phpunit
    Local path is /var/php/vendor/phpunit/phpunit/phpunit
    [Click to set up path mappings]

All you need to do is enable a path-mapping where your project root lives "remotely" (in the Docker container) as `/var/php`


### Cleaning up and shutting down

`bin/server-down.sh` will try to stop the docker container and remove it. The `build/` and `vendor/` folders can be safely deleted, but it does no harm to leave them around.

## Other tasks

### Tinkering with the docker environment

`bin/prompt.sh` can be used if you want to manually tinker, or to run commands like `composer update` when you've changed the dependencies.

### Running other PHP tools 

For composer-distributed dev tools like `phpmd` or `phpcs`, the portable way is to:

1. Add them as dependencies in `composer.json`
2. Start a terminal with `bin/prompt.sh`
3. Use `composer update` to download them into the `vendor/` folder if you haven't already
4. Run the command that the tool provides inside `/var/php/vendor/bin/` 

There is another mechanism which exists mainly to support quirks of PHPStorm, which is to use fixed copies "baked in" to the image:

1. Start a terminal with `bin/prompt.sh`
2. Run the command that the tool provides inside `/var/phptool/vendor/bin/`

## Known issues with scripts

### IP addresses

The `bin/server-up.sh` script makes a little effort to guess the right IP address for the debugger to use to "call out" of the docker container, but this process isn't very refined. You can edit the `bin/config.sh` script and set a value for `$HOST_IP` if it doesn't seem to be working.

### Composer "corrupt"

If the image can't be built and you see something like this:

    2017-03-08 07:09:47 URL:https://getcomposer.org/installer [305728/305728] -> "composer-setup.php" [1]
    Installer corrupt
    Could not open input file: composer-setup.php
    
That means that the Composer team have updated their installer, and the local `docker/Dockerfile` is out of date. It needs to be edited to match the hash shown on [the Composer download page](https://getcomposer.org/download/). (And if you've forked the original project, send a pull request!) 
 
## Introduction

*[TODO:Screenshots]*

This guide will focus on configuring PHPStorm (version 2016.3.2 or above) to:

* Control the lifecycle of this project's Docker container(s)
* Run PHPUnit tests and display results in a GUI
* Debug code and tests
* Collect and display code-coverage information
 
Please note that these tasks are separate from the scripts in `bin/` and represent a separate control system around the same underlying Docker image.

## Machine-level docker integration

The steps in this section are only needed once for a particular developer machine.

### Check that plugins are present

This section assumes the following PHPStorm plugins are installed and enabled:

* Docker
* PHP Docker
* PHP Remote Interpreter

### Enable web-control 

If you are on a Linux machine, you may first need to configure your `dockerd` background process so that it exposes an HTTP control interface. By default, it only provides a socket-file which PHPStorm cannot use.
 
These steps will vary based on your distro, but in Ubuntu, you'll want to edit `/etc/defaults/docker` to add arguments for `dockerd`.
    
    DOCKER_OPTS="-H tcp://127.0.0.1:2376 -H unix:///var/run/docker.sock"
    
Finally, restart `dockerd` with the new settings, such as by `sudo service docker restart` .    

## Tell PHPStorm how to talk to `dockerd`


In PHPStorm, open the `File > Settings` dialog, and navigate to `Build, Execution, Deployment > Docker`. Press the green `+` icon:

* Name: Choose anything you want, such as `My Local Docker`
* API URL: Leave it at the default: `http://127.0.0.1:2376`
* Docker Compose executable: Try `/usr/local/bin/docker-compose`

If you're not sure where docker-compose lives, you can try opening a terminal and typing `which docker-compose`. 


### Per-project configuration

## Creating the image

Go to `Run > Edit Configurations` dialog, and click the green `+` icon and choose "Docker Deployment". Give it a name like `Test Server`, and fill it in with values for:

* Server: Pick the name you chose before, e.g. `My Local Docker`
* Deployment: `docker/Dockerfile`
* Image tag: Choose a name, e.g. `technofovea/test-image:latest`
* Container name: You can leave this blank if you wish.
* Open Browser: Ignore this section, this particular project is command-line only.

Next, click on the "Container" tab...

* Add one entry under "Volume bindings", mapping `/var/php` to the project directory. (The folder that contains `composer.json`)
 
At this point, you can try running your `Test Server`, which should cause PHPStorm display a long screen of progress text that resembles:

    Deploying '<unknown>  Dockerfile: docker/Dockerfile'...
    Building image...
    Step 1 : FROM php:7.1-cli
    
    [...Lots of content omitted...]
    
    Creating container...
    Container Id: e1de3a8e62e13e2cbad6bfd2797b067b7399cfaab899941d264939e432a48820
    Attaching to container ''...
    Starting container ''
    '<unknown>  Dockerfile: docker/Dockerfile' has been deployed successfully.


## Installing/updating composer libraries

With the image you created in the previous step, there's an "Attached console" tab. You will want to run the command:

`composer install`

This will modify the content of `/var/php/vendor`, which will create a `vendor` folder in your project. Generally speaking, changes to other paths inside the container will not be permanently saved.

## Configuring a remote PHP interpreter

In PHPStorm, open the `File > Settings` dialog, and navigate to `Languages & Frameworks > PHP`. For this particular project, make sure the PHP Language Level is 7.1. On the line labeled "CLI Interpreter", click the  button marked `...` to open up a new dialog. 

Click the green `+` button in the corner to add a new "Remote...", and choose the "Docker" radio-button. This will allow you to fill in:

* Server: The docker installation you chose earlier, e.g. `My Local Docker`
* Image name: The image you chose earlier, e.g. `technofovea/test-image:latest`
* PHP Interpreter path: `php`

Click OK to dismiss the dialog and click OK again to return to the screen where you had to choose the "CLI Interpreter", which should now show something like `Remote PHP 7.1`. 

In an earlier step, we configured `/var/php` on the docker container to contain our project. However, PHPStorm uses its own default of `/opt/project` Let's fix that by going to the line labeled "Docker Container" and click the `...` button, and then change `/opt/project` to `/var/php`.

## Configuring the PHPUnit environment  

 
In PHPStorm, open the `File > Settings` dialog, and navigate to `Languages & Frameworks > PHP >  PHPUnit`. There will already be an entry called "Local", but this is a default that you should ignore. Instead, click the green `+` button and choose "By Remote Interpreter". Then choose the interpreter we set up in the previous step, `Remote PHP 7.1`, and click OK.

Choose the "Use Composer autoloader" radio-button, and enter in:

* Path to script: `/var/php/vendor/autoload.php`.
* Default configuration file:  `/var/php/phpunit.xml`

## Create a PHPUnit run to hit all tests

Go to `Run > Edit Configurations` dialog, and click the green `+` icon and choose "PHPUnit". Give it a name like `"Run all tests", and choose the radio-button "Defined in configuration file". Click OK.

Now just press the green "Play" arrow at the top of the screen to run the tests. PHPStorm should pop up a text area showing something like: 


    docker://technofovea/test-image:latest/php /var/php/vendor/phpunit/phpunit/phpunit --configuration /var/php/phpunit.xml --teamcity
    Testing started at 8:44 PM ...
    PHPUnit 6.0.8 by Sebastian Bergmann and contributors.        
    
    Time: 182 ms, Memory: 4.00MB
    
    OK (1 test, 2 assertions)
    
    Generating code coverage report in Clover XML format ... done
    
    Generating code coverage report in HTML format ... done
    
    Process finished with exit code 0
  
If you want to debug or do code-coverage, there are a additional buttons to the right of the "Play" button. 
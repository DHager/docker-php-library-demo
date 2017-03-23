## Introduction

*[TODO:Screenshots]*

This guide will focus on configuring PHPStorm (version 2016.3.2 or above) to:

* Control the lifecycle of this project's Docker container(s)
* Run PHPUnit tests and display results in a GUI
* Debug code and tests
* Collect and display code-coverage information
 
Please note that these tasks are separate from the scripts in `bin/` and represent a separate control system around the same underlying Docker image. Some instructions will differ for Linux and Windows.

## Host-machine configuration

The steps in this section are only needed once for a particular developer machine.

### Check that PHPStorm plugins are present

This section assumes the following PHPStorm plugins are installed and enabled:

* Docker
* PHP Docker
* PHP Remote Interpreter

### Enable web-control 

#### Linux

PHPStorm uses the HTTP(S) API to control Docker, but some Linux installations may only enable the file-socket by default. In this case, you may need to change the settings for the `dockerd` daemon and restart it. These steps will vary based on your distro.
 

##### Suggested for Ubuntu 14

Edit the `/etc/defaults/docker` file to add arguments for `dockerd`:
    
    DOCKER_OPTS="-H tcp://127.0.0.1:2376 -H unix:///var/run/docker.sock"
    
Then restart `dockerd` with the new settings, such as by `sudo service docker restart` .

##### Suggested for Ubuntu 16

Create or modify the file `/etc/systemd/system/docker.service.d/custom.conf` to contain:
    
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd -H tcp://127.0.0.1:2376 -H unix:///var/run/docker.sock
    
The reload configuration and restart docker with the commands

    sudo systemctl daemon-reload
    sudo systemctl restart docker
    
#### Windows

The web API is enabled by default in a Windows installation, since unix file-sockets are obviously not available.

### Tell PHPStorm how to talk to `dockerd`

#### Linux

In PHPStorm, open the `File > Settings` dialog, and navigate to `Build, Execution, Deployment > Docker`. Press the green `+` icon:

* Name: Choose anything you want, such as `My Local Docker`
* API URL: Leave it at the default. `http://127.0.0.1:2376`
* Docker Compose executable: Try `/usr/local/bin/docker-compose`

If you're not sure where docker-compose lives, you can try opening a terminal and typing `which docker-compose`. There should usually be no need for docker-machine settings.
 
#### Windows

In PHPStorm, open the `File > Settings` dialog, and navigate to `Build, Execution, Deployment > Docker`. Press the green `+` icon:

* Name: Choose anything you want, such as `My Local Docker`
* API URL: Leave it at the default. `https://192.168.99.100:2376`
* Docker Compose executable: Try `C:\Program Files\Docker Toolbox\docker-compose.exe`

Since the control URL is https, you will also need credentials. 

* Tick "Import Credentials from Docker Machine"
* Enter in the "Docker Machine executable" path e.g. `C:\Program Files\Docker Toolbox\docker-machine.exe`. Copy-pasting alone doesn't always work, you may need to also click the `...` button and hit OK inside the file-finder dialog in order to make PHPStorm react.
* This should automatically fill the "Certificates Folder" path.

## Per-project configuration

### Creating the image

Go to `Run > Edit Configurations` dialog, and click the green `+` icon and choose "Docker Deployment". Give it a name like `Test Server`, and fill it in with values for:

* Server: Pick the name you chose before, e.g. `My Local Docker`
* Deployment: `docker/Dockerfile`
* Image tag: Choose a name, e.g. `technofovea/test-image:latest`
* Container name: You can leave this blank if you wish.
* Open Browser: Ignore this section, this particular project is command-line only.

Next, click on the "Container" tab, and add one entry under "Volume bindings", mapping `/var/php` to the project directory.
 
**Windows-specific instructions**

* **Warning:** If you click to browse to the project directory, you may encounter the error: "VirtualBox shared folders should be configured in the Docker cloud settings". This seems to be spurious and can be ignored, but it does stop you from "exploring" your way to the folder. 
* Instead, enter the path manually in a form understood by [MinGW](http://www.mingw.org/wiki/Posix_path_conversion). For example, the path `c:/foo/bar` should be entered as `/c/foo/bar`.

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


### Installing/updating composer libraries

With the image you created in the previous step, there's an "Attached console" tab. You will want to run the command:

`composer install`

This will modify the content of `/var/php/vendor`, which will create a `vendor` folder in your project. Generally speaking, changes to other paths inside the container will not be permanently saved.

While you work on a project, you may need to return to this interface (or re-launch the container) in order to run other commands such as `composer update`. 

As of March 2017, PHPStorm's plug-in for Composer does **not** yet support remote-interpreters. Unfortunately this means many GUI "Composer" options will not work, and the `composer.json` file isn't as convenient to edit. 

### Configuring a remote PHP interpreter

In PHPStorm, open the `File > Settings` dialog, and navigate to `Languages & Frameworks > PHP`. For this particular project, make sure the PHP Language Level is 7.1. On the line labeled "CLI Interpreter", click the  button marked `...` to open up a new dialog. 

Click the green `+` button in the corner to add a new "Remote...", and choose the "Docker" radio-button. This will allow you to fill in:

* Server: The docker installation you chose earlier, e.g. `My Local Docker`
* Image name: The image you chose earlier, e.g. `technofovea/test-image:latest`
* PHP Interpreter path: `php`

Click OK to dismiss the dialog, and now enter a unique name for this image's interpreter such as `test-image Remote 7.1`. Click OK again. 

In an earlier step, we configured `/var/php` on the docker container to contain our project. However, PHPStorm uses its own default of `/opt/project` Let's fix that by going to the line labeled "Docker Container" and click the `...` button, and then change `/opt/project` to `/var/php`.

### Configuring the PHPUnit environment  

 
In PHPStorm, open the `File > Settings` dialog, and navigate to `Languages & Frameworks > PHP >  PHPUnit`. There will already be an entry called "Local", but this is a default that you should ignore. Instead, click the green `+` button and choose "By Remote Interpreter". Then choose the interpreter we set up in the previous step, `test-image Remote 7.1`, and click OK.

Choose the "Use Composer autoloader" radio-button, and enter in:

* Path to script: `/var/php/vendor/autoload.php`.
* Default configuration file:  `/var/php/phpunit.xml`

#### Additional Windows instructions

Due to the Windows/Linux path differences, you may need to add an additional Path Mapping here in order for debugging breakpoints to work. On the "Path mappings" line, click on the `...` button to open a dialog. You should already see one row underneath a heading titled "From Docker volumes". If that row says something like `/c/some/path`, you should add a new row that is identical except for the beginning, ex: `c:/some/path`. 
 

## Create a PHPUnit run to hit all tests

Go to `Run > Edit Configurations` dialog, and click the green `+` icon and choose "PHPUnit". Give it a name like "Run all tests", and choose the radio-button "Defined in configuration file". Click OK.

Now just press the green "Play" arrow at the top of the screen to run the tests. PHPStorm should pop up a text area showing something like: 


    docker://technofovea/test-image:latest/php /var/php/vendor/phpunit/phpunit/phpunit --configuration /var/php/phpunit.xml --teamcity
    Testing started at 8:44 PM ...
    PHPUnit 6.0.8 by Sebastian Bergmann and contributors.        
    
    Time: 182 ms, Memory: 4.00MB
    
    OK (1 test, 2 assertions)        
    
    Generating code coverage report in HTML format ... done
    
    Process finished with exit code 0
  
If you want to debug or do code-coverage, there are a additional buttons to the right of the "Play" button. 

## Other tools

### Inspections

Currently PHPStorm 2016.3.3 will not mount any of our previously-defined volume-mappings when it runs `phpcs` or `phpmd`. As a workaround, the tools are baked into the docker image under `/var/phptools/`. You can change which versions are installed by editing `docker/inspections-composer.json` and recreating the image.

To enable Mess Detector (`phpmd`)

1. Go to `Files > Settings` dialog
2. Navigate to `Languages & Frameworks > PHP > Mess Detector`
3. Under Configuration, pick `Default Project Interpreter`, and then the `...` button. 
4. You should see "Local" and not much else. Hit `+` to add a new entry, picking the `test-image Remote 7.1` we created in previous steps.
5. Enter a path of `/var/phptools/vendor/bin/phpmd`, click "Validate" to check, and then you're done.

To enable Code Sniffer (`phpcs`)

1. Go to `Files > Settings` dialog
2. Navigate to `Languages & Frameworks > PHP > Code Sniffer`
3. Under Configuration, pick `Default Project Interpreter`, and then the `...` button. 
4. You should see "Local" and not much else. Hit `+` to add a new entry, picking the `test-image Remote 7.1` we created in previous steps.
5. Enter a path of `/var/phptools/vendor/bin/phpcs`, click "Validate" to check, and then you're done.

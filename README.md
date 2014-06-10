try-haxe
========

The try-haxe project is a browser-based IDE for testing Haxe code.  It provides a
quick and easy environment for playing with the Haxe language and compiles to
JavaScript or Flash, instantly viewable in the browser.  It also allows saving
and sharing of programs with the auto-generated hyperlink hash-codes.

The official project is hosted at [try.haxe.org](http://try.haxe.org).

Technical notes:
----------------
The try-haxe project is written in Haxe, with part of the application compiling to
JavaScript for use on the client, and part of the application compiling to PHP as
a backend service.  The backend PHP service provides server-side compilation of
programs as well as language auto-complete results.

Run your own instance:
----------------------

You can run the try-haxe project on a server with Apache, PHP, and Haxe installed.  Some commands may be distribution-specific (location of web server root, etc) -- the below works on Ubuntu.

Clone the repo and initialize the submodules:

    git clone https://github.com/clemos/try-haxe.git
    cd try-haxe
    git submodule init
    git submodule update

You may need to update the location of the haxe compiler executable in the `Compiler.hx` source file, line 26.  You can specify a full path to your haxe compiler, such as:

    public static var haxePath = "/opt/haxe-3.1.3/haxe";

Build the try-haxe compiler and app:

    haxe build.hxml

Link (or copy) this project directory to a location served by Apache (or other PHP-enabled web server):

    sudo ln -s `pwd` /var/www/

The above creates a `/var/www/try-haxe` symlinked to your git repo.

Create the tmp directory (where web-based projects will be created and saved):

    mkdir tmp
    chmod a+rw tmp

Ensure Apache has mod_rewrite enabled:

    sudo a2enmod rewrite

Edit the apache configuration file and add the `/var/www/try-haxe` location with `AllowOverrides All` directive (so it can use the .htaccess file):

    sudo emacs /etc/apache2/sites-available/default

Add a `<Directory>` entry like so:

    # Required by try-haxe
    <Directory /var/www/try-haxe>
      Options FollowSymLinks
      AllowOverride All
    </Directory>

Restart the apache server:

    sudo /etc/init.d/apache2 restart

Navigate to your server (by name, ip address, or localhost) and enjoy try-haxe!  [http://localhost/try-haxe/](http://localhost/try-haxe/)

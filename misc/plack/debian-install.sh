sudo apt-get install libplack-perl libcgi-emulate-psgi-perl libfile-pushd-perl libtext-microtemplate-perl libclass-method-modifiers-perl \
libcss-minifier-xs-perl libjavascript-minifier-xs-perl 

sudo dh-make-perl --install --cpan CGI::Compile
sudo dh-make-perl --install --cpan Module::Versions
sudo dh-make-perl --install --cpan Plack::Middleware::Debug
sudo dh-make-perl --install --cpan Plack::Middleware::Static::Minifier
sudo dh-make-perl --build --cpan Plack::Middleware::Debug::DBIProfile


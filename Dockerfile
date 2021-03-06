FROM debian:buster
MAINTAINER Lukas Plevac

#add system
ADD bin/. /var/www/data
ADD data/. /data

RUN apt-get update && \
    apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    apache2 php php-auth-sasl php-common php-curl php-mail php-mbstring php-mysql \
    php-net-smtp php-net-socket php-pear php-xml php-fpm php-json php-opcache \
    php-readline libapache2-mod-php php-zip curl nodejs && \
    curl -L https://npmjs.org/install.sh | sh && \
    #enable mods
    a2enmod php7.3 && \
    a2enmod rewrite && \
    #copy node_modules to lib
    cp -r /var/www/data/node_modules/ /var/www/data/lib/ && \
    #chown dirs
    chown -R www-data /var/www/data && \
    chown -R www-data /data && \
    #install packages for compile fronted
    cd /var/www/data && \
    npm install gulp-cli@2.2.0 && \
    npm install --save-dev gulp@3.9.1 && \
    npm install gulp-uglify@3.0.2 && \
    npm install gulp-clean-css@4.2.0 && \
    npm install gulp-angular-templatecache@2.2.7 && \
    npm install gulp-eslint@6.0.0 && \
    #compile fronted
    gulp build || node node_modules/gulp/bin/gulp.js build && \
    #uninstall packages for compile fronted
    npm uninstall gulp-cli && \
    npm uninstall gulp && \
    npm uninstall gulp-uglify && \
    npm uninstall gulp-clean-css && \
    npm uninstall gulp-angular-templatecache && \
    npm uninstall gulp-eslint && \
    apt-get -y purge nodejs && apt-get -y autoremove && apt-get clean && \
    #remove file for compilation
    rm -rf node_modules/ && \
    rm -rf src/ && \
    rm -f package-lock.json && \
    rm -f gulpfile.js && \
    rm -f package.json && \
    #remove all node and npm forders
    rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp /opt/local/bin/node /opt/local/include/node /opt/local/lib/node_modules && \
    rm -rf /usr/local/lib/node* && \
    rm -rf /usr/local/include/node* && \
    rm -rf /usr/local/bin/node*

#add apache config
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

#hide server info
RUN echo 'ServerSignature Off' >> /etc/apache2/apache2.conf && \
    echo 'ServerTokens Prod' >> /etc/apache2/apache2.conf && sed -e "s/expose_php = On/expose_php = Off/" /etc/php/7.3/apache2/php.ini > /etc/php/7.3/apache2/php.ini


#set volume
VOLUME /data/

#ENTRYPOINT
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

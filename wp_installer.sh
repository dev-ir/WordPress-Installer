## wordpress installation function
## https://ubuntu.com/tutorials/install-and-configure-wordpress#6-configure-wordpress-to-connect-to-the-database
## special tnk astro

install_wordpress(){
    
    # Update all package
    sudo apt update -y
    sudo apt upgrade -y
    
    # Install Dependencies
    sudo apt install apache2  -y
    sudo apt install ghostscript  -y
    sudo libapache2-mod-apt install php  -y
    sudo mysql-server -y
    sudo apt install php -y
    sudo apt install php-bcmath -y
    sudo apt install php-curl -y
    sudo apt install php-imagick -y
    sudo apt install php-intl -y
    sudo apt install php-json -y
    sudo apt install php-mbstring -y
    sudo apt install php-mysql -y
    sudo apt install php-xml -y
    sudo apt install php-zip -y
    
    # Install WordPress
    sudo mkdir -p /srv/www
    sudo chown www-data: /srv/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
    
    # Set Define
    FILE_PATH="/etc/apache2/sites-available/wordpress.conf"
    FILE_CONTENT="<VirtualHost *:80>\n\tDocumentRoot /srv/www/wordpress\n\t<Directory /srv/www/wordpress>\n\t\tOptions FollowSymLinks\n\t\tAllowOverride Limit Options FileInfo\n\t\tDirectoryIndex index.php\n\t\tRequire all granted\n\t</Directory>\n\t<Directory /srv/www/wordpress/wp-content>\n\t\tOptions FollowSymLinks\n\t\tRequire all granted\n\t</Directory>\n</VirtualHost>"
    echo -e $FILE_CONTENT | sudo tee $FILE_PATH > /dev/null
    sudo a2ensite wordpress.conf
    
    #Enable the site with:
    sudo a2ensite wordpress
    
    #Enable URL rewriting with:
    sudo a2enmod rewrite
    
    #Disable the default “It Works” site with:
    sudo a2dissite 000-default
    # Reload Apache
    sudo service apache2 reload
    sudo systemctl restart apache2
    
    # Configure database
    read -sp "Enter MySQL root password: " mysql_password
    read -s -p "Enter your WordPress password: " wordpress_password
    
    # Run the SQL commands
    echo "CREATE DATABASE wordpress;" | sudo mysql -u root -p$mysql_password
    echo "CREATE USER wordpress@localhost IDENTIFIED BY '$wordpress_password';" | sudo mysql -u root -p$mysql_password
    echo "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;" | sudo mysql -u root -p$mysql_password
    echo "FLUSH PRIVILEGES;" | sudo mysql -u root -p$mysql_password
    echo "quit" | sudo mysql -u root -p$mysql_password
    
    # simple copy for wp-config.php
    sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
    
    # Define the database settings
    DB_NAME=wordpress
    DB_USER=wordpress
    DB_PASSWORD="$wordpress_password"
    DB_HOST="localhost"
    DB_CHARSET="utf8"
    DB_COLLATE=""
    
    # Get the secret keys
    SECRET_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    
    # Define the table prefix and debugging mode
    TABLE_PREFIX="wp_"
    
    # Define the file path
    FILE_PATH="/srv/www/wordpress/wp-config.php"
    
    # Create the wp-config.php file
    echo "<?php

            define( 'DB_NAME', '$DB_NAME' );

            define( 'DB_USER', '$DB_USER' );

            define( 'DB_PASSWORD', '$DB_PASSWORD' );

            define( 'DB_HOST', '$DB_HOST' );

            define( 'DB_CHARSET', '$DB_CHARSET' );

            define( 'DB_COLLATE', '$DB_COLLATE' );

            $SECRET_KEYS

            \$table_prefix = '$TABLE_PREFIX';

            define( 'WP_DEBUG', 'false' );

            if ( ! defined( 'ABSPATH' ) ) {
                define( 'ABSPATH', __DIR__ . '/' );
            }
            require_once ABSPATH . 'wp-settings.php';
    " > "$FILE_PATH"
    
    sleep 2
    echo -e "Now, you need to open your IP and enter the required information to complete the setup"
    
}

install_wordpress
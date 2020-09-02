#! /bin/bash

# VARs
installDir="/opt/motma/"

if [[ "$2" == 'webservice' ]]; then
  rsync -av --delete -e ssh var/www/webservice root@$1:/var/www/html/
  
  # Set correct permissions for CentOS
  ssh root@$1 /bin/bash << EOF
        chown -R apache.apache /var/www/html/webservice
        echo "Installation finished"
EOF
else
    # Copy files to given GW Server
    echo "rsync files to "$1
    rsync -a --delete -e ssh bin root@$1:$installDir
    rsync -a --delete -e ssh etc root@$1:$installDir
    rsync -a --delete -e ssh init.d root@$1:$installDir
    rsync -a --delete -e ssh data root@$1:$installDir
    rsync -a --delete -e ssh lib root@$1:$installDir
    rsync -a --delete -e ssh var root@$1:$installDir
    # rsync -a --delete -e ssh Makefile.PL root@$1:$installDir

    # Install and extract needed files on the GW Server
    ssh root@$1 /bin/bash << EOF
        chown -R nagios.nagios $installDir
        chmod +x $installDir/bin/runLin.pl
        chmod +x $installDir/init.d/motma

        if [[ "$2" == 'restore' ]]; then
            export PGPASSWORD='gwos'
            /usr/local/groundwork/postgresql/bin/psql -d helpdesk -f $installDir/data/postgresql/database.sql
            echo "Database restored"
        fi

        echo "Installation finished"
EOF
fi

#!/bin/sh

# Allow only root execution
if [ `id|sed -e s/uid=//g -e s/\(.*//g` -ne 0 ]; then
    echo "This script requires root privileges"
    exit 1
fi


# Restoring SELinux
# This function is to be called via a trap no matter how we exit,
# with that trap to be set once we know the previous state to
# restore to and just before we modify that state, to guarantee
# we always put things back exactly the way we found them.
restore_selinux() {
    if [ -f "/usr/sbin/getenforce" ] && [ `id -u` = 0 ] ; then
        /usr/sbin/setenforce $selinux_status 2> /dev/null
    fi
}

# Disabling SELinux if enabled
if [ -f "/usr/sbin/getenforce" ] && [ `id -u` = 0 ] ; then
    selinux_status=`/usr/sbin/getenforce`
    trap "restore_selinux" EXIT
    /usr/sbin/setenforce 0 2> /dev/null
fi

INSTALLDIR=/usr/local/groundwork

if [ -r "$INSTALLDIR/scripts/setenv.sh" ]; then
. "$INSTALLDIR/scripts/setenv.sh"
fi

ERROR=0
POSTGRESQL_SCRIPT=$INSTALLDIR/postgresql/scripts/ctl.sh
APACHE_SCRIPT=$INSTALLDIR/apache2/scripts/ctl.sh
NAGIOS_SCRIPT=$INSTALLDIR/nagios/scripts/ctl.sh
SYSLOG_SCRIPT=$INSTALLDIR/common/scripts/ctl-syslog-ng.sh
GWSERVICES_SCRIPT=$INSTALLDIR/core/services/gwservices
SNMPTT_SCRIPT=$INSTALLDIR/common/scripts/ctl-snmptt.sh
SNMPTRAPD_SCRIPT=$INSTALLDIR/common/scripts/ctl-snmptrapd.sh
NTOP_SCRIPT=$INSTALLDIR/common/scripts/ctl-nms-ntop.sh
NOMA_SCRIPT=$INSTALLDIR/noma/scripts/ctl.sh
MOTMA_SCRIPT=$INSTALLDIR/motma/init.d/motma

help() {
        echo "usage: $0 help"
        echo "       $0 (start|stop|restart|status)"
        if test -x $POSTGRESQL_SCRIPT; then
            echo "       $0 (start|stop|restart|status) postgresql"
        fi
        if test -x $APACHE_SCRIPT; then
            echo "       $0 (start|stop|restart|status) apache"
        fi
        if test -x $NAGIOS_SCRIPT; then
            echo "       $0 (start|stop|restart|status) nagios"
        fi
        if test -x $SYSLOG_SCRIPT; then
            echo "       $0 (start|stop|restart|status) syslog-ng"
        fi
        if test -x $GWSERVICES_SCRIPT; then
            echo "       $0 (start|stop|restart|status) gwservices"
        fi
        if test -x $SNMPTT_SCRIPT; then
            echo "       $0 (start|stop|restart|status) snmptt"
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            echo "       $0 (start|stop|restart|status) snmptrapd"
        fi
        if test -x $NTOP_SCRIPT; then
            echo "       $0 (start|stop|restart|status) ntop"
        fi
        if test -x $NOMA_SCRIPT; then
            echo "       $0 (start|stop|restart|status) noma"
        fi
        if test -x $MOTMA_SCRIPT; then
            echo "       $0 (start|stop|restart|status) motma"
        fi
        cat <<EOF

help       - this screen
start      - start the service(s)
stop       - stop  the service(s)
restart    - restart or start the service(s)
status     - show the status of the service(s)

EOF
}


if [ "x$1" = "xhelp" ] || [ "x$1" = "x-help" ] || [ "x$1" = "x--help" ] || [ "x$1" = "x" ]; then
    help
elif [ "x$1" = "xstart" ]; then

    if [ "x$2" = "xpostgresql" ]; then
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT start
            POSTGRESQL_ERROR=$?
        fi
    elif [ "x$2" = "xapache" ]; then
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT start
            APACHE_ERROR=$?
        fi
    elif [ "x$2" = "xnagios" ]; then
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT start
            NAGIOS_ERROR=$?
        fi
    elif [ "x$2" = "xsyslog-ng" ]; then
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT start
            SYSLOG_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptt" ]; then
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT start
            SNMPTT_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptrapd" ]; then
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT start
            SNMPTRAPD_ERROR=$?
        fi
    elif [ "x$2" = "xntop" ]; then
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT start
            NTOP_ERROR=$?
        fi
    elif [ "x$2" = "xgwservices" ]; then
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT start
            GWSERVICES_ERROR=$?
        fi
    elif [ "x$2" = "xnoma" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT start
            NOMA_ERROR=$?
        fi
    elif [ "x$2" = "xmotma" ]; then
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT start
            MOTMA_ERROR=$?
        fi

    elif [ "x$2" = "x" ]; then
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT start
            POSTGRESQL_ERROR=$?
            sleep 5
        fi
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT start
            APACHE_ERROR=$?
        fi
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT start
            NAGIOS_ERROR=$?
        fi
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT start
            SYSLOG_ERROR=$?
        fi
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT start
            SNMPTT_ERROR=$?
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT start
            SNMPTRAPD_ERROR=$?
        fi
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT start
            NTOP_ERROR=$?
        fi
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT start
            GWSERVICES_ERROR=$?
        fi
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT start
            NOMA_ERROR=$?
        fi
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT start
            MOTMA_ERROR=$?
        fi

    else
        ERROR=1
        echo "Invalid argument: $2"
        help
    fi


elif [ "x$1" = "xstop" ]; then

    if [ "x$2" = "xpostgresql" ]; then
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT stop
            POSTGRESQL_ERROR=$?
            sleep 2
        fi
    elif [ "x$2" = "xapache" ]; then
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT stop
            APACHE_ERROR=$?
        fi
    elif [ "x$2" = "xnagios" ]; then
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT stop
            NAGIOS_ERROR=$?
        fi
    elif [ "x$2" = "xntop" ]; then
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT stop
            NTOP_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptrapd" ]; then
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT stop
            SNMPTRAPD_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptt" ]; then
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT stop
            SNMPTT_ERROR=$?
        fi
    elif [ "x$2" = "xsyslog-ng" ]; then
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT stop
            SYSLOG_ERROR=$?
        fi
    elif [ "x$2" = "xnoma" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT stop
            NOMA_ERROR=$?
        fi
    elif [ "x$2" = "xmotma" ]; then
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT stop
            MOTMA_ERROR=$?
        fi
    elif [ "x$2" = "xgwservices" ]; then
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT stop
            GWSERVICES_ERROR=$?
        fi

    elif [ "x$2" = "x" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT stop
            NOMA_ERROR=$?
        fi
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT stop
            MOTMA_ERROR=$?
        fi
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT stop
            GWSERVICES_ERROR=$?
        fi
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT stop
            NTOP_ERROR=$?
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT stop
            SNMPTRAPD_ERROR=$?
        fi
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT stop
            SNMPTT_ERROR=$?
        fi
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT stop
            SYSLOG_ERROR=$?
        fi
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT stop
            NAGIOS_ERROR=$?
        fi
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT stop
            APACHE_ERROR=$?
        fi
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT stop
            POSTGRESQL_ERROR=$?
        fi

    else
        ERROR=1
        echo "Invalid argument: $2"
        help
    fi

elif [ "x$1" = "xrestart" ]; then

    if [ "x$2" = "xpostgresql" ]; then
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT stop
            sleep 2
            $POSTGRESQL_SCRIPT start
            POSTGRESQL_ERROR=$?
        fi
    elif [ "x$2" = "xapache" ]; then
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT stop
            sleep 2
            $APACHE_SCRIPT start
            APACHE_ERROR=$?
        fi
    elif [ "x$2" = "xnagios" ]; then
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT stop
            sleep 2
            $NAGIOS_SCRIPT start
            NAGIOS_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptt" ]; then
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT stop
            sleep 2
            $SNMPTT_SCRIPT start
            SNMPTT_ERROR=$?
        fi
    elif [ "x$2" = "xsnmptrapd" ]; then
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT stop
            sleep 2
            $SNMPTRAPD_SCRIPT start
            SNMPTRAPD_ERROR=$?
        fi
    elif [ "x$2" = "xntop" ]; then
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT stop
            sleep 2
            $NTOP_SCRIPT start
            NTOP_ERROR=$?
        fi
    elif [ "x$2" = "xsyslog-ng" ]; then
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT stop
            sleep 2
            $SYSLOG_SCRIPT start
            SYSLOG_ERROR=$?
        fi
    elif [ "x$2" = "xgwservices" ]; then
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT stop
            sleep 2
            $GWSERVICES_SCRIPT start
            GWSERVICES_ERROR=$?
        fi
    elif [ "x$2" = "xnoma" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT stop
            sleep 2
            $NOMA_SCRIPT start
            NOMA_ERROR=$?
        fi
    elif [ "x$2" = "xmotma" ]; then
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT stop
            sleep 2
            $MOTMA_SCRIPT start
            MOTMA_ERROR=$?
        fi

    elif [ "x$2" = "x" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT stop
            NOMA_ERROR=$?
        fi
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT stop
            MOTMA_ERROR=$?
        fi
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT stop
            GWSERVICES_ERROR=$?
        fi
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT stop
            SYSLOG_ERROR=$?
        fi
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT stop
            NTOP_ERROR=$?
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT stop
            SNMPTRAPD_ERROR=$?
        fi
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT stop
            SNMPTT_ERROR=$?
        fi
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT stop
            NAGIOS_ERROR=$?
        fi
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT stop
            APACHE_ERROR=$?
        fi
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT stop
            POSTGRESQL_ERROR=$?
            sleep 2
        fi
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT start
            POSTGRESQL_ERROR=$?
            sleep 2
        fi
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT start
            APACHE_ERROR=$?
        fi
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT start
            NAGIOS_ERROR=$?
        fi
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT start
            SYSLOG_ERROR=$?
        fi
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT start
            SNMPTT_ERROR=$?
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT start
            SNMPTRAPD_ERROR=$?
        fi
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT start
            NTOP_ERROR=$?
        fi
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT start
            GWSERVICES_ERROR=$?
        fi
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT start
            NOMA_ERROR=$?
        fi
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT start
            MOTMA_ERROR=$?
        fi
    else
        ERROR=1
        echo "Invalid argument: $2"
        help
    fi

elif [ "x$1" = "xstatus" ]; then

    if [ "x$2" = "xpostgresql" ]; then
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT status
            sleep 2
        fi
    elif [ "x$2" = "xapache" ]; then
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT status
        fi
    elif [ "x$2" = "xnagios" ]; then
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT status
        fi
    elif [ "x$2" = "xsyslog-ng" ]; then
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT status
        fi
    elif [ "x$2" = "xsnmptt" ]; then
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT status
        fi
    elif [ "x$2" = "xsnmptrapd" ]; then
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT status
        fi
    elif [ "x$2" = "xntop" ]; then
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT status
        fi
    elif [ "x$2" = "xgwservices" ]; then
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT status
        fi
    elif [ "x$2" = "xnoma" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT status
        fi
    elif [ "x$2" = "xmotma" ]; then
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT status
        fi

    elif [ "x$2" = "x" ]; then
        if test -x $NOMA_SCRIPT; then
            $NOMA_SCRIPT status
        fi
        if test -x $MOTMA_SCRIPT; then
            $MOTMA_SCRIPT status
        fi
        if test -x $GWSERVICES_SCRIPT; then
            $GWSERVICES_SCRIPT status
        fi
        if test -x $SYSLOG_SCRIPT; then
            $SYSLOG_SCRIPT status
        fi
        if test -x $NTOP_SCRIPT; then
            $NTOP_SCRIPT status
        fi
        if test -x $SNMPTRAPD_SCRIPT; then
            $SNMPTRAPD_SCRIPT status
        fi
        if test -x $SNMPTT_SCRIPT; then
            $SNMPTT_SCRIPT status
        fi
        if test -x $NAGIOS_SCRIPT; then
            $NAGIOS_SCRIPT status
        fi
        if test -x $APACHE_SCRIPT; then
            $APACHE_SCRIPT status
        fi
        if test -x $POSTGRESQL_SCRIPT; then
            $POSTGRESQL_SCRIPT status
        fi
    else
        ERROR=1
        echo "Invalid argument: $2"
        help
    fi
else
    ERROR=1
    echo "Invalid argument: $1"
    help
fi

# Checking for errors
for e in $APACHE_ERROR $POSTGRESQL_ERROR $NAGIOS_ERROR $SYSLOG_ERROR $SNMPTT_ERROR $SNMPTRAPD_ERROR $NTOP_ERROR $GWSERVICES_ERROR $NOMA_ERROR $MOTMA_ERROR; do
    if [ $e -gt 0 ]; then
        ERROR=$e
    fi
done

exit $ERROR

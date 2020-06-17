# MoTMa - Monitoring Ticketing Manager

Interface between Monitoring and Service Desk Tools.

MoTMa collects events from your monitoring system and will create incidents on your Service Desk Tool. Corresponding Events will be collected and aggregated. Status changes triggered from the monitoring system will update the incident in the Service Desk Tool.

## Getting Started

### Supported Monitoring Tools (Event generation)

* GroundWork
* Nagios
* NoMa (Notification Manager)

### Supported Service Desk Tools

* BMC Remedy ITSM
* BMC RemedyForce

### Missing Monitoring / Service Desk Tools

If your tools are missing. Try to add your own and make a pull request or contact office@realstuff.ch.

## System Requirements

MoTMa was tested on GroundWork 7.2.2 with Nagios 4.3.4. Make sure your Monitoring Tool is equal. MoTMa is only running on Linux.
* Monitoring Tool with Nagios
* Perl Environment
* PosgreSQL database server (except when running on sqlite)

### Perl Dependencies

MoTMa is implemented in Perl and uses differnt modules. Make sure you have installed them in your Perl installation or you can use the folder lib in MoTMa.
* App::Daemon
* Cache::File
* Class::Inspector
* Email::Format
* File::NFSLock
* MIME::Lite
* SOAP::Lite
* Text::Template
* JSON
* HTTP::Request
* LWP::UserAgent
* Log::Log4Perl

### Database

You can use sqlite or postgreSQL as your database backend for MoTMa. Depending on your needs you need:
* sqlite3
* postgreSQL 9.x

## Installation

To install just download this repo and extract it. Change to the folder you like to install MoTMa and clone the repo.

```
cd /opt/motma

git clone https://github.com/RealStuff/MoTMa.git motma
```

## Configuration

A sample configuration file is located in the `etc` folder. Change it accordingly. 

```
# Main config file
vim motma/etc/motma.ini

# If you like to change the log behavior edit:
vim motma/etc/motma.l4p
```
## GroundWork

If you are using GroundWork we recommend to install MoTMa in the `/usr/local/groundwork/` folder and to add the MoTMa init.d script to the `ctlscript.sh` in GroundWork. You will find an adapted `ctlsript.sh` in `resources/groundwork`.

### GroundWork / Nagios

When using Nagios to send notifications you have to add a notification command for MoTMa.

For Hosts:

```
define command {
        command_name                    host-notify-motma
        command_line                    /usr/local/groundwork/motma/bin/sendEvent.pl -H $HOSTNAME$ -m "$HOSTOUTPUT$" -d $TIMET$ -S $HOSTSTATE$
}
```

For Services:

```
define command {
        command_name                    service-notify-itsm
        command_line                    /usr/local/groundwork/motma/bin/sendEvent.pl -H $HOSTNAME$ -s $SERVICEDESC$ -m "$SERVICEOUTPUT$" -d $TIMET$ -S $SERVICESTATE$
}
```


### GroundWork / NoMa

When using NoMa in GroundWork you have to configure some files.

#### Edit `NoMa.yml`

1. add a command `sendmotma` in the `command:` section to `/usr/local/groundwork/noma/etc/NoMa.yml`:

```
  sendmotma: /usr/local/groundwork/noma/notifier/sendmotma.pl
```

2. add a method `sendmotma` in the `methods:` section:

```
  sendmotma:
    message:
      host:
        ackmessage: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nAuthor: $authors\nComment: $comments\nState: $status\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        message: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nHost Alias: $host_alias\nState: $status\nAddress: $host_address\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        subject: "NoMa: Host $host is $status"
      service:
      service:
    message:
      host:
        ackmessage: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nAuthor: $authors\nComment: $comments\nState: $status\nLink: http://t-
gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        message: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nHost Alias: $host_alias\nState: $status\nAddress: $host_address\nLink: h
ttp://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        subject: "NoMa: Host $host is $status"
      service:
        ackmessage: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nAuthor: $authors\nComment: $comments\nService: $service\nHost: $host\nState: $stat
us\n\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host&service=$service\nInfo: $output\n\nDate/Time: $datetime"
        message: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nService: $service\nHost: $host\nHost Alias: $host_alias\nState: $status\nAddress: $ho
st_address\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host&service=$service\nInfo: $output\n\nDate/Time: $datetime"
        subject: "NoMa: Service $service on host $host is $status"
    sendmail: /usr/local/groundwork/common/bin/sendEmail
  sendmotma:
    message:
      host:
        ackmessage: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nAuthor: $authors\nComment: $comments\nState: $status\nLink: http://t-
gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        message: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nHost: $host\nHost Alias: $host_alias\nState: $status\nAddress: $host_address\nLink: h
ttp://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host\nInfo: $output\n\nDate/Time: $datetime"
        subject: "NoMa: Host $host is $status"
      service:
        ackmessage: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nAuthor: $authors\nComment: $comments\nService: $service\nHost: $host\nState: $status\n\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host&service=$service\nInfo: $output\n\nDate/Time: $datetime"
        message: "***** NoMa *****\n\nID: $incident_id\nNotification Type: $notification_type\nService: $service\nHost: $host\nHost Alias: $host_alias\nState: $status\nAddress: $host_address\nLink: http://t-gw-motma-awe/portal-statusviewer/urlmap?host=$host&service=$service\nInfo: $output\n\nDate/Time: $datetime"
        subject: "NoMa: Service $service on host $host is $status"
    sendmotma : /opt/motma/bin/NoMaEvent.pl
```

#### Configure NoMa in the UI

1. Got to the NoMa UI and add a new Method. This method should be called `sendmotma` or as named in the previous step.
2. Create a new Notification Rule with the method `sendmotma`or add the method `sendmotma` to an already created Notification rule.
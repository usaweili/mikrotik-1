##
##   Automatically upgrade RouterOS and Firmware
##   https://github.com/massimo-filippi/mikrotik
##
##   script by Maxim Krusina, maxim@mfcc.cz
##   based on: http://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS
##   created: 2014-12-05
##   updated: 2015-12-05
##   tested on: RouterOS 6.33.1 / multiple HW devices
##


########## Set variables

## Notification e-mail
:local email "your@email.com"


########## Do the stuff

## Check for update
/system package update
set channel=current
check-for-updates

## Waint on slow connections
:delay 15s;

:if ([get installed-version] != [get latest-version]) do={ 

   ## New version of RouterOS available, let's upgrade
   /tool e-mail send to="$email" subject="Upgrading RouterOS on router $[/system identity get name]" body="Upgrading RouterOS on router $[/system identity get name] from $[/system package update get installed-version] to $[/system package update get latest-version] (channel:$[/system package update get channel])"
   :log info ("Upgrading RouterOS on router $[/system identity get name] from $[/system package update get installed-version] to $[/system package update get latest-version] (channel:$[/system package update get channel])")     

   ## Wait for mail to be send & upgrade
   :delay 15s;
   upgrade

} else={

   ## RouterOS latest, let's check for updated firmware
    :log info ("No RouterOS upgrade found, checking for HW upgrade...")

   /system routerboard

   :if ( [get current-firmware] != [get upgrade-firmware]) do={ 

      ## New version of firmware available, let's upgrade
      /tool e-mail send to="$email" subject="Upgrading firmware on router $[/system identity get name]" body="Upgrading firmware on router $[/system identity get name] from $[/system routerboard get current-firmware] to $[/system routerboard get upgrade-firmware]"
      :log info ("Upgrading firmware on router $[/system identity get name] from $[/system routerboard get current-firmware] to $[/system routerboard get upgrade-firmware]")
      
      ## Wait for mail to be send & upgrade
      :delay 15s;
      upgrade

      ## Wait for upgrade, then reboot
      :delay 180s;
      /system reboot

   } else={

   :log info ("No Router HW upgrade found")

   }

}
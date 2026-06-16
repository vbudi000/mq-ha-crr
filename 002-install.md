# Installing IBM MQ 

## Preparation
Download IBM MQ from Passport Advantage Online site or IBM Software Download site. The following are the list of part numbers and filenames that you can use to search the download. The size for 9.4.x is roughly 0.5GB.

- M0SJDML 9.4.4.0-IBM-MQ-LinuxX64_.tar.gz
- M0XKZML 9.4.5.0-IBM-MQ-LinuxX64_.tar.gz

The next section, the installation and Web console should be run on each of the 6 servers. Automatic installation on the servers are provided in [scripts/2-0-runinstall.sh](scripts/2-0-runinstall.sh), or you can run the installation manually. The installation file must be put on each of the 6 servers. So that it can be installed later.

## Installing

To install IBM MQ you can use the script in [scripts/2-1-install.sh](scripts/2-1-install.sh). Or you can follow these procedure: 

1. Prepare the `mqm` user and group. The following commands can be used, but if your environment has a different mechanism for creating users and groups, follow the procedure. The last part is to increase the file and processes limit for the mqm user.

    ``` bash
    # Create mqm user and group with consistent GID
    groupadd -g 1000 mqm
    useradd -u 1000 -g 1000 -d /home/mqm mqm 

    cat << EOF > /etc/security/limits.d/30-ibmmq.conf
    mqm - nofile 65536
    mqm - nproc  32768
    EOF
    ```

2. Install several pre-requisite software for IBM MQ.

    ``` bash
    dnf -y install bc ca-certificates openssl libstdc++ wget util-linux
    dnf -y install shadow-utils glibc-common findutils gawk
    ```

3. Open several ports from firewalld if necessary, these are the default ports that are being used in MQ.

    ``` bash
    firewall-cmd --permanent --add-port=mqlistener-1414/tcp
    firewall-cmd --permanent --add-port=mqadmin-1415/tcp
    firewall-cmd --permanent --add-port=mqhalistener-9414/tcp
    firewall-cmd --permanent --add-port=mqhaadmin-9415/tcp
    firewall-cmd --permanent --add-port=mqweb-9443/tcp
    ```

4. Define the required paths for MQ.

    ``` bash
    mkdir /var/mqm
    mkdir /opt/mqm

    chown mqm:mqm /var/mqm
    chown mqm:mqm /opt/mqm
    ```

5. Install MQ, assuming that the tar installable file is in the `/tmp` directory, you can run the following commands.

    ``` bash
    cd /tmp
    tar -xzvf 9.4.4.0-IBM-MQ-LinuxX64_.tar.gz

    cd MQServer
    ./mqlicense.sh -accept

    dnf install -y MQSeries*.rpm
    ```

6. Setup a profile that set the MQ environment for all users

    ``` bash
    echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
    echo "" >> /etc/profile.d/mqm.sh
    chmod 755 /etc/profile.d/mqm.sh

    source /etc/profile.d/mqm.sh && dspmqver
    ```


## MQ Web Console

This last part is optional. You can install MQ Web Console for easier management of you MQ resources. The script is provided in [scripts/2-2-mqweb.sh](scripts/2-2-mqweb.sh)

1. To install the web console, you must act as `mqm` user

    ``` bash
    su - mqm
    strmqweb
    endmqweb
    ```

2. After starting the MQ web, the directory and files are created. The easiest way is to copy the sample configuration for the basic registry and set up a couple of parameters.

    ``` bash
    cd /var/mqm/web/installations/Installation1/servers/mqweb/
    cp mqwebuser.xml mqwebuser.xml.bak
    cp /opt/mqm/web/mq/samp/configuration/basic_registry.xml mqwebuser.xml

    cat <EOF >>mqwebuser.xml
    <variable name="httpsPort" value="9443"/>
    <variable name="httpHost" value="*"/>
    <variable name="mqRestMessagingEnabled" value="true”/>
    EOF
    ```

3. Now start the MQ Web Console

    ``` bash
    strmqweb
    ```

4. MQ Web Console is available at `https://${host}:9443/ibmmq/console` and you can login as `mqadmin` with the password of `mqadmin`
 
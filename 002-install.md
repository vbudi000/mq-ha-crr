# Installing IBM MQ

In this section, you will:

- [Install MQ Software](#installing-mq-software)
- [Set Up the MQ Web Console](#mq-web-console)

Both the MQ software and the MQ Web Console must be installed on each of the 6 servers. Automated installation is provided by [scripts/2-0-runinstall.sh](scripts/2-0-runinstall.sh), or you can follow the manual steps below. The installation archive must be placed on each of the 6 servers before running the installer.

## Installing MQ Software

To install IBM MQ, use the script [scripts/2-1-install.sh](scripts/2-1-install.sh), or follow this procedure manually:

1. Prepare the `mqm` user and group. The commands below work for most environments; if your environment uses a different mechanism for user and group creation, follow that procedure instead. The final step increases the file and process limits for the `mqm` user.

    ``` bash
    # Create mqm user and group with consistent GID
    groupadd -g 1000 mqm
    useradd -u 1000 -g 1000 -d /home/mqm mqm 

    cat << EOF > /etc/security/limits.d/30-ibmmq.conf
    mqm - nofile 65536
    mqm - nproc  32768
    EOF
    ```

2. Install the prerequisite packages for IBM MQ:

    ``` bash
    dnf -y install bc ca-certificates openssl libstdc++ wget util-linux
    dnf -y install shadow-utils glibc-common findutils gawk
    ```

3. Open the required ports in `firewalld` if necessary. These are the default ports used by MQ:

    ``` bash
    firewall-cmd --permanent --add-port=mqlistener-1414/tcp
    firewall-cmd --permanent --add-port=mqadmin-1415/tcp
    firewall-cmd --permanent --add-port=mqhalistener-9414/tcp
    firewall-cmd --permanent --add-port=mqhaadmin-9415/tcp
    firewall-cmd --permanent --add-port=mqweb-9443/tcp
    ```

4. Create the required directories for MQ:

    ``` bash
    mkdir /var/mqm
    mkdir /opt/mqm

    chown mqm:mqm /var/mqm
    chown mqm:mqm /opt/mqm
    ```

5. Install MQ. Assuming the installation archive is in the `/tmp` directory, run:

    ``` bash
    cd /tmp
    tar -xzvf 9.4.4.0-IBM-MQ-LinuxX64_.tar.gz

    cd MQServer
    ./mqlicense.sh -accept

    dnf install -y MQSeries*.rpm
    ```

6. Set up a system-wide profile that configures the MQ environment for all users:

    ``` bash
    echo "source /opt/mqm/bin/setmqenv -s" > /etc/profile.d/mqm.sh
    echo "" >> /etc/profile.d/mqm.sh
    chmod 755 /etc/profile.d/mqm.sh

    source /etc/profile.d/mqm.sh && dspmqver
    ```


## MQ Web Console

This step is optional. The MQ Web Console provides a graphical interface for managing MQ resources. The setup script is provided in [scripts/2-2-mqweb.sh](scripts/2-2-mqweb.sh).

1. Switch to the `mqm` user and initialise the web console:

    ``` bash
    su - mqm
    strmqweb
    endmqweb
    ```

2. Starting and stopping the web console creates the required directory structure. Copy the sample basic registry configuration and set the required parameters:

    ``` bash
    cd /var/mqm/web/installations/Installation1/servers/mqweb/
    cp mqwebuser.xml mqwebuser.xml.bak
    cp /opt/mqm/web/mq/samp/configuration/basic_registry.xml mqwebuser.xml

    cat <<EOF >> mqwebuser.xml
    <variable name="httpsPort" value="9443"/>
    <variable name="httpHost" value="*"/>
    <variable name="mqRestMessagingEnabled" value="true"/>
    EOF
    ```

3. Start the MQ Web Console:

    ``` bash
    strmqweb
    ```

4. The MQ Web Console is available at `https://${host}:9443/ibmmq/console`. Log in as `mqadmin` with the password `mqadmin`.

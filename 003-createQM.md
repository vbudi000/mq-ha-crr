# Creating the Queue Manager with Native HA and CRR

The Queue Manager must be installed on all 6 VMs. An automated installation script is provided in [scripts/3-0-createqm.sh](scripts/3-0-createqm.sh).

To create the Queue Managers manually, perform the following steps on all 6 servers:

- [Create Queue Manager](#create-queue-manager)
- [Establish MQ Monitor](#create-mq-monitor-systemd-process)
- [Create the Resources](#configure-mq-resources)

## Create Queue Manager

1. Log in as the `mqm` user:

    ``` bash
    sudo su - mqm
    ```

2. Create the Queue Manager. Increase the log file size and count, and assign a proper instance name so that communication between Native HA members can be established. The Queue Manager name must be the same on all 6 servers.

    ``` bash
    curnode=$(hostname -s)
    qmname=MYQMGR
    crtmqm -lr ${curnode} -lf 8192 -lp 10 -ls 10 -p 1414 ${qmname}
    ```

3. Edit the configuration file at `/var/mqm/qmgrs/<qmname>/qm.ini` and add the following stanzas:

    ```
        . . .
    NativeHALocalInstance:
        Name=${host11}
        GroupName=${site1}
        GroupRole=Live
        GroupLocalAddress=(9415)
    NativeHARecoveryGroup:
        GroupName=${site2}
        ReplicationAddress=${ip21}(9415),${ip22}(9415),${ip23}(9415)
        Enabled=Yes
    NativeHAInstance:
        Name=${host11}
        ReplicationAddress=${ip11}(9414)
    NativeHAInstance:
        Name=${host12}
        ReplicationAddress=${ip12}(9414)
    NativeHAInstance:
        Name=${host13}
        ReplicationAddress=${ip13}(9414)
    ```

    - **NativeHALocalInstance** — defines the local group, its name, its role, and the listening port. This group is the *Live* group, listening on port 9415.
    - **NativeHARecoveryGroup** — defines the partner group and the replication addresses it will attempt to connect to.
    - **NativeHAInstance** — defines the individual members within the local Native HA group.

The following diagram illustrates the communication defined by the configuration above:

![images/003-01-ports.png](images/003-01-ports.png)


## Create MQ Monitor Systemd Process

IBM MQ ships with a sample `systemd` unit that makes it easy to manage the Queue Manager process across systems. The `mqmonitor` service handles starting, stopping, and monitoring the Queue Manager. To enable it, use the script [scripts/3-2-mqmonitor.sh](scripts/3-2-mqmonitor.sh).

1. Link the sample `systemd` unit file into the system directory (requires root):

    ``` bash
    sudo ln -s /opt/mqm/samp/mqmonitor@.service /etc/systemd/system 
    ```

2. Enable the service for each Queue Manager:

    ``` bash
    sudo systemctl enable mqmonitor@${qmgr}
    ```

3. The `enable` command creates the service definition file at `/etc/systemd/system/mqmonitor@<qmgr>.service`. If your environment uses Active Directory for authentication, it is recommended to add the following environment variable to that file:

    ```
     Environment=MQS_GETGROUPLIST_API=1
    ```

4. Start the service. From this point, the service manages the Queue Manager lifecycle:

    ```
    sudo systemctl start mqmonitor@${qmgr}
    ```


## Configure MQ Resources

This section disables most security settings and creates a local queue named `QUEUE1`. This avoids the complexity of a full security configuration — in a production environment, security must be configured according to your requirements.

As the `mqm` user on the active Queue Manager instance, run `runmqsc <QMGR name>` and provide the following input:

```
ALTER QMGR CONNAUTH('') CHLAUTH(DISABLED)
SET CHLAUTH(SYSTEM.DEF.SVRCONN) TYPE(ADDRESSMAP) ADDRESS(*) USERSRC(CHANNEL)
DEFINE QLOCAL(QUEUE1) DEFPSIST(YES)
REFRESH SECURITY (*)
END
```

Alternatively, run [scripts/3-3-modqm.sh](scripts/3-3-modqm.sh) as root from the bastion host.

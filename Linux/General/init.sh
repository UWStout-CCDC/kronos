#!/bin/bash

# The name of the command that will be used to start the script
getCommandName="InitBox"

# define important variables
CCDC_DIR="/ccdc"
CCDC_ETC="$CCDC_DIR/etc" # Holds old configuration files so if we need to revert we can
SCRIPT_DIR="$CCDC_DIR/scripts"
SYSTEM_SCRIPT_DIR="$CCDC_DIR/systemscripts"


# Verry first, change the root user
# Ask for new root password
while true; do
    echo "Please enter the new root password:"
    read -s -p "Enter the new root password: " PASSWORD
    echo
    read -s -p "Confirm the new root password: " CONFIRM_PASSWORD
    echo

    if [ "$PASSWORD" = "$CONFIRM_PASSWORD" ]; then
        break
    else
        clear
        echo "Passwords do not match. Please try again."
    fi
done

# Change the root password
echo "Changing the root password..."
echo "root:$PASSWORD" | chpasswd

# Install things that important
# Ensure that screen is installed so we can run stuff in the background
if type yum; then
    yum install screen -y
elif type apt-get; then
    apt-get install screen -y
else
    echo "Could not install screen. Please install it manually."
    sleep 1
    return -1
fi

get() {
  # only download if the file doesn't exist
  if [[ ! -f "$SCRIPT_DIR/$1" ]]
  then
    mkdir -p $(dirname "$SCRIPT_DIR/$1") 1>&2
    BASE_URL="https://raw.githubusercontent.com/UWStout-CCDC/CCDC-scripts-2020/master"
    wget --no-check-certificate "$BASE_URL/$1" -O "$SCRIPT_DIR/$1" 1>&2
  fi
  echo "$SCRIPT_DIR/$1"
}

prompt() {
  case "$2" in 
    y) def="[Y/n]" ;;
    n) def="[y/N]" ;;
    *) echo "INVALID PARAMETER!!!!"; exit ;;
  esac
  read -p "$1 $def" ans
  case $ans in
    y|Y) true ;;
    n|N) false ;;
    *) [[ "$def" != "[y/N]" ]] ;;
  esac
}

# Now we need to get all of the information from the user upfront
# So they are able to let it run in the background

# Now we need to get user input, this will include the below:
# CREATE NEW ROOT USER
# get the username
# get the password

# GET MACHINE TYPE FOR IP TABLES
# is HTTP or HTTPS?
# is DNS or NTP?
# is MAIL?
# is SPLUNK?

clear
# Now we need to get the user input
echo "Please enter the following information to create new root user:"
read -p "Enter the username for the new root user: " USERNAME
clear

while true; do
    
    echo "Enter the username for the new root user: " $USERNAME
    read -s -p "Enter the password: " PASSWORD
    echo
    read -s -p "Confirm password: " CONFIRM_PASSWORD
    echo

    if [ "$PASSWORD" = "$CONFIRM_PASSWORD" ]; then
        break
    else
        clear
        echo "Passwords do not match. Please try again."
    fi
done

clear


# Now we need to get the machine type
echo "Please enter the following information to configure the machine type for firewall tools:"
server_http=$(prompt "Does the machine have an HTTP(s) server?" n)
server_dns=$(prompt "Does the machine have a DNS server?" n)
server_mail=$(prompt "Does the machine have a mail server?" n)
server_splunk=$(prompt "Does the machine have a splunk server?" n)

clear

# Ask if they want to install splunk
if [[ !$server_splunk ]] then
    SPLUNK_SCRIPT=$(get linux/splunk-forward.sh)
    installSplunkForward=$(prompt "Do you wish to install Splunk Forwarder?" y)
fi

clear

# Generate the script directory if it doesn't exist, and restrict access to root
echo "Generating the ccdc directory..."
if [[ ! -d $SCRIPT_DIR || ! -d $CCDC_ETC || ! -d $SYSTEM_SCRIPT_DIR ]]; then
    mkdir $SCRIPT_DIR
    chown root:root $SCRIPT_DIR
    chmod 700 $SCRIPT_DIR
    mkdir $CCDC_ETC
    chown root:root $CCDC_ETC
    chmod 700 $CCDC_ETC
    mkdir $SYSTEM_SCRIPT_DIR
    chown root:root $SYSTEM_SCRIPT_DIR
    chmod 700 $SYSTEM_SCRIPT_DIR
fi

# Change etc/sudoers
echo "Changing /etc/sudoers..."
groupadd wheel
groupadd sudo
cp /etc/sudoers $CCDC_ETC/sudoers
cat <<-EOF > /etc/sudoers
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# User privilege specification
root    ALL=(ALL:ALL) ALL
$USERNAME ALL=(ALL:ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
%wheel   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "@include" directives:
#@includedir /etc/sudoers.d
EOF

# Create the new root user with the above information
echo "Creating the new root user..."
useradd -m -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo $USERNAME

# Create script deny nologin users
echo "Creating the nologin promp..."
cat <<-EOF > $SYSTEM_SCRIPT_DIR/nologin.sh
#!/bin/bash
echo "This account is currently unavailable."
exit 0
EOF
chmod +x $SYSTEM_SCRIPT_DIR/nologin.sh

# create scrpit to change all users to nologin except new root user
echo "Creating the nologin script..."
cat <<-EOF > $SCRIPT_DIR/nologin.sh
#!/bin/bash
getCommandName="nologin users"
for user in \$(awk -F: '{print \$1}' /etc/passwd); do
    if [ \$user != $USERNAME ]; then
        usermod -s $SYSTEM_SCRIPT_DIR/nologin.sh \$user
        passwd -l \$user
    fi
done
EOF

# Run the nologin script
echo "Running the nologin script..."
bash $SCRIPT_DIR/nologin.sh

# Create the script to configure the firewall
echo "Creating the firewall configuration script..."
cat <<-EOF > $SCRIPT_DIR/firewall.sh
#!/bin/bash
getCommandName="Re-configure firewall"

if [[ \$EUID -ne 0 ]]
then
  printf 'Must be run as root, exiting!\n'
  exit 1
fi

# Empty all rules
iptables -t filter -F
iptables -t filter -X

# Block everything by default
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

# Authorize already established connections
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

# DNS (Needed for curl, and updates)
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT

# HTTP/HTTPS
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT

# NTP (server time)
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

# Splunk
iptables -t filter -A OUTPUT -p tcp --dport 8000 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 8089 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 9997 -j ACCEPT

# SSH outbound
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######## OUTBOUND SERVICES ###############

EOF

# Add the services to the firewall script
if [ $server_http ]; then
    cat <<-EOF >> $SCRIPT_DIR/firewall.sh
# HTTP
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
EOF
fi

if [ $server_dns ]; then
    cat <<-EOF >> $SCRIPT_DIR/firewall.sh
# DNS (bind)
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT

# NTP
iptables -t filter -A INPUT -p tcp --dport 123 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 123 -j ACCEPT
EOF
fi

if [ $server_mail ]; then
    cat <<-EOF >> $SCRIPT_DIR/firewall.sh
# SMTP
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT

# POP3
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT

# IMAP
iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT

EOF
fi

if [ $server_splunk ]; then
    cat <<-EOF >> $SCRIPT_DIR/firewall.sh
# Splunk Web UI
iptables -t filter -A INPUT -p tcp --dport 8000 -j ACCEPT
# Splunk Forwarder
iptables -t filter -A INPUT -p tcp --dport 8089 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 9997 -j ACCEPT
# Syslog (PA)
iptables -t filter -A INPUT -p tcp --dport 514 -j ACCEPT
EOF
fi

# Run the firewall script
echo "Running the firewall script..."
bash $SCRIPT_DIR/firewall.sh

# Create systemd unit for the firewall
echo "Creating the firewall systemd unit..."
# Create systemd unit for the firewall
mkdir -p /etc/systemd/system/
cat <<-EOF > /etc/systemd/system/ccdc_firewall.service
[Unit]
Description=ZDSFirewall
After=syslog.target network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/firewall.sh
ExecStop=/sbin/iptables -F
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable the firewall service
echo "Enabling the firewall service..."
systemctl enable ccdc_firewall.service

legalBanner=<<-EOF
UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED

You must have explicit, authorized permission to access or configure this device.
Unauthorized attempts and actions to access or use this system may result in civil
and/or criminal penalties.

All activities performed on this device are logged and monitored.
EOF

# Set legal banners
echo "Setting legal banners..."
echo $legalBanner > /etc/issue
echo $legalBanner > /etc/issue.net

# Set the motd
echo "Setting the motd..."
echo $legalBanner > /etc/motd


############# CONFIGURE SERVICES #############
if type systemctl 
then
    # Disable ssh
    echo "Disabling SSH..."
    systemctl disable --now sshd

    # Disable telnet
    echo "Disabling Telnet..."
    systemctl disable --now telnet

    # Disable other firewalls
    echo "Disabling other firewalls..."
    systemctl disable --now firewalld
    systemctl disable --now ufw
else
    echo "Could not disable services. Since you do not have systemctl. Please disable them manually. Continuing..."
    sleep 3
fi

############ UPDATE SYSTEM ############
if type yum
then
    echo "Updating the system..."
    yum update -y && yum upgrade -y
elif type apt-get
then
    echo "Updating the system..."
    apt-get update -y && apt-get upgrade -y
else
    echo "Could not update the system. Please update it manually. Continuing..."
    sleep 3
fi

############ INSTALL OTHER TOOLS ############
# Install Splunk Forwarder
if [ $installSplunkForward ]; then
    echo "Installing Splunk Forwarder..."
    bash $SPLUNK_SCRIPT 172.20.241.20 
fi

# Tell the user that they need to reboot
echo
echo
echo "The system has been configured. Please reboot the system to apply the changes. You will be redirected to the main menu."
# Wait for user input to continue
read -p "Press [Enter] to continue..."
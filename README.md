# Installation

The assignment can be inatalled via the command line

if you set an env variable

```bash
export WEEK2_TEAMS_WEBHOOK_ENV=<teams_webhook_url>
```

the montior information will be sent to your webhook url
other i will be the one receiving the information 🌚 🌚

```bash
git clone https://github.com/X4MU-L/month2-week3-assignment.git
cd month2-week3-assignment
sudo bash install.sh [<name_of_command>]
```

```bash
# one line command
curl -sSL https://raw.githubusercontent.com/X4MU-L/month2-week3-assignment/main/install.sh| sudo bash
# or
curl -sSL https://raw.githubusercontent.com/X4MU-L/month2-week3-assignment/main/install.sh| sudo bash -s -- <name_of_command>
```

# create nginx server and capture and analyze packages

```bash
sudo bash capture_nginx
#or run
sudo ./capture_ngix
```

```bash
# replace eth0 with an actual network dev on your syste,
sudo tcpdump -i any port 80 -w nginx_traffic.pcap
```

in a different terminal

```bash
curl http://localhost
```

```bash
# read and analyze the captures packets using wireshark
 wireshark -r nginx_traffic.pcap
```

# IPTV Docker Compose Configuration

## Prequsite
- docker
- git

## How to install
```
git clone https://github.com/hexafiber/iptv-compose.git

cd iptv-compose

# for origin server

# create a RAM Disk folder if you haven't already
sudo mkdir /tmp/ramdisk
sudo chmod 777 /tmp/ramdisk
sudo mount -t tmpfs -o size=5G myramdisk /tmp/ramdisk

sudo nano /etc/fstab
myramdisk  /tmp/ramdisk  tmpfs  defaults,size=1G,x-gvfs-show  0  0

# Finaly run docker compose
docker compose up -d


# for cdn server
docker compose -f docker-compose.cdn.yml up -d
```
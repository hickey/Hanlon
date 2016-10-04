

hostname_prefix: "rhelnode"
domainname: localdomain
root_password: test1234
partition_table: |
  part /boot --ondisk=sda --size=512  --fstype=ext3
  part swap  --ondisk=sda --size=4096 --fstype=swap
  part pv.01 --ondisk=sda --size=1  --grow
  volgroup vg_root pv.01
  logvol /    --vgname=vg_root --size=32768  --name=lv_root --fstype=xfs --grow
  ignoredisk --only-use=sda
  
filesystem:
  /boot:
    disk: sda
    size: 512
    fstype: ext2
    primary: true
    partition_type: 83
  swap:
    disk: sda
    size: 4096
    fstype: swap
    partition_type: 82
  pv.01:
    disk: sda
    size: 1
    grow: true
    partition_type: 8e
  vg_root:
    type: volgroup
    pv:
      - pv.01
  /:
    type: logvol
    size: 32768
    name: lv_root
    fstype: xfs
    grow: true
    partition_type: 83
    
    
salt_grains:
  roles:
    - mesos.slave
  pool: mesos
  
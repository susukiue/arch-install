#  Install

> https://wiki.archlinux.org/title/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

## 获取安装映像

> **官网:** https://archlinux.org/download/
>
> >- **国内源 (China)**
> >- [163.com](http://mirrors.163.com/archlinux/iso/2022.11.01/)
> >- [aliyun.com](http://mirrors.aliyun.com/archlinux/iso/2022.11.01/)
> >- [aliyun.com](https://mirrors.aliyun.com/archlinux/iso/2022.11.01/)
> >- [bfsu.edu.cn](http://mirrors.bfsu.edu.cn/archlinux/iso/2022.11.01/)
> >- [bfsu.edu.cn](https://mirrors.bfsu.edu.cn/archlinux/iso/2022.11.01/)
> >- [cqu.edu.cn](https://mirrors.cqu.edu.cn/archlinux/iso/2022.11.01/)
> >- [cqu.edu.cn](http://mirrors.cqu.edu.cn/archlinux/iso/2022.11.01/)
> >- [hit.edu.cn](https://mirrors.hit.edu.cn/archlinux/iso/2022.11.01/)
> >- [hit.edu.cn](http://mirrors.hit.edu.cn/archlinux/iso/2022.11.01/)
> >- [lzu.edu.cn](http://mirror.lzu.edu.cn/archlinux/iso/2022.11.01/)
> >- [neusoft.edu.cn](https://mirrors.neusoft.edu.cn/archlinux/iso/2022.11.01/)
> >- [neusoft.edu.cn](http://mirrors.neusoft.edu.cn/archlinux/iso/2022.11.01/)
> >- [nju.edu.cn](https://mirrors.nju.edu.cn/archlinux/iso/2022.11.01/)
> >- [nju.edu.cn](http://mirrors.nju.edu.cn/archlinux/iso/2022.11.01/)
> >- [njupt.edu.cn](https://mirrors.njupt.edu.cn/archlinux/iso/2022.11.01/)
> >- [redrock.team](http://mirror.redrock.team/archlinux/iso/2022.11.01/)
> >- [redrock.team](https://mirror.redrock.team/archlinux/iso/2022.11.01/)
> >- [shanghaitech.edu.cn](https://mirrors.shanghaitech.edu.cn/archlinux/iso/2022.11.01/)
> >- [shanghaitech.edu.cn](http://mirrors.shanghaitech.edu.cn/archlinux/iso/2022.11.01/)
> >- [sjtug.sjtu.edu.cn](https://mirrors.sjtug.sjtu.edu.cn/archlinux/iso/2022.11.01/)
> >- [tuna.tsinghua.edu.cn](https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/2022.11.01/)
> >- [tuna.tsinghua.edu.cn](http://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/2022.11.01/)
> >- [ustc.edu.cn](https://mirrors.ustc.edu.cn/archlinux/iso/2022.11.01/)
> >- [ustc.edu.cn](http://mirrors.ustc.edu.cn/archlinux/iso/2022.11.01/)
> >- [wsyu.edu.cn](https://mirrors.wsyu.edu.cn/archlinux/iso/2022.11.01/)
> >- [wsyu.edu.cn](http://mirrors.wsyu.edu.cn/archlinux/iso/2022.11.01/)
> >- [xjtu.edu.cn](https://mirrors.xjtu.edu.cn/archlinux/iso/2022.11.01/)
> >- [zju.edu.cn](http://mirrors.zju.edu.cn/archlinux/iso/2022.11.01/)

## 验证 *ISO* 镜像

- **下载 GPG 验证** 

>**GnuPG:** https://gnupg.org/download/
>
>>**Linux:**	[*GnuPG Desktop® AppImage with the current GnuPG*](https://download.gnupg.com/files/gnupg/gnupg-desktop-2.3.8.0-x86_64.AppImage)
>>**Windows:**
>>
>>- [*Full featured Windows version of GnuPG*](https://gpg4win.org/download.html)
>>- [*Simple installer for the current GnuPG*](https://gnupg.org/ftp/gcrypt/binary/gnupg-w32-2.3.8_20221013.exe)
>>- [*Simple installer for GnuPG 1.4*](https://gnupg.org/ftp/gcrypt/binary/gnupg-w32cli-1.4.23.exe)
>>
>>**OS X:** 
>>
>>- [*Installer from the gpgtools project*](https://gpgtools.org/)
>>- [*Installer for GnuPG*](https://sourceforge.net/p/gpgosx/docu/Download/)
>>
>>**Debian:**	[*GnuPG is part of Debian*](https://www.debian.org/)
>>**RPM:**		[*RPM packages for different OS*](http://rpmfind.net/)
>>**Android:**  [*Provides a GnuPG framework*](https://guardianproject.info/code/gnupg/)
>>**VMS:**		[*A port of GnuPG 1.4 to OpenVMS*](http://www.antinode.info/dec/sw/gnupg.html)
>>**RISC OS:** [*A port of GnuPG to RISC OS*](http://www.sbellon.de/gnupg.html)
>>

- **验证 sig  文件**

- >**Windows:**
  >
  >```powershell
  >PS C:\Users\pmup> gpg --verify archlinux-2022.11.01-x86_64.iso.sig
  >```
  >```powershell
  >gpg: assuming signed data in '.\\Downloads\\archlinux-2022.11.01-x86_64.iso'
  >gpg: Signature made 2022/11/1 21:57:39 中国标准时间
  >gpg:                using RSA key 4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC
  >gpg:                issuer "pierre@archlinux.de"
  >gpg: Good signature from "Pierre Schmitz <pierre@archlinux.de>" [unknown]
  >gpg:                 aka "Pierre Schmitz <pierre@archlinux.org>" [unknown]
  >gpg: WARNING: The key's User ID is not certified with a trusted signature!
  >gpg:          There is no indication that the signature belongs to the owner.
  >Primary key fingerprint: 4AA4 767B BC9C 4B1D 18AE  28B7 7F2D 434B 9741 E8AC
  >```
  >**ArchLinux:**
  >
  >  > ```shell
  >  > $ gpg --keyserver-options auto-key-retrieve --verify archlinux-2022.11.01-x86_64.iso.sig
  >  > ```
  >  >
  >  > ```shell
  >  >  $ pacman-key -v archlinux-version-x86_64.iso.sig
  >  > ```
  >  >
  > 

## 正常安装

### 连接网络

- **网线连接**

  - 检查网络是否连通 `# ping baidu.com`

    >网络不通的话
    >
    >1. 请检查 **网线** 是否插好
    >2. 使用 **dhcpcd** 分配 *动态IP* 地址 `# dhcpcd`

- **WIFI 连接**    [**iwctl**](https://wiki.archlinux.org/title/Iwd_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)#iwctl)

  1. 确保 网卡 支持 WIFI

  2. 检查 网卡 能够使用 (列出可用设备) `# iwctl device list`

  3. 使用 可用设备 扫描 WIFI `# iwctl station <device name> scan`

  4. 列出 可用 WIFI `# iwctl station <device name> get-networks`

  5. 连接 无密码 WIFI `# wictl station <device name> connect <SSID>`

  6. 连接 有密码 WIFI `# iwctl --passphrase passphrase station <device name> connect <SSID>`
  
     > **iwctl** 只支持 **8** 到 **63** 位 ASCII 编码字符组成的 PSK 密码
     >
     > 要连接 SSID 里带空格的网络，连接时请用双引号将网络名称括起来
  
  7. 检查网络是否连通 `# ping baidu.com`
  
     > <device name> 是 列出的 可用设备的 名字
     >
     > <SSID> 是扫描到的 WIFI 的 名称

### 更新系统时间

```shell
# timedatectl set-ntp true
```

### 硬盘分区

1. 列出 可用设备

   ```shell
   # fdisk -l
   Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   
   Disk /dev/loop0: 671.03 MiB, 703623168 bytes, 1374264 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   ```

   

2. 选择 可用的 /dev/sda 设备

   ```shell
   # fdisk /dev/sda
   Welcome to fdisk (util-linux 2.38.1).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   Deuice does not contain a recognized partition table.
   Created a new DOs disklabel with diskidentifier 0xbf6026f3.
   
   Command (m for help):
   ```

   > */dev/sda* 为 列出的 可用的 硬盘文件设备路径

3. 创建新的分区

   ```shell
   Command (m for help): n
   Partition type
      p   primary (0 primary, 0 extended, 4 free)
      e   extended (container for logical partitions)
   Select (default p): p
   Partition number (1-4, default 1): 1
   First sector (2048-20971520, default 2048): 2048
   Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-20971520, default 20971520): 20971520
   
   Created a new partition 1 of type 'Linux' and of size 10G GiB.
   
   Command (m for help): w
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Suncing disks.
   ```

   

4. 格式化分区为 ext4 类型

   ```shell
   # mkfs.ext4 /dev/sda1
   Creating filesystem with 2621184 4k blocks and 655360 inodes
   Filesystem UUID: 507d3ace-b104-4b4a-bfec-7f5e911938db
   Superblock backups stored on blocks: 
   	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632
   
   Allocating group tables: done
   Writing inode tables: done
   Creating journal (16384 blocks): done
   Writing superblocks and filesystem accounting information: done
   ```

### 挂载分区

```shell
# mount /dev/sda1 /mnt
```

> UEFI 分区挂载
>
> ```shell
> # mount /dev/sda1 /mnt/boot
> ```

### 修改 国内镜像源

- [Tencent Cloud](https://mirrors.cloud.tencent.com)
- [Huawei Cloud](https://repo.huaweicloud.com)
- [Beijing Institute of Technology](https://mirror.bit.edu.cn)
- [Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn)

**使用 *sed* 进行替换**

- 替换为 腾讯 源

    - ```shell
      # sed -i '1,/Server = /s/Server = .*/Server = https:\/\/mirrors.cloud.tencent.com\/archlinux\/$repo\/os\/\$arch/' /etc/pacman.d/mirrorlist
      ```

- 替换为 华为 源

    - ```shell
      # sed -i '1,/Server = /s/Server = .*/Server = https:\/\/repo.huaweicloud.com\/archlinux\/$repo\/os\/\$arch/' /etc/pacman.d/mirrorlist
      ```

- 替换为 北京理工大学 源

    - ```shell
      # sed -i '1,/Server = /s/Server = .*/Server = https:\/\/mirror.bit.edu.cn\/archlinux\/$repo\/os\/\$arch/' /etc/pacman.d/mirrorlist
      ```

- 替换为 清华开源镜像 源

    - ```shell
      # sed -i '1,/Server = /s/Server = .*/Server = https:\/\/mirrors.tuna.tsinghua.edu.cn/\/archlinux\/$repo\/os\/\$arch/' /etc/pacman.d/mirrorlist
      ```

### 同步 更新 镜像

```shell
# pacman -Syyu
```

### 安装必需的软件包

**使用 [*pacstrap*](https://man.archlinux.org/man/pacstrap.8) 脚本，安装 [*base*](https://archlinux.org/packages/?name=base) 软件包和 [*Linux 内核*](https://wiki.archlinux.org/title/%E5%86%85%E6%A0%B8) 以及常规硬件的固件**

```shell
# pacstrap /mnt base linux linux-firmware
```

### 进入 挂载的 系统

```shell
# arch-chroot /mnt
```

(*可选的*) **更新 镜像源**

> [选择国内源 (跳转)](###修改 国内镜像源)

(*可选的*) **安装** *vim* 、*ssh*

```shell
pacman -S vim openssh
```

### 设置时区

设置为 *上海* 时区

```shell
# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

生成 */etc/adjtime*

```shell
# hwclock --systohc
```

### 本地化设置

- ***应用程序*** 的本地化设置

```shell
# sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
```

> 或 使用 *vim* 编辑 ***/etc/locale.gen*** 将 `#en_US.UTF-8 UTF-8` 改为 `en_US.UTF-8 UTF-8`

- 生成 **locale** 信息

```shell
# locale-gen
```

- ***系统库*** 的本地化设置

```shell
# echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

> 或 使用 *vim* 编辑 ***/etc/locale.conf*** 写入 `LANG=en_US.UTF-8`
>
> 或 使用其他 *文本编辑器*

创建 **hostname** 文件

> 可以随意设置自己喜欢的 主机名

```shell
# echo "localhost" > /etc/hostname
```

(*可选的*) 创建 ***initramfs***

> 通常不需要自己创建新的 *initramfs*，因为在执行 *pacstrap* 时已经安装 *linux*，这时已经运行过 *mkinitcpio* 了

```shell
# mkinitcpio -P
```

## 安装 *GRUB* 引导

```shell
# pacman -S grub
```

> 当存在其它系统时 可以安装 ***os-prober***
>
> ```shell
> # pacman -S grub os-prober
> ```

### 使用 *UEFI* 引导

```shell
# pacman -S efibootmgr
# mount -t efivarfs efivarfs /sys/firmware/efi/efivars
# grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB --recheck
```

### **使用 *BIOS* 引导**

```shell
# grub-install --target=i386-pc --recheck /dev/sda
```

> 使用 **(移动设备)U盘** 作为 **arch** 的基本盘在安装 **GRUB** 时需要加上 `--removable`
>
> - ```shell
>   # grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB --recheck --removable
>   ```
>
> - ```shell
>   # grub-install --target=i386-pc --recheck --removable /dev/sda
>   ```

## 生成 *grub.cfg*

> 如果希望在 GRUB 引导菜单 显示 其他操作系统的 引导
>
> ```shell
> # sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
> ```
>
> 或 使用 *vim* 编辑 *etc/default/grub* 将 `#GRUB_DISABLE_OS_PROBER=false` 改为 `GRUB_DISABLE_OS_PROBER=false`
>
> 还需要 ***挂载所需引导的系统引导分区***

```shell
# grub-mkconfig -o /boot/grub/grub.cfg
```

> 使用 **(移动设备)U盘** 安装完成 **GRUB** 后 需要更改 */etc/mkinitcpio.conf* 
>
> ```shell
> # sed -i '/^HOOKS/s/ block//g' /etc/mkinitcpio.conf
> # sed -i '/^HOOKS/s/udev/udev block/g' /etc/mkinitcpio.conf
> ```
>
> 或 使用 *vim* 编辑 */etc/mkinitcpio.conf* 将 `HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)` 改为 `HOOKS=(base udev block autodetect modconf filesystems keyboard fsck)`

## 设置密码

设置 **root** 用户的密码

```shell
# passwd
New password:
Retype new password:
passwd: password updated successfully
```

## 完成安装

(*可选的*) **安装** *dialog* 、*wpa_supplicant* 来更好地支持 WiFi 连接

```shell
# pacman -S dialog wpa_supplicant
```

> 重启后 使用 ***wifi-menu*** 来连接 WIFI
>
> ```shell
> # wifi-menu
> ```

**卸载 挂载**

> `# umount -R /mnt`

**重启系统**

> `# reboot`

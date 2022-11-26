#!/usr/bin/env bash

#############################################################################
# auto install # echo -e -n "/dev/sda\nBIOS\n2\n" | ./install.sh [password] #
#############################################################################

mountpoint -q /mnt && echo "[*] Unmount mount point /mnt !" && umount -R /mnt

network(){
    local status=$(curl baidu.com)
    if [[ -n "$status" ]]
    then
        echo "[*] network status connecting !"
        return 0
    else
        echo "[x] network status connection failed !"
        return 1
    fi
}

exists(){
    local args=("$@") exists=()
    for arg in "${args[@]}"
    do
        if [[ -e "$arg" ]]
        then
            exists+=("$arg")
        fi
    done
    echo $((${#args[@]} - ${#exists[@]}))
}

sizeTo(){
    case $1 in
        "bit" | "Bit" | "BiT" | "BIT" )
            echo "b" ;;
        "b" | "byt" | "byte" | "bytes" | "B" | "Byt" | "Byte" | "Bytes" | "BYT" | "BYTE" | "BYTES" )
            echo "B" ;;
        "k" | "K" | "kb" | "KB" | "Kib" | "KiB" | "KIB" )
            echo "K" ;;
        "m" | "M" | "mb" | "MB" | "Mib" | "MiB" | "MIB" )
            echo "M" ;;
        "g" | "G" | "gb" | "GB" | "Gib" | "GiB" | "GIB" )
            echo "G" ;;
        "t" | "T" | "tb" | "TB" | "Tib" | "TiB" | "TIB" )
            echo "T" ;;
    esac
}

size(){
    declare -A local s=(
        ["b"]=0 ["B"]=1 ["K"]=2 ["M"]=3 ["G"]=4 ["T"]=5
    )
    local x=$(sizeTo $1) y=$(sizeTo $3) z=$2
    local mod=$(( ${s[$y]} > ${s[$x]} )) ka=${s[$y]} ea=${s[$x]}
    while (($ka != $ea))
    do
        if (($mod))
        then
            if ((ka--))
            then
                z=$(echo "$z 1024" | awk '{printf "%.16f", $1 * $2}')
            else
                z=$(echo "$z 8" | awk '{printf "%.16f", $1 * $2}')
            fi
        else
            if ((ka++))
            then
                z=$(echo "$z 1024" | awk '{printf "%.16f", $1 / $2}')
            else
                z=$(echo "$z 8" | awk '{printf "%.16f", $1 / $2}')
            fi
        fi
    done
    echo "$z" | sed 's/0\+$//g' | sed 's/\.$//g'
}

diskInfo(){
    case $2 in
        0 )
            echo $(fdisk -l | sed -n "s?Disk $1: ?&?p" | sed "s?Disk $1: ??" | sed 's/, .*//')
            ;;
        1 )
            echo $(fdisk -l | sed -n "s?Disk $1: ?&?p" | sed "s?Disk $1: ??" | sed 's/.*, //' | sed 's/ sectors//')
            ;;
    esac
}

ddOfm(){
    dd if=/dev/zero of=$1 bs=2048k count=$(($(expr $2 % 2) + $(expr $2 / 2)))
}

sizeOfUEFI="256 M"
diskOfUEFI(){
    local d=$1 s=$2
    [[ -n "$d" ]] || d=$disk
    [[ -n "$s" ]] || s=$dsm
    echo "[*] A brand new UEFI partition is starting !"
    ddOfm $d $s
    echo "[EFI] Allocate $(size m $sizeOfUEFI)M !"
    echo "[EFI] Set type to 'EFI System' !"
    echo "[SYSTEM] All the rest are allocated to the system partition !"
    echo "[SYSTEM] Allocate $(($s - $(size m $sizeOfUEFI)))M !"
    echo "[SYSTEM] Set type to 'Linux filesystem' !"
    echo -e -n "g\nn\n1\n2048\n$(($(size m $sizeOfUEFI) * 2048))\nt\n4\nn\n2\n$(($(size m $sizeOfUEFI) * 2048 + 1))\n$(($(diskInfo $d 1) - $(($(size m $sizeOfUEFI) * 2048))))\nw\n" | fdisk $d
    echo "[*] Partition complete !"
    echo "[*] Format the boot partition as 'fat' !"
    mkfs.fat -F 32 /dev/sda1
    echo "[*] Format the system partition as 'ext4' !"
    mkfs.ext4 ${d}2
    echo "[*] Formatting is complete !"
    echo "[*] Mount system partition ${d}2 !"
    mount ${d}2 /mnt
    echo "[*] Mount boot partition ${d}1 !"
    [[ -e /mnt/boot ]] || mkdir /mnt/boot -p
    mount ${d}1 /mnt/boot
}

sizeOfBIOS="2 M"
diskOfBIOS(){
    local d=$1 s=$2
    [[ -n "$d" ]] || d=$disk
    [[ -n "$s" ]] || s=$dsm
    echo "[*] A brand new BIOS partition is starting !"
    ddOfm $d $s
    echo "[BIOS] Allocate $(size m $sizeOfBIOS)M !"
    echo "[BIOS] Set type to 'BIOS boot' !"
    echo "[SYSTEM] All the rest are allocated to the system partition !"
    echo "[SYSTEM] Allocate $(($s - $(size m $sizeOfBIOS)))M !"
    echo "[SYSTEM] Set type to 'Linux filesystem' !"
    echo -e -n "g\nn\n1\n2048\n$(($(size m $sizeOfBIOS) * 2048))\nt\n4\nn\n2\n$(($(size m $sizeOfBIOS) * 2048 + 1))\n$(($(diskInfo $d 1) - $(($(size m $sizeOfBIOS) * 2048))))\nw\n" | fdisk $d
    echo "[*] Partition complete !"
    echo "[*] Format the system partition as 'ext4' !"
    mkfs.ext4 ${d}2
    echo "[*] Formatting is complete !"
    echo "[*] Mount system partition ${d}2 !"
    mount ${d}2 /mnt
}

disk=""
types=""
dsm=""
diskOf(){
    fdisk -l
    echo -n "[-] Enter your disk(eg:/dev/sda): "
    read disk
    if [[ "${disk%/*}" == "/dev" ]]
    then
        echo "[*] The input disk is '$disk'"
        if (($(exists $disk)))
        then
            echo -e "\033[31m[X] Disk '$disk' does not exist !\033[0m"
            return 0
        fi
        dsm=$(size m $(diskInfo $disk 0))
        echo "[*] The hard disk capacity is ${dsm}M !"
        echo -n "[-] Enter the type of partition(uefi,bios,diy): "
        read types
        case $types in
            "uefi" | "UEFI" )
                diskOfUEFI
                ;;
            "bios" | "BIOS" )
                diskOfBIOS
                ;;
            "diy" | "DIY" )
                ;;
        esac
    else
        return 0
    fi
    return 1
}

declare -A mirrors=(
    ["Tsinghua Open Source"]='https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch'
    ["Beijing Institute of Technology"]='https://mirror.bit.edu.cn/archlinux/$repo/os/$arch'
    ["Huawei Cloud"]='https://repo.huaweicloud.com/archlinux/$repo/os/$arch'
    ["Tencent Cloud"]='https://mirrors.cloud.tencent.com/archlinux/$repo/os/$arch'
)
mirror(){
    local mks=("${!mirrors[@]}") mvs=("${mirrors[@]}") mi=0 m=$1
    echo "++++++++++++++++++++++++++++++++++++++++++++"
    while (($mi < ${#mirrors[@]}))
    do
        printf "+ $mi | %-37s+\n" "${mks[$((mi++))]}"
    done
    echo "++++++++++++++++++++++++++++++++++++++++++++"
    echo -n "[-] Please select a mirror source: "
    [[ -n "$m" ]] || read m
    echo "[*] Use ${mks[$m]} Mirror Source !"
    sed -i "1,/Server = /s?Server = .*?Server = ${mvs[$m]}?" /etc/pacman.d/mirrorlist
}

install(){
    echo "[*] Replace it with a domestic mirror download source !"
    mirror
    echo "[*] Sync Update Mirror !"
    pacman -Syyu
    echo "[*] Install required packages !"
    pacstrap /mnt base linux linux-firmware
}

sync(){
    if (($#))
    then
        if [[ -e "$1" ]]
        then
             ln -sf $1 /etc/localtime
        fi
    fi
    timedatectl set-ntp true
}

date(){
    local task=2 path="/usr/share/zoneinfo" args=("region" "city") c
    if (($#))
    then
        path="$path/$1"
    else
        while (($task))
        do
            ls $path
            echo -n -e "[-] Enter the \033[33m${args[$(( 2 - $task))]}\033[0m to sync: "
            read c
            if [[ -e "$path/$c" ]]
            then
                path="$path/$c"
                task=$(($task - 1))
            else
                echo -e "\033[31m[x] The ${args[$((2 - $task))]} '$c' is invalid !\033[0m"
                if (($task < 2))
                then
                    task=$(($task + 1))
                fi
            fi
        done
    fi
    hwclock --systohc
    sync $path
}

chrootOf(){
    local args=("$@") password=$3 mn=$4 hostname=$5 types=$6 removable=$7 mounts=() i=7
    echo -e "\033[32m[*] Currently operating after chroot !\033[0m"
    echo "[*] Replace it with a domestic mirror download source !"
    [[ ! -n "$mn" ]] && echo -e "\033[36m[*] The optional parameter image source sequence is not selected , defaults to 3 !\033[0m" && mn=3
    [[ "$mn" == "-1" ]] || mirror $mn && mirror
    echo "[*] Set time zone !"
    date "/Asia/Shanghai"
    echo "[*] Set up localization !"
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    [[ -n "$hostname" ]] || hostname="localhost"
    echo "$hostname" > /etc/hostname
    echo "[*] Start installing *GRUB* boot !"
    echo -e -n "y\n" | pacman -S grub
    [[ ! -n "$types" ]] && echo -e "\033[36m[*] No partition type selected, defaults to 0 (BIOS) !\033[0m"  && types=0
    [[ ! -n "$removable" ]] && echo -e "\033[36m[*] Whether to install or not is not selected, the default is 0 (non-U disk installation) !\033[0m" && removable=0
    (($types)) && echo "[*] Install the dependencies required for UEFI boot !" && echo -e -n "y\n" | pacman -S efibootmgr
    if [[ $types == 1 ]]
    then
        if [[ $removable == 1 ]]
        then
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck --removable
        else
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
        fi
    else
        if [[ $removable == 1 ]]
        then
            grub-install --target=i386-pc --recheck --removable $2
        else
            grub-install --target=i386-pc --recheck $2
        fi
    fi
    if ((${#args[@]} > i))
    then
        pacman -S os-prober
        echo "[*] Set other OS to boot !"
        sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
        while ((${#args[@]} > i))
        do
            mounts+=${args[$((i++))]}
        done
        for i in "${mounts[@]}"
        do
            local uuid=$(uuidgen)
            mkdir "/mounts/$uuid" -p
            mount $i "/mounts/$uuid"
            echo "[*] Mount other system boot partitions as /mounts/$uuid !"
        done
    fi
    echo "[*] Generate GRUB main configuration file /boot/grub/grub.cfg !"
    grub-mkconfig -o /boot/grub/grub.cfg
    (($removable)) && echo "[*] Hooks when setting up mobile installs !" && sed -i '/^HOOKS/s/ block//g' /etc/mkinitcpio.conf && sed -i '/^HOOKS/s/udev/udev block/g' /etc/mkinitcpio.conf
    [[ -n "$password" ]] && echo "[*] Set the root user password !" && echo -e -n "$password\n$password\n" | passwd
	echo "[*] Install additional networking tools !"
	echo -e -n "y\n" | pacman -S dhcpcd dialog wpa_supplicant
    mountpoint -q /mnt && echo "[*] Unmount mount point /mounts/* !" && umount -R /mounts
}

if [[ -n "$1" && $1 == 1 ]]
then
    chrootOf $@
else
    network && (($?)) && exit 1
    sync
    diskOf
    install
    cp $0 /mnt
    arch-chroot /mnt /bin/bash -c "$0 1 $disk $@"
    echo "[*] Unmount all mounted partitions !"
    mountpoint -q /mnt && echo "[*] Unmount mount point /mnt !" && umount -R /mnt
fi

exit 0

#############################################################################
# auto install # echo -e -n "/dev/sda\nBIOS\n2\n" | ./install.sh [password] #
#############################################################################

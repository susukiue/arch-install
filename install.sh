#!/usr/bin/env bash

######################################################################################
# BIOS install # echo -e -n "/dev/sda\nBIOS\n2\n" | ./install.sh "[password] ... "   #
# UEFI install # echo -e -n "/dev/sda\nUEFI\n2\n" | ./install.sh "123 2 localhost 1" #
######################################################################################
###########################################################################################################################################
# custom install # /dev/sda1 [EFI] <300M> "mkfs.vfat" # /dev/sda2 [swap] <4G> "mkswap" # /dev/sda3 [ext4] <ALL> "mkfs.ext4"               #
# echo -en "/dev/sda\nDIY\ng\n1\n300\n1\n2\n4G\n19\n3\n\n\n\n3\next4\n/mnt\n1\nvfat\n/mnt/boot\n\n2\n" | ./install.sh "123 2 localhost 1" #
###########################################################################################################################################

mountpoint -q /mnt && echo "[*] Unmount mount point /mnt !" && umount -R /mnt
swapoff --all

network(){
    local status r=5
    while (($r && r--))
    do
        status="$(curl -s baidu.com)"
        [[ -n "$status" ]] \
            && echo "[*] network status connecting !" \
            && break \
            || echo "[x] network status connection failed !"
        sleep 1
    done
    return $r
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

zero(){
    local z="$1"
    z="$(echo "$z" | grep '\.[0-9]*' | sed "s/0\+$//g" | sed "s/\.0*$//g")"
    [[ -n "$z" ]] && echo "$z" || echo "$1"
}

sizeTo(){
    case $1 in
        "b" | "bit" | "Bit" | "BiT" | "BIT" )
            echo "b" ;;
        "byt" | "byte" | "bytes" | "B" | "Byt" | "Byte" | "Bytes" | "BYT" | "BYTE" | "BYTES" )
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
    (($# == 3)) || return 0
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
    echo "$(zero $z)"
}

prefix=""
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
    local x=$(echo "$2" | awk '{printf "%d", $1 % 2}') y=$(echo "$2" | awk '{printf "%d", $1 / 2}')
    dd if=/dev/zero of=$1 bs=2048k count=$(($x + $y))
}

sizeOfUEFI="256 M"
diskOfUEFI(){
    local d=$1 s=$2 p=$prefix
    [[ -n "$d" ]] || d=$disk
    [[ -n "$s" ]] || s=$dsm
    echo "[*] A brand new UEFI partition is starting !"
    ddOfm $d $s
    echo "[EFI] Allocate $(size m $sizeOfUEFI)M !"
    echo "[EFI] Set type to 'EFI System' !"
    echo "[SYSTEM] All the rest are allocated to the system partition !"
    echo "[SYSTEM] Allocate $(echo "$s $(size m $sizeOfUEFI)" | awk '{printf "%d", $1 - $2}')M !"
    echo "[SYSTEM] Set type to 'Linux filesystem' !"
    echo -e -n "g\n  \
        n\n1\n2048\n$(($(size m $sizeOfUEFI) * 2048))\nt\n1\n  \
        n\n2\n$(($(size m $sizeOfUEFI) * 2048 + 1))\n$(($(diskInfo $d 1) - $(($(size m $sizeOfUEFI) * 2048))))\n  \
        w\n" | fdisk $d
    echo "[*] Partition complete !"
    echo "[*] Format the boot partition as 'fat' !"
    mkfs.fat -F 32 "${d}${p}1"
    echo "[*] Format the system partition as 'ext4' !"
    mkfs.ext4 "${d}${p}2"
    echo "[*] Formatting is complete !"
    echo "[*] Mount system partition ${d}${p}2 !"
    mount "${d}${p}2" /mnt
    echo "[*] Mount boot partition ${d}${p}1 !"
    [[ -e /mnt/boot ]] || mkdir /mnt/boot -p
    mount "${d}${p}1" /mnt/boot
}

sizeOfBIOS="2 M"
diskOfBIOS(){
    local d=$1 s=$2 p=$prefix
    [[ -n "$d" ]] || d=$disk
    [[ -n "$s" ]] || s=$dsm
    echo "[*] A brand new BIOS partition is starting !"
    ddOfm $d $s
    echo "[BIOS] Allocate $(size m $sizeOfBIOS)M !"
    echo "[BIOS] Set type to 'BIOS boot' !"
    echo "[SYSTEM] All the rest are allocated to the system partition !"
    echo "[SYSTEM] Allocate $(echo "$s $(size m $sizeOfBIOS)" | awk '{printf "%d", $1 - $2}')M !"
    echo "[SYSTEM] Set type to 'Linux filesystem' !"
    echo -e -n "g\n  \
        n\n1\n2048\n$(($(size m $sizeOfBIOS) * 2048))\nt\n4\n  \
        n\n2\n$(($(size m $sizeOfBIOS) * 2048 + 1))\n$(($(diskInfo $d 1) - $(($(size m $sizeOfBIOS) * 2048))))\n  \
        w\n" | fdisk $d
    echo "[*] Partition complete !"
    echo "[*] Format the system partition as 'ext4' !"
    mkfs.ext4 "${d}${p}2"
    echo "[*] Formatting is complete !"
    echo "[*] Mount system partition ${d}${p}2 !"
    mount "${d}${p}2" /mnt
}

partitionTableTo(){
    case $1 in
        "g" | "G" | "gpt" | "GPT" )
            (($2)) && echo "g" || echo "GPT" ;;
        "m" | "M" | "mbr" | "MBR" )
            (($2)) && echo "o" || echo "MBR" ;;
        "i" | "I" | "irix" | "IRIX" )
            (($2)) && echo "G" || echo "SGI" ;;
        "s" | "S" | "sun" | "SUN" )
            (($2)) && echo "s" || echo "SUN" ;;
    esac
}

aext(){
    echo "$([[ -n "$1" && -n "$2" ]] && echo "+$1$2")"
}

inputToDIY(){
    local l c t s i=0 pk=() pt=() ps=()
    declare -A local p
    echo "[*] A brand new custom partition is starting !"
    ddOfm $disk $dsm
    while true
    do
        echo "[*] Choose your partition table type !"
        echo "+++++++++++++++++++++++++++++++"
        echo "| <GPT> - enter /g/gpt/G/GPT/ |"
        echo "| <MBR> - enter /g/gpt/G/GPT/ |"
        echo "+++++++++++++++++++++++++++++++"
        echo -n "[-] Select to (Enter directly to skip !): "
        read c
        [[ ! -n "$c" ]] && echo -e "\033[36m[*] Skip setting the partition type !\033[0m" && break
        [[ -n "$(partitionTableTo $c)" ]] && l="$(partitionTableTo $c 1)\n" \
            && echo "[*] The partition type is set to $(partitionTableTo $c) !" && break \
            || echo -e "\033[31m[x] Invalid input !\033[0m" && continue
    done
    while true
    do
        echo -n "[*] Create partition number (Enter directly to skip!): "
        read c
        [[ ! -n "$c" ]] && echo -e "\033[36m[*] Skip partition creation !\033[0m" && break
        [[ ! "$c" =~ ^[0-9]*$ ]] && echo -e "\033[31m[x] Invalid input !\033[0m" && continue
        [[ ! "${!pk[@]}" =~ $c ]] && echo "[*] Create a partition with sequence number $c !" && pk[$c]=${#p[@]} \
            || echo -e "\033[36m[*] The partition with sequence number $c has been recreated !\033[0m"
        p[${pk[$c]}]="n\n$c\n"
        echo -n "[-] Enter the partition size (Use : to indicate range): "
        local ts ss tss se tse
        read s
        if [[ "$s" =~ ^.*:.*$ ]]
        then
            ss=$(echo "$s" | sed "s/[A-Z|a-z]*:.*$//")
            tss=$(echo "$s" | sed "s/:.*//" | sed "s/^[0-9|.]*//")
            se=$(echo "$s" | sed "s/.*://" | sed "s/[A-Z|a-z]*$//")
            tse=$(echo "$s" | sed "s/.*://" | sed "s/^[0-9|.]*//")
            p[${pk[$c]}]+="$(($(size m $ss \
            $([[ ! -n "$tss" ]] && tss="M"; echo "$tss")) * 2048 + 2048))\n$(aext $(size m $se \
            $([[ ! -n "$tse" ]] && tse="M"; echo "$tse")) M)\n"
        else
            ts=$(echo "$s" | sed "s/^[0-9|.]*//")
            s=$(echo "$s" | sed "s/[A-z|a-z]*$//")
            p[${pk[$c]}]+="\n$(aext $(size m $s $([[ ! -n "$ts" ]] && ts="M"; echo "$ts")) M)\n"
        fi
        echo -n "[*] Set Partition Type (type code): "
        read t
        if [[ -n "$t" ]]
        then
            [[ "$t" == "19" ]] && ps+=$c
            ((${#pk[@]} > 1)) && p[${pk[$c]}]+="t\n$c\n$t\n" || p[${pk[$c]}]+="t\n$t\n"
        fi
    done
    echo "[*] Created ${#pk[@]} partitions !"
    pt=("${pk[@]}")
    while (($i < ${#pt[@]}))
    do
        l+="${p[${pt[i++]}]}"
    done
    echo -e -n "${l}w\n" | fdisk $disk
    while true
    do
        echo -n "[-] Operating partition number: "
        read c
        [[ ! -n "$c" ]] && echo -e "\033[36m[*] Skip partition operating !\033[0m" && break
        [[ ! "${!pk[@]}" =~ $c ]] && echo -e "\033[31m[x] Invalid input !\033[0m" && continue
        echo -n "[-] Format partition type: "
        read t
        [[ ! -n "$t" ]] && echo -e "\033[36m[*] Skip partition format !\033[0m" && l=0 || l=1
        (($l)) && mkfs -t "$t" "$disk$prefix$c"
        echo -n "[-] Mount point for $disk$prefix$c: "
        read t
        [[ ! -n "$t" ]] && echo -e "\033[36m[*] Skip partition mount !\033[0m" && continue
        [[ ! -e "$t" ]] && echo -e "\033[36m[x] Mount point does not exist !\033[0m" \
            && echo -e "\033[36m[*] Create directory $t !\033[0m" && mkdir -p "$t"
        mountpoint -q $t &&  umount -R $t
        mount "$disk$prefix$c" "$t"
        echo "[*] Mount $disk$prefix$c to $t !"
    done
    for number in "${ps[@]}"
    do
        echo "[*] Format swap type for $disk$prefix$number !"
        mkswap $disk$prefix$number
        echo "[*] Mount swap partition for $disk$prefix$number !"
        swapon $disk$prefix$number
    done
}

disk="" types="" dsm=""
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
                inputToDIY
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
    pacman -Syy
    echo -e -n "y\n" | pacman -S archlinux-keyring
    echo "[*] Install required packages !"
    pacstrap /mnt base linux linux-firmware
    echo -n "[*] Generate fstab file "
    genfstab -U /mnt >> /mnt/etc/fstab
    [[ -e "/mnt/etc/fstab" ]] && echo "ok !" || echo "failled !"
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
    (($mn != -1)) && mirror $mn || mirror
    echo "[*] Set time zone !"
    date "/Asia/Shanghai"
    echo "[*] Set up localization !"
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    [[ -n "$hostname" ]] || hostname="localhost"
    echo "$hostname" > /etc/hostname
    network && ((!$?)) && exit 1
    echo "[*] Start installing *GRUB* boot !"
    echo -e -n "y\n" | pacman -S grub
    [[ ! -n "$types" ]] && echo -e "\033[36m[*] No partition type selected, defaults to 0 (BIOS) !\033[0m"  && types=0
    [[ ! -n "$removable" ]] && echo -e "\033[36m[*] Whether to install or not is not selected, the default is 0 (non-U disk installation) !\033[0m" && removable=0
    network && ((!$?)) && exit 1
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
		network && ((!$?)) && exit 1
        echo -e -n "y\n" | pacman -S os-prober
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
    network && ((!$?)) && exit 1
    echo "[*] Install additional tools !"
    echo -e -n "\ny\n" | \
        pacman -S dhcpcd wpa_supplicant iwd netctl dialog wireless_tools vim openssh
    echo "[*] Setting services !"
    services
    mountpoint -q /mnt && echo "[*] Unmount mount point /mounts/* !" && umount -R /mounts
}

services(){
    systemctl enable iwd
    systemctl enable netctl
    systemctl enable sshd
}

if [[ -n "$1" && $1 == 1 ]]
then
    network && (($?)) && exit 1
    chrootOf "$@"
else
    echo "[*] Test network connecting !"
    network && ((!$?)) && exit 1 
    sync
    diskOf
    network && ((!$?)) && exit 1
    install
    network && ((!$?)) && exit 1
    cp $0 /mnt
    arch-chroot /mnt /bin/bash -c "$0 1 $disk $@"
    echo "[*] Unmount all mounted partitions !"
    mountpoint -q /mnt && echo "[*] Unmount mount point /mnt !" && umount -R /mnt
    swapoff --all
fi

exit 0

######################################################################################
# BIOS install # echo -e -n "/dev/sda\nBIOS\n2\n" | ./install.sh "[password] ... "   #
# UEFI install # echo -e -n "/dev/sda\nUEFI\n2\n" | ./install.sh "123 2 localhost 1" #
######################################################################################
###########################################################################################################################################
# custom install # /dev/sda1 [EFI] <300M> "mkfs.vfat" # /dev/sda2 [swap] <4G> "mkswap" # /dev/sda3 [ext4] <ALL> "mkfs.ext4"               #
# echo -en "/dev/sda\nDIY\ng\n1\n300\n1\n2\n4G\n19\n3\n\n\n\n3\next4\n/mnt\n1\nvfat\n/mnt/boot\n\n2\n" | ./install.sh "123 2 localhost 1" #
###########################################################################################################################################

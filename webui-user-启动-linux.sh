#!/usr/bin/env bash

cd "${PWD}/" || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd, aborting...\n\e[0m"; exit 1; }

# dialog
height=15
width=40
choose_height=4

# python3 executable
if [[ -z "${python_cmd}" ]]
then
    python_cmd="python3"
fi
if [[ -z "${pip_cmd}" ]]
then
    pip_cmd="pip"
fi
if [[ -z "${dialog_cmd}" ]]
then
    dialog_cmd="dialog"
fi

# git executable
if [[ -z "${GIT}" ]]
then
    export GIT="git"
fi

# Name of the subdirectory (defaults to stable-diffusion-webui)
if [[ -z "${clone_dir}" ]]
then
    clone_dir="stable-diffusion-webui"
fi

if [[ -z "${LAUNCH_SCRIPT}" ]]
then
    LAUNCH_SCRIPT="launch.py"
fi

# this script cannot be run as root by default
ingone_root=0

# Do not reinstall existing pip packages on Debian/Ubuntu
export PIP_IGNORE_INSTALLED=0

function setup()
{
    options=(1 "next"
             2 "exit")
    choice=$(dialog --clear \
                --backtitle "stablediffusion-webui-autoinstall" \
                --title "SETUP" \
                --menu "welcome to sdwebui install script" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         ;;
        2)
         echo canceled by user.
         exit 1
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

     options=(1 "ghproxy(recommand)"
              2 "official")
    choice=$(dialog --clear \
                --backtitle "stablediffusion-webui-autoinstall" \
                --title "SETUP" \
                --menu "select git source" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         gitsource=https://ghproxy.com/https://github.com
         ;;
        2)
         echo 2
         gitsource=https://github.com
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

    options=(1 "NVIDIA(CUDA11)"
             2 "AMD"
             3 "CPU")
    choice=$(dialog --clear \
                --backtitle "stablediffusion-webui-autoinstall" \
                --title "SETUP" \
                --menu "select pytorch type" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         torchver=nv
         ;;
        2)
         echo 2
         torchver=am
         ;;
        3)
         echo 3
         torchver=cpu
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac

    printf "\e[1m\e[34m[INFO] \e[0mInstalling...\n"

    if [[ -d stable-diffusion-webui ]]
    then
        printf "\n%s\n" "${delimiter}"
        printf "Repo already cloned, using it as install directory"
        printf "\n%s\n" "${delimiter}"
        clone_dir="${PWD}/${clone_dir}"
    else
        printf "\n%s\n" "${delimiter}"
        printf "Clone stable-diffusion-webui"
        printf "\n%s\n" "${delimiter}"
        "${GIT}" clone "${gitsource}/AUTOMATIC1111/stable-diffusion-webui.git" "${clone_dir}" || { "${GIT}" clone https://ghproxy.com/https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${clone_dir}"; }
        clone_dir="${PWD}/${clone_dir}"
    fi
    for file in ./models/*.ckpt
    do
    if [ -e "$file" ]
    then
        printf "\e[1m\e[34m[INFO] \e[0mcreating hard link %a to /stable-diffusion-webui/models/Stable-diffusion...\n" "$file"
        cp -l "$file" ./stable-diffusion-webui/models/Stable-diffusion || { printf "\e[1m\e[31m[ERROR] \e[0mCan't copy, aborting...\e[0m"; exit 1; }
    fi
    done
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd to %s/, aborting...\e[0m" "${clone_dir}"; exit 1; }
    if [ ! -s "${LAUNCH_SCRIPT}" ] 
    then
        printf "\e[1m\e[31m[ERROR] \e[0mCan't find launch script, aborting...\e[0m"
        exit 1
    fi
    printf "\e[1m\e[34m[INFO] \e[0mrunning %a...\n" "$LAUNCH_SCRIPT"
    #"${python_cmd}" "${LAUNCH_SCRIPT}" "--exit" || "${python_cmd}" "${LAUNCH_SCRIPT}" "--skip-torch-cuda-test --exit"
    printf "\e[1m\e[34m[INFO] \e[0m Install requirements...\n"
    "${python_cmd}" -m "${pip_cmd}" install --upgrade pip setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
    "${pip_cmd}" install wheel pep517 -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    "${pip_cmd}" install gdown clip -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    if [ $torchver = "nv" ]
    then
        "${pip_cmd}" install torch==1.13.1+cu117 torchvision==0.14.1+cu117 --extra-index-url https://download.pytorch.org/whl/cu117 || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    elif [ $torchver = "am" ]
    then
        "${pip_cmd}" install torch==1.13.1+rocm5.1.1 torchvision==0.14.1+rocm5.1.1 --extra-index-url https://download.pytorch.org/whl/rocm5.1.1 || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    elif [ $torchver = "cpu" ]
    then
        "${pip_cmd}" install torch==1.13.1+cpu torchvision==0.14.1+cpu --extra-index-url https://download.pytorch.org/whl/cpu -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    fi
    "${pip_cmd}" install basicsr==1.4.2 --use-pep517 -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    "${pip_cmd}" install -r requirements_versions.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
    "${pip_cmd}" install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    "${pip_cmd}" install xformers -i https://pypi.tuna.tsinghua.edu.cn/simple
    "${GIT}" clone "${gitsource}/KichangKim/DeepDanbooru.git" repositories/DeepDanbooru
    cd repositories/DeepDanbooru/ || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    "${python_cmd}" setup.py build
    "${python_cmd}" setup.py install
    cd ..
    "${GIT}" clone "${gitsource}/mlfoundations/open_clip.git" open_clip
    cd open_clip || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    "${python_cmd}" setup.py build
    "${python_cmd}" setup.py install || { printf "\e[1m\e[31m[ERROR] \e[0mInstall failed, aborting...\e[0m"; exit 1; }
    cd ..
    cd ..
    "${GIT}" clone "${gitsource}/CompVis/stable-diffusion.git" repositories/stable-diffusion
    "${GIT}" clone "${gitsource}/Stability-AI/stablediffusion.git" repositories/stable-diffusion-stability-ai
    "${GIT}" clone "${gitsource}/CompVis/taming-transformers.git" repositories/taming-transformers
    "${GIT}" clone "${gitsource}/crowsonkb/k-diffusion.git" repositories/k-diffusion
    "${GIT}" clone "${gitsource}/sczhou/CodeFormer.git" repositories/CodeFormer
    "${GIT}" clone "${gitsource}/salesforce/BLIP.git" repositories/BLIP

    options=(1 "none"
             2 "lowvram"
             3 "only CPU,whih gfx card output"
             4 "only CPU")
    choice=$(dialog --clear \
                --backtitle "stablediffusion-webui-autoinstall" \
                --title "SETUP" \
                --menu "select command args" \
                $height $width $choose_height \
                "${options[@]}" \
                2>&1 >/dev/tty)
    clear
    case $choice in
        1)
         echo 1
         method=1
         ;;
        2)
         echo 2
         method=2
         ;;
        3)
         echo 3
         method=3
         ;;
        4)
         echo 4
         method=4
         ;;
        "")
         echo canceled by user.
         exit 1
         ;;
        *) 
          echo invaild choice
          exit 1
    esac
    cd ..
    printf "[info]\r\nmethod=%s" "${method}" >>installed.ini
    printf "\e[1m\e[34m[INFO] \e[0mInstalled.\n"
}

function change_source()
{
if [ -s /etc/apt/sources.list.bak ]
then
    sudo cp /etc/apt/sources.list.bak /etc/apt/sources.list
    sudo rm -f /etc/apt/sources.list.bak
    sudo apt update
else
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
    sudo apt update
fi
}

delimiter="################################################################"

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mInstall script for stable-diffusion Web UI\n"
printf "\e[1m\e[34mTested on Ubuntu 22.04\e[0m"
printf "\n%s\n" "${delimiter}"

# if run as root
if [[ "$(id -u)" -eq "0" && ingone_root -eq "0" ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Running on \e[1m\e[32m%s\e[0m user" "$(whoami)"
    printf "\e[1m\e[33mWARN: Launched this script as root may cause bugs.\e\n[0m"
    printf "\n%s\n\n" "${delimiter}"
else
    printf "\n%s\n" "${delimiter}"
    printf "Running on \e[1m\e[32m%s\e[0m user" "$(whoami)"
    printf "\n%s\n\n" "${delimiter}"
fi

printf "\e[1m\e[33m[WARN] \e[0mNOTE:This script is in early progress,and may including bugs.\n"

printf "\e[1m\e[32m[INFO] \e[0mAccess root perm...\n"
sudo -l >/dev/null
exit_code=$?
if [ ${exit_code} -ne 0 ]
then
    printf "\e[1m\e[31m[ERROR] \e[0mAccess failed.Exiting...\n"
    exit ${exit_code}
else
    printf "\e[1m\e[32m[INFO] \e[0mAccess complete.\n"
fi


if [[ -d .git ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Running script in install directory"
    printf "\n%s\n" "${delimiter}"
    installed_script=1
else
    printf "\n%s\n" "${delimiter}"
    printf "Running script in unknown directory\n"
    printf "\e[1m\e[33mWARN: It is recommand to run in a repo directory."
    printf "\n%s\n" "${delimiter}"
    installed_script=0
fi

if [ $installed_script = "1" ]
then
printf "\e[1m\e[32m[INFO] \e[0mUpdating...\n"
"${GIT}" pull || printf "\e[1m\e[33m[WARN] \e[0mupdate failed.\n"
fi

printf "\e[1m\e[32m[INFO] \e[0mCheck program integrity...\n"
for preq in "${GIT}" "${python_cmd}" "${pip_cmd}" "${dialog_cmd}"
do
    if ! hash "${preq}" &>/dev/null
    then
        printf "\e[1m\e[33m[WARN] \e[0m%s is not installed, installing...\n" "${preq}"
        printf "       When installed failed,try sudo apt update.\n"
        sudo apt install -y "${preq}" --fix-missing
    fi
done

if [ ! -s installed.ini ] 
then
    printf "\e[1m\e[32m[INFO] \e[0mProgram is not installed,running setup...\n"
    setup
else
    method="$(sed '\/method=/!d;s/.*=//' installed.ini)"
    printf "method: %s" "${method}"
fi

if [ "$method" = "1" ]
then
ARGS=""
elif [ "$method" = "2" ]
then
ARGS="--precision full --no-half"
elif [ "$method" = "3" ]
then
ARGS="--lowvram --precision full --no-half"
elif [ "$method" = "4" ]
then
ARGS="--skip-torch-cuda-test --lowvram --precision full --no-half --disable-safe-unpickle"
fi

###############################启动参数###############################
#export PYTHON=
#export GIT=
#export VENV_DIR=
#export COMMANDLINE_ARGS=$ARGS
export INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
#####################################################################

if [[ -d stable-diffusion-webui ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "Repo already cloned, using it as install directory"
    printf "\n%s\n" "${delimiter}"
    clone_dir="${PWD}/${clone_dir}"
fi

if [[ -d "${clone_dir}" ]]
then
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m[ERROR] \e[0mCan't cd to %s/, aborting...\e[0m" "${clone_dir}"; exit 1; }
else
    exit 1
fi

if [ ! -s "${LAUNCH_SCRIPT}" ] 
then
    printf "\e[1m\e[31m[ERROR] \e[0mCan't find launch script, aborting...\e[0m"
    exit 1
fi

if [[ ! -z "${ACCELERATE}" ]] && [ "${ACCELERATE}" = "True" ] && [ -x "$(command -v accelerate)" ]
then
    printf "\n%s\n" "${delimiter}"
    printf "Accelerating launch.py..."
    printf "\n%s\n" "${delimiter}"
    exec accelerate launch --num_cpu_threads_per_process=6 "${LAUNCH_SCRIPT}" "$@"
else
    printf "\n%s\n" "${delimiter}"
    printf "Launching launch.py..."
    printf "\n%s\n" "${delimiter}"      
    exec "${python_cmd}" "${LAUNCH_SCRIPT}" "$ARGS" "$@"
fi
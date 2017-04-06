# !/bin/sh
readonly TUNNABLE_FILE=./tool/tunable/tunable_input.txt
readonly PROJ=demo/sdk_shell
ENV_FILE=./sdk_env.sh
WIN_SHARED_PATH=/mnt/hgfs/bin/

gen_env_file() {
    cat << EOF > $ENV_FILE
# Set up environment variables in order to build from IoE SDK source
# If SDK_ROOT is not set, this script must be sourced from within
# a script or from a non-login bash shell using:
#
export SDK_ROOT=\${SDK_ROOT:-\$(pwd)}
export FW=\$SDK_ROOT
export INTERNALDIR=\$FW/Internal
export SRC_IOE=\$SDK_ROOT
export IMAGEDIR=\$SRC_IOE/image
export LIBDIR=\$SRC_IOE/lib
export BINDIR=\$SRC_IOE/bin
export TOOLDIR=\$SRC_IOE/tool
export PRINTF="/usr/bin/printf"
export SDK_VERSION_IOE=REV76
export AR6002_REV7_VER=6

XTENSA_CORE=KF1_prod_rel_2012_4
XTENSA_TOOLS_ROOT=/cad/tensilica/xtensa/XtDevTools/install/tools/RD-2012.4-linux/XtensaTools
XTENSA_ROOT=/cad/tensilica/chips/kingfisher/RD-2012.4-linux/\${XTENSA_CORE}
XTENSA_SYSTEM=\${XTENSA_ROOT}/config
LM_LICENSE_FILE=/cad/tensilica/license.dat
PATH=\${PATH}:\${XTENSA_TOOLS_ROOT}/bin
export LM_LICENSE_FILE XTENSA_TOOLS_ROOT XTENSA_ROOT XTENSA_SYSTEM XTENSA_CORE PATH
export XTENSA_PREFER_LICENSE=XT-GENERIC
EOF
    chmod +x $ENV_FILE
}

gen_env_file
. ./$ENV_FILE
( make  -C $PROJ ) && {
    if [ ! -e $TUNNABLE_FILE ]; then
        cp ./tool/tunable/tunable_input_sp24X_hostless_4bitflash.txt $TUNNABLE_FILE
        echo "copy tunnable file"
    fi
    sleep 2    
    ./tool/qonstruct.sh --qons ./tool/tunable/
    tmp=$? 
    sleep 3 
    if [ "$tmp" -eq 0 ]; then
        echo "complile OK"
        echo "copy bin to win shared path $WIN_SHARED_PATH"
        cp bin/raw_flashimage_AR401X_REV6_IOT_hostless_unidev_dualband.bin  $WIN_SHARED_PATH
        exit 0
    else
        echo "complile fail $tmp\r\n"
        exit 1
    fi
}

echo "compile fail"
exit 1

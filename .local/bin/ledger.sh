#!/usr/bin/env bash

set -e
source ${HOME}/.local/bin/myEnv

getLedger() {
    ${PRIN} " %b %s ..." "${INFO}" "Downloading ledger live desktop"
        APP_REPO="https://download.live.ledger.com/${APP_LATEST}"
        wget "${APP_REPO}" -P "${APP_DIR}"/ -q || error "Couldn't download"
        chmod +x ${APP_DIR}/${APP_LATEST}
    ${PRIN} "${DONE}"
}

checkDir() {
    # Check app path
    APP_DIR="${HOME}/Apps/LedgerLive-Linux-x64"
    if [ -z "${APP_DIR}" ]; then
        ${PRIN} " %b %s !\n" "${INFO}" "Directories: ${APP_DIR} not exist"
        ${PRIN} " %b %s ..." "${INFO}" "Creating ${APP_DIR}"
            mkdir "${APP_DIR}"
        ${PRIN} "${DONE}\n"
    fi
}

checkVersion() {
    # Check latest version ledger live
    ${PRIN} " %b %s ...\n" "${INFO}" "Checking Ledger Live Desktop Version"
    # LATEST_VERSION=$(curl -sSL https://github.com/LedgerHQ/ledger-live/releases \
    # | grep '@ledgerhq/live-desktop' \
    # | awk 'FNR == 2' \
    # | cut -c 36-41
    # )
    LATEST_VERSION=$(curl -sSL https://download.live.ledger.com/latest-linux.yml \
    | awk 'FNR == 1' \
    | cut -c 10-15
    )
    ${PRIN} " %b %s %s\n" "${INFO}" "Latest Version:" "${LATEST_VERSION}"

    CURRENT_VERSION=$(which ${APP_DIR}/ledger-live-desktop* | cut -c 37-42)
    if [ -z "${CURRENT_VERSION}" ]; then
        # Downloading latest version if not exist
        ${PRIN} " %b %s !\n" "${INFO}" "Ledger live desktop not exist"
        getLedger
    elif [ "${CURRENT_VERSION}" != "${LATEST_VERSION}" ]; then
        # Updating to latest version
        ${PRIN} " %b %s !\n" "${INFO}" "Old version detected"
        getLedger
    fi
    
    APP_LATEST="${APP_DIR}/ledger-live-desktop-${LATEST_VERSION}-linux-x86_64.AppImage"
}

runMe() {
    checkDir
    checkVersion
    ${APP_LATEST}
}

installDesktop() {
    ${PRIN} " %b %s ..." "${INFO}" "Checking requirements"
    checkDir >> /dev/null
    checkVersion >> /dev/null
    ${PRIN} "${DONE}\n"

    ICON_PATH="${APP_DIR}/res/icon.png"
    if [ -z "${ICON_PATH}" ]; then
        ICON_REPO="https://www.pngaaa.com/api-download/158980"
        ${PRIN} " %b %s ..." "${INFO}" "Downloading ledger icon"
            wget -O "${ICON_PATH}" ${ICON_REPO} -q || error "Couldn't download icon"
        ${PRIN} "${DONE}\n"
    fi

    # Resize icon use imagemagick
    ${PRIN} " %b %s ..." "${INFO}" "Resize icon"
        convert -resize 160X160 "${ICON_PATH}" "${ICON_PATH}" || error "Pls install imagemagick"
    ${PRIN} "${DONE}\n"

    ${PRIN} " %b %s ..." "${INFO}" "Creating LedgerLive.desktop"
    DESK_PATH="${HOME}/.local/share/applications/LedgerLive.desktop"
    cat > "${DESK_PATH}" << EOF
[Desktop Entry]
Name=Ledger Live
Exec=${APP_LATEST}
StartupNotify=true
Terminal=false
Type=Application
Categories=Crypto Wallet
Icon=${ICON_PATH}
EOF
    ${PRIN} "${DONE}\n"
}

case "$1" in
    -r|--run)
        runMe
    ;;
    -i|--install-desktop)
        installDesktop
    ;;
    *)
    error "Invalid arguments"
    ;;
esac
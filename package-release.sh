#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_CONFIG="${SCRIPT_DIR}/build.config"

if [ -f "$BUILD_CONFIG" ]; then
    # shellcheck source=/dev/null
    source "$BUILD_CONFIG"
fi

: "${DKST_VERSION_DISPLAY:=unknown}"

SOURCE_APP="${SCRIPT_DIR}/build/DKST.app"
INSTALL_COMMAND="${SCRIPT_DIR}/install.command"
DIST_DIR="${SCRIPT_DIR}/dist"
PACKAGE_NAME="DKST-${DKST_VERSION_DISPLAY}"
PACKAGE_DIR="${DIST_DIR}/${PACKAGE_NAME}"
ZIP_PATH="${DIST_DIR}/${PACKAGE_NAME}.zip"

if [ ! -d "$SOURCE_APP" ]; then
    echo "오류: 배포할 앱을 찾을 수 없습니다."
    echo "경로 확인: $SOURCE_APP"
    echo "먼저 ./build.sh 로 Release 빌드를 생성해주세요."
    exit 1
fi

if [ ! -f "$INSTALL_COMMAND" ]; then
    echo "오류: install.command 파일을 찾을 수 없습니다."
    echo "경로 확인: $INSTALL_COMMAND"
    exit 1
fi

echo "배포 패키지 생성 중: ${PACKAGE_NAME}.zip"

rm -rf "$PACKAGE_DIR" "$ZIP_PATH"
mkdir -p "$PACKAGE_DIR"

ditto "$SOURCE_APP" "${PACKAGE_DIR}/DKST.app"
cp "$INSTALL_COMMAND" "${PACKAGE_DIR}/install.command"
chmod +x "${PACKAGE_DIR}/install.command"

(
    cd "$DIST_DIR"
    COPYFILE_DISABLE=1 zip -qry "$ZIP_PATH" "$PACKAGE_NAME"
)

echo "완료: $ZIP_PATH"
echo "압축을 푼 뒤 install.command를 실행하면 DKST.app이 설치됩니다."

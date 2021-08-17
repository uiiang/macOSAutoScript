#!/bin/bash
set -u
printf "开始安装mac os配置\n"

read -p "是否重新设置系统使用习惯(y:重新设置,其它键不设置):" sys_config
read -p "是否重新安装brew(y:安装,其它键不安装):" install_brew
read -p "是否重新安装xcode-select(y:安装,其它键不安装):" install_xcode_select
read -p "是否配置brew,npm,pip源为国内镜像(y:安装,其它键不安装):" brew_npm_pip_fast


if [[ $sys_config == "y" ]]; then
    ####### 设置mac系统使用习惯
    # Finder中显示路径栏
    defaults write com.apple.finder ShowPathbar -bool true
    # Finder中显示状态栏
    defaults write com.apple.finder ShowStatusBar -bool true
    # 访达中显示文件扩展名
    defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
    #插入新的硬盘时，不询问是否用作时间机器
    defaults write com.apple.TimeMachine "DoNotOfferNewDisksForBackup" -bool "true"
    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true && \
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true && \
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true && \
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
    # 避免在网络卷上创建 .DS_Store 文件
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    # 访达标题栏显示路径 
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES
    # 显示xcode编译时间
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
    #将程序坞位置移到屏幕左侧
    defaults write com.apple.dock "orientation" -string "right"
    #将程序坞的图标大小设置为33，默认大小为48
    defaults write com.apple.dock "tilesize" -int "33"
    #在程序坞中不显示最近使用的程序
    defaults write com.apple.dock "show-recents" -bool "false"
    #在最小化时使用缩放效果
    defaults write com.apple.dock "mineffect" -string "scale"
    #截图后创建的文件名称上加上时间
    defaults write com.apple.screencapture "include-date" -bool "true"
    killall Dock
    killall Finder
fi

##########  安装软件

if [[ $install_xcode_select == "y" ]]; then
# 安装 Xcode Command Line Tools
printf "start 安装 Xcode Command Line Tools\n"
xcode-select --install
fi

if [[ $install_brew == "y" ]]; then
    # 配置homebrew清华源
    printf "配置homebrew清华源\n"
    if [[ "$(uname -s)" == "Linux" ]]; then BREW_TYPE="linuxbrew"; else BREW_TYPE="homebrew"; fi
    export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/${BREW_TYPE}-core.git"

    # 从本镜像下载安装脚本并安装 Homebrew / Linuxbrew
    printf "安装brew\n"
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
    /bin/bash brew-install/install.sh
    rm -rf brew-install
fi

if [[ $brew_npm_pip_fast == "y" ]]; then
    git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    BREW_TAPS="$(brew tap)"
    for tap in core cask{,-fonts,-drivers,-versions} command-not-found; do
        if echo "$BREW_TAPS" | grep -qE "^homebrew/${tap}\$"; then
            # 将已有 tap 的上游设置为本镜像并设置 auto update
            # 注：原 auto update 只针对托管在 GitHub 上的上游有效
            git -C "$(brew --repo homebrew/${tap})" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git
            git -C "$(brew --repo homebrew/${tap})" config homebrew.forceautoupdate true
        else   # 在 tap 缺失时自动安装（如不需要请删除此行和下面一行）
            brew tap --force-auto-update homebrew/${tap} https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git
        fi
    done

    brew update
    printf "end brew update\n"
fi

brew analytics off
printf "start install iina\n"
brew install \
iina \
itsycal \
python \
iterm2 \
node \
appium \
gradle \
openjdk \
google-chrome \
visual-studio-code \
tencent-lemon \
free-download-manager \
android-studio \
handshaker \
switchhosts \
Anaconda \
mas \
shadowsocksx-ng-r \
wechatwebdevtools \
flutter

brew cleanup


if [[ $brew_npm_pip_fast == "y" ]]; then
    # # 设置npm国内源
    printf "设置npm国内源\n"
    npm config set registry http://registry.npm.taobao.org

    # # 设置pip国内源
    printf "设置pip国内源\n"
    pip3 install pip -U
    pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
fi

pip3 install pip -U
# # 安装pip包
pip3 install \
bs4 \
beautifulsoup4 \
peewee \
schedule

# # Install MAS Applications
mas install \
836500024 \ # 微信
497799835 \ # Xcode
1274495053 \ # Microsoft To Do
451108668 \ # QQ
1554034946 \ # Paste
789066512 \ # Maipo
425424353 # The Unarchiver
#!/bin/bash
# AutoBuild Module by Hyy2001 <https://github.com/Hyy2001X/AutoBuild-Actions>
# AutoBuild DiyScript

Firmware_Diy_Core() {

	Author=AUTO
	Author_URL=AUTO
	Default_Flag=AUTO
	Default_IP="192.168.1.199"
	Default_Title="Powered by AutoBuild-Actions"

	Short_Fw_Date=true
	x86_Full_Images=false
	Fw_Format=false
	Regex_Skip="packages|buildinfo|sha256sums|manifest|kernel|rootfs|factory|itb|profile"

	AutoBuild_Features=true
}

Firmware_Diy() {

	# 请在该函数内定制固件

	# 可用预设变量, 其他可用变量请参考运行日志
	# ${OP_AUTHOR}			OpenWrt 源码作者
	# ${OP_REPO}			OpenWrt 仓库名称
	# ${OP_BRANCH}			OpenWrt 源码分支
	# ${TARGET_PROFILE}		设备名称
	# ${TARGET_BOARD}		设备架构
	# ${TARGET_FLAG}		固件名称后缀

	# ${WORK}				OpenWrt 源码位置
	# ${CONFIG_FILE}		使用的配置文件名称
	# ${FEEDS_CONF}			OpenWrt 源码目录下的 feeds.conf.default 文件
	# ${CustomFiles}		仓库中的 /CustomFiles 绝对路径
	# ${Scripts}			仓库中的 /Scripts 绝对路径
	# ${FEEDS_LUCI}			OpenWrt 源码目录下的 package/feeds/luci 目录
	# ${FEEDS_PKG}			OpenWrt 源码目录下的 package/feeds/packages 目录
	# ${BASE_FILES}			OpenWrt 源码目录下的 package/base-files/files 目录

	case "${OP_AUTHOR}/${OP_REPO}:${OP_BRANCH}" in
	coolsnowwolf/lede:master)
		rm -r $(PKG_Finder d "package feeds" luci-theme-argon)
		sed -i "s?/bin/login?/usr/libexec/login.sh?g" ${FEEDS_PKG}/ttyd/files/ttyd.config
		
		AddPackage git lean luci-theme-argon jerrykuku 18.06
		AddPackage git lean luci-app-argon-config jerrykuku master
		AddPackage svn other luci-app-smartdns immortalwrt/luci/branches/openwrt-18.06/applications
		sed -i 's/..\/..\//\$\(TOPDIR\)\/feeds\/luci\//g' $(PKG_Finder d package luci-app-smartdns)/Makefile
		AddPackage svn other luci-app-eqos immortalwrt/luci/branches/openwrt-18.06/applications
		sed -i 's/..\/..\//\$\(TOPDIR\)\/feeds\/luci\//g' $(PKG_Finder d package luci-app-eqos)/Makefile
		AddPackage svn other luci-app-socat immortalwrt/luci/branches/openwrt-18.06/applications
		sed -i 's/..\/..\//\$\(TOPDIR\)\/feeds\/luci\//g' $(PKG_Finder d package luci-app-socat)/Makefile
		AddPackage git other OpenClash vernesong master
		AddPackage git other luci-app-ikoolproxy iwrt main
		AddPackage git other helloworld fw876 master
		sed -i 's/143/143,8080,8443/' $(PKG_Finder d package luci-app-ssr-plus)/root/etc/init.d/shadowsocksr

		patch < ${CustomFiles}/Patches/fix_shadowsocksr_alterId.patch -p1 -d ${WORK}
		patch < ${CustomFiles}/Patches/fix_ntfs3_conflict_with_antfs.patch -p1 -d ${WORK}
		patch < ${CustomFiles}/Patches/fix_aria2_auto_create_download_path.patch -p1 -d ${WORK}

		case "${TARGET_PROFILE}" in
		d-team_newifi-d2)
			Copy ${CustomFiles}/${TARGET_PROFILE}_system ${BASE_FILES}/etc/config system
			sed -i "/DEVICE_COMPAT_VERSION := 1.1/d" target/linux/ramips/image/mt7621.mk
			Copy ${CustomFiles}/Depends/automount $(PKG_Finder d "package" automount)/files 15-automount
			patch < ${CustomFiles}/d-team_newifi-d2_mt76_dualband.patch -p1 -d ${WORK}
		;;
		xiaoyu_xy-c5)
			Copy ${CustomFiles}/Depends/automount $(PKG_Finder d "package" automount)/files 15-automount
		;;
		x86_64)
			AddPackage git passwall-depends openwrt-passwall xiaorouji packages
			AddPackage git passwall-luci openwrt-passwall xiaorouji luci
			rm -rf packages/lean/autocore
			AddPackage git lean autocore-modify Hyy2001X master
			# cat ${CustomFiles}/${TARGET_PROFILE}_kExtra >> ${WORK}/target/linux/x86/config-5.15
			sed -i -- 's:/bin/ash:'/bin/bash':g' ${BASE_FILES}/etc/passwd
			cat ${CustomFiles}/${TARGET_PROFILE}_kExtra >> ${WORK}/target/linux/x86/config-5.18
			patch < ${CustomFiles}/Patches/upgrade_intel_igpu_drv.patch -p1 -d ${WORK}
			sed -i 's/1.2021.35/2022.03.02/g' feeds/packages/net/smartdns/Makefile
                        sed -i 's/f50e4dd0813da9300580f7188e44ed72a27ae79c/1fd18601e7d8ac88e8557682be7de3dc56e69105/g' feeds/packages/net/smartdns/Makefile
                        sed -i 's/^PKG_MIRROR_HASH/#&/' feeds/packages/net/smartdns/Makefile
		;;
		hiwifi_hc5861)
			AddPackage git passwall-depends openwrt-passwall xiaorouji packages
			AddPackage git passwall-luci openwrt-passwall xiaorouji luci
			rm -rf packages/lean/autocore
			AddPackage git lean autocore-modify Hyy2001X master
		;;
		hiwifi_hc5962)
			AddPackage git passwall-depends openwrt-passwall xiaorouji packages
			AddPackage git passwall-luci openwrt-passwall xiaorouji luci
			rm -rf packages/lean/autocore
			AddPackage git lean autocore-modify Hyy2001X master
		;;
		esac
	;;
	immortalwrt/immortalwrt*)
		sed -i "s?/bin/login?/usr/libexec/login.sh?g" ${FEEDS_PKG}/ttyd/files/ttyd.config
	;;
	esac
}

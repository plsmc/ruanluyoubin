include $(TOPDIR)/rules.mk

PKG_NAME:=radar-raw1-sender
PKG_RELEASE:=2

include $(INCLUDE_DIR)/package.mk

define Package/radar-raw1-sender
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Radar RAW1 sender service placeholder
  DEPENDS:=+libc +libgcc +luci-base
endef

define Package/radar-raw1-sender/description
  Captures IPv4 UDP frames and forwards them to radar-go over RAW1 TCP.
endef

define Build/Compile
endef

define Package/radar-raw1-sender/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config $(1)/etc/uci-defaults \
		$(1)/usr/lib/lua/luci/controller \
		$(1)/usr/share/luci/view
	$(INSTALL_BIN) ./files/usr/bin/radar-raw1-sender $(1)/usr/bin/
	$(INSTALL_BIN) ./files/usr/bin/radar-raw1-update $(1)/usr/bin/
	$(INSTALL_BIN) ./files/etc/init.d/radar-raw1-sender $(1)/etc/init.d/
	$(INSTALL_CONF) ./files/etc/config/radar-raw1-sender $(1)/etc/config/
	$(INSTALL_BIN) ./files/etc/uci-defaults/99-radar-capture $(1)/etc/uci-defaults/
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/radar_update.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DATA) ./files/usr/share/luci/view/radar_update.htm $(1)/usr/share/luci/view/
endef

$(eval $(call BuildPackage,radar-raw1-sender))

WLAN_CHIPSET := qca_cld3

PRODUCT_PACKAGES += \
	wpa_supplicant_overlay.conf \
	p2p_supplicant_overlay.conf \
	wificond \
	wifilogd

#Disable CNSS_CLI
TARGET_NO_USE_CNSS_CLI := true

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
	frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
	frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml


######## For multiple ko support ########

# whether to load/unload wlan driver dynamically
PRODUCT_WLAN_DRIVER_ALWAYS_LOADED := true

# WLAN driver configuration file
ifeq ($(strip $(shell expr $(words $(strip $(TARGET_WLAN_CHIP))) \>= 2)), 1)
PRODUCT_COPY_FILES += \
$(foreach chip, $(TARGET_WLAN_CHIP), \
    device/qcom/wlan/sm6150_au/WCNSS_qcom_cfg_$(chip).ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/$(chip)/WCNSS_qcom_cfg.ini)
else
TARGET_WLAN_CHIP := wlan
PRODUCT_COPY_FILES += \
    device/qcom/wlan/sm6150_au/WCNSS_qcom_cfg.ini:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/WCNSS_qcom_cfg.ini
endif

PRODUCT_PACKAGES += $(foreach chip, $(TARGET_WLAN_CHIP), $(WLAN_CHIPSET)_$(chip).ko)

ifeq ($(PRODUCT_WLAN_DRIVER_ALWAYS_LOADED), true)
# this script will set the property 'ro.vendor.wlan.chip' when boot completed,
# which will trigger wlan driver loading.
PRODUCT_PACKAGES += init.qcom.wlan.sh
PRODUCT_COPY_FILES += \
    device/qcom/wlan/sm6150_au/init.qcom.wlan.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.qcom.wlan.sh
endif

PRODUCT_PACKAGES += ctrlapp_dut

# AOSP: interface combinations
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{AP}, 1}, {{P2P}, 1}},\
                                   {{{STA}, 1}, {{NAN}, 1}}, \
                                   {{{STA}, 2}, {{AP}, 1}}, \
                                   {{{STA}, 1}, {{AP}, 2}}

# Override WLAN configurations
# # Usage:
# # To disable WLAN_CFG_1/WLAN_CFG_3 and enable WLAN_CFG_2 for <wlan_chip>
# # (<wlan_chip> is from $TARGET_WLAN_CHIP).
# #   WLAN_CFG_OVERRIDE_<wlan_chip> := WLAN_CFG_1=n WLAN_CFG_2=y WLAN_CFG_3=n
WLAN_CFG_OVERRIDE_qca6174 := CONFIG_AR6320_SUPPORT=y
WLAN_CFG_OVERRIDE_qca6390 := CONFIG_FEATURE_COEX=y CONFIG_QCACLD_FEATURE_BTC_CHAIN_MODE=y
WLAN_CFG_OVERRIDE_qcn7605 := CONFIG_FEATURE_COEX=y CONFIG_QCACLD_FEATURE_BTC_CHAIN_MODE=y CONFIG_GET_DRIVER_MODE=y

# Enable vendor properties.
PRODUCT_PROPERTY_OVERRIDES += \
	wifi.aware.interface=wifi-aware0

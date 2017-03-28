PRODUCT_BRAND ?= OwnROM

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
 # determine the smaller dimension
 TARGET_BOOTANIMATION_SIZE := $(shell \
   if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
     echo $(TARGET_SCREEN_WIDTH); \
   else \
     echo $(TARGET_SCREEN_HEIGHT); \
   fi )
 
 # get a sorted list of the sizes
 bootanimation_sizes := $(subst .zip,, $(shell ls vendor/ownrom/bootanimation))
 bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)
 
 # find the appropriate size and set
 define check_and_set_bootanimation
 $(eval TARGET_BOOTANIMATION_NAME := $(shell \
   if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
     if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
       echo $(1); \
       exit 0; \
     fi;
   fi;
   echo $(TARGET_BOOTANIMATION_NAME); ))
 endef
 $(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))
 
 PRODUCT_BOOTANIMATION := vendor/ownrom/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
 
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Hassium.ogg

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Custom Prebuilt OwnROM Packages
PRODUCT_COPY_FILES += \
vendor/ownrom/prebuilt/apps/Amaze.apk:system/priv-app/Amaze/Amaze.apk

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/ownrom/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/ownrom/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/ownrom/prebuilt/common/bin/blacklist:system/addon.d/blacklist

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/ownrom/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# init.d support
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/ownrom/prebuilt/common/bin/sysinit:system/bin/sysinit

ifneq ($(TARGET_BUILD_VARIANT),user)
# userinit support
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit
endif

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/common/lib/content-types.properties:system/lib/content-types.properties

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is OwnROM!
PRODUCT_COPY_FILES += \
    vendor/ownrom/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Include OwnROM audio files
include vendor/ownrom/config/cm_audio.mk

# Theme engine
include vendor/ownrom/config/themes_common.mk

ifneq ($(TARGET_DISABLE_CMSDK), true)

# CMSDK
include vendor/ownrom/config/cmsdk_common.mk
endif

# Required OwnROM packages
PRODUCT_PACKAGES += \
    BluetoothExt \
    CMAudioService \
    CMParts \
    Development \
    Profiles \
    WeatherManagerService

# Optional OwnROM packages
PRODUCT_PACKAGES += \
    libemoji \
    LiveWallpapersPicker \
    PhotoTable \
    Terminal

# Include explicitly to work around GMS issues
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full \
    librsjni

# Custom OwnROM packages
PRODUCT_PACKAGES += \
    AudioFX \
    CMSettingsProvider \
    CustomTiles \
    Eleven \
    ExactCalculator \
    LiveLockScreenService \
    LockClock \
    ThemeInterfacer \
    Trebuchet \
    WallpaperPicker \
    WeatherProvider

# Exchange support
PRODUCT_PACKAGES += \
    Exchange2

# Extra tools in OwnROM
PRODUCT_PACKAGES += \
    7z \
    bash \
    bzip2 \
    curl \
    fsck.ntfs \
    gdbserver \
    htop \
    lib7z \
    libsepol \
    micro_bench \
    mke2fs \
    mkfs.ntfs \
    mount.ntfs \
    oprofiled \
    pigz \
    powertop \
    sqlite3 \
    strace \
    tune2fs \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Magisk Manager
PRODUCT_PACKAGES += \
    MagiskManager

# Copy Magisk zip
PRODUCT_COPY_FILES += \
    vendor/ownrom/prebuilt/zips/magisk.zip:system/addon.d/magisk.zip
    
# Custom off-mode charger
ifneq ($(WITH_CM_CHARGER),false)
PRODUCT_PACKAGES += \
    charger_res_images \
    cm_charger_res_images \
    font_log.png \
    libhealthd.cm
endif

# ExFAT support
WITH_EXFAT ?= true
ifeq ($(WITH_EXFAT),true)
TARGET_USES_EXFAT := true
PRODUCT_PACKAGES += \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat
endif

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# Storage manager
PRODUCT_PROPERTY_OVERRIDES += \
    ro.storage_manager.enabled=true

# Telephony
PRODUCT_PACKAGES += \
    telephony-ext

PRODUCT_BOOT_JARS += \
    telephony-ext

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank

# Conditionally build in su
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

DEVICE_PACKAGE_OVERLAYS += vendor/ownrom/overlay/common

OWNROM_BUILDTYPE ?= UNOFFICIAL
 OWN_VERSION := 4.0
OWNROM_VERSION := $(OWNROM_BUILDTYPE)-v$(OWN_VERSION)-$(OWNROM_BUILD)-$(shell date +%Y%m%d)

OWNROM_DISPLAY_VERSION := $(OWNROM_BUILDTYPE)-$(OWN_VERSION)-$(shell date +%Y%m%d)

PRODUCT_PROPERTY_OVERRIDES += \
	ro.own.version=$(OWN_VERSION) \
    ro.ownrom.version=$(OWNROM_VERSION) \
    ro.ownrom.releasetype=$(OWNROM_BUILDTYPE) \
    ro.modversion=$(OWNROM_VERSION) \
    ro.ownrom.display.version=$(OWNROM_DISPLAY_VERSION) \
    ro.cmlegal.url=https://lineageos.org/legal


PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/ownrom/build/target/product/security/lineage

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/ownrom/config/partner_gms.mk
-include vendor/cyngn/product.mk

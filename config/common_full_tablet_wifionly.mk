# Inherit common OwnROM stuff
$(call inherit-product, vendor/ownrom/config/common_full.mk)

# Required OwnROM packages
PRODUCT_PACKAGES += \
    LatinIME

# Include OwnROM LatinIME dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/ownrom/overlay/dictionaries

# Default notification/alarm sounds
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.notification_sound=Argon.ogg \
    ro.config.alarm_alert=Helium.ogg

ifeq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
    PRODUCT_COPY_FILES += \
        vendor/ownrom/prebuilt/common/bootanimation/800.zip:system/media/bootanimation.zip
endif

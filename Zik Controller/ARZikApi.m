//
//  ZikApi.m
//  Zik Controller
//
//  Created by Rui Araújo on 14/09/14.
//  Copyright (c) 2014 Rui Araújo. All rights reserved.
//

#import "ARZikApi.h"

NSString *const BATTERY_GET = @"/api/system/battery/get";
NSString *const VERSION_GET = @"/api/software/version/get";
NSString *const CONCERT_HALL_ANGLE_GET = @"/api/audio/sound_effect/angle/get";
NSString *const CONCERT_HALL_ANGLE_SET = @"/api/audio/sound_effect/angle/set";
NSString *const CONCERT_HALL_ENABLED_GET = @"/api/audio/sound_effect/enabled/get";
NSString *const CONCERT_HALL_ENABLED_SET = @"/api/audio/sound_effect/enabled/set";
NSString *const CONCERT_HALL_GET = @"/api/audio/sound_effect/get";
NSString *const CONCERT_HALL_ROOM_GET = @"/api/audio/sound_effect/room_size/get";
NSString *const CONCERT_HALL_ROOM_SET = @"/api/audio/sound_effect/room_size/set";
NSString *const EQUALIZER_ENABLED_GET = @"/api/audio/equalizer/enabled/get";
NSString *const EQUALIZER_ENABLED_SET = @"/api/audio/equalizer/enabled/set";
NSString *const EQUALIZER_GET = @"/api/audio/equalizer/get";
NSString *const EQUALIZER_PRESETS_LIST_GET = @"/api/audio/equalizer/presets_list/get";
NSString *const EQUALIZER_PRESET_ID_GET = @"/api/audio/equalizer/preset_id/get";
NSString *const EQUALIZER_PRESET_ID_SET = @"/api/audio/equalizer/preset_id/set";
NSString *const EQUALIZER_PRESET_VALUE_GET = @"/api/audio/equalizer/preset_value/get";
NSString *const EQUALIZER_PRESET_VALUE_SET = @"/api/audio/equalizer/preset_value/set";
NSString *const FRIENDLY_NAME_GET = @"/api/bluetooth/friendlyname/get";
NSString *const FRIENDLY_NAME_SET = @"/api/bluetooth/friendlyname/set";
NSString *const NOISE_CANCELLATION_ENABLED_GET = @"/api/audio/noise_cancellation/enabled/get";
NSString *const NOISE_CANCELLATION_ENABLED_SET = @"/api/audio/noise_cancellation/enabled/set";
NSString *const SOUND_EFFECT_ENABLED_GET = @"/api/audio/specific_mode/enabled/get";
NSString *const SOUND_EFFECT_ENABLED_SET = @"/api/audio/specific_mode/enabled/set";
NSString *const SYSTEM_ANC_PHONE_MODE_GET = @"/api/system/anc_phone_mode/enabled/get";
NSString *const SYSTEM_ANC_PHONE_MODE_SET = @"/api/system/anc_phone_mode/enabled/set";
NSString *const SYSTEM_AUTO_CONNECTION_GET = @"/api/system/auto_connection/enabled/get";
NSString *const SYSTEM_AUTO_CONNECTION_SET = @"/api/system/auto_connection/enabled/set";
NSString *const SYSTEM_AUTO_POWER_OFF_GET = @"/api/system/auto_power_off/get";
NSString *const SYSTEM_AUTO_POWER_OFF_SET = @"/api/system/auto_power_off/set";
NSString *const SYSTEM_AUTO_POWER_OFF_LIST_GET = @"/api/system/auto_power_off/presets_list/get";
NSString *const SYSTEM_HEAD_DETECTION_ENABLED_GET = @"/api/system/head_detection/enabled/get";
NSString *const SYSTEM_HEAD_DETECTION_ENABLED_SET = @"/api/system/head_detection/enabled/set";

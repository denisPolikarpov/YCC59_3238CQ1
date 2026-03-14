#include "YCC59_3238CQ1.h"

const u8 PROG_DATA_START_ADDR  = 0x04;
const u8 TR_EN_OTHER_ADDR      = 0x18;
const u8 SELFTEST_START_ADDR   = 0x19;

channel_settings_ts channel_settings[5] = {0};

u32 MEM_START_ADDRESS = 0;

union {
    u8 word;
    struct {
        u8 EN        : 1;  // 0 - 0
        u8 TR1       : 1;  // 1 - 1
        u8 TR2       : 1;  // 2 - 2
        u8 SelfTest  : 1;  // 3 - 3
        u8 StartProg : 1;  // 4 - 4
        u8 Init      : 1;  // 5 - 5
        u8 reserved  : 2;  // 7 - 6
    } fields;
    
} word_for_ctrl = {0};

// Сюда надо передать адрес внутренней памяти модуля програмирующего микруху
void init_ycc59_3238cq1(u32 mem_start_address) {
    MEM_START_ADDRESS = mem_start_address;
    word_for_ctrl.fields.Init = 0x01;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
}

// Передаёт в память настройки из массива chan_sets
void set_settings_for_all_channels(channel_settings_ts chan_sets[5]) {
    for (int i = 0; i < 5; i++) {
        channel_settings[i] = chan_sets[i];
    }
}

// Устанавливает настройки для конкретного канал (от 1 до 5)
void set_settings_for_channel(u8 channel_num, channel_settings_ts chan_sets) {
    channel_settings[channel_num - 1] = chan_sets;
}

// Возвращает настройки для конкретного канала (от 1 до 5)
channel_settings_ts get_settings_for_channel(u8 channel_num) {
    return channel_settings[channel_num - 1];
}

// Устанавливает значения для TR1
void set_TR1_value (u8 TR_state) {
    word_for_ctrl.fields.TR1 = TR_state & 0x01;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
}

// Устанавливает значения для TR2
void set_TR2_value (u8 TR_state) {
    word_for_ctrl.fields.TR2 = TR_state & 0x01;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
}

// Устанавливает значения для EN
void set_EN_value (u8 EN_state) {
    word_for_ctrl.fields.EN = EN_state & 0x01;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
}

// Запрограмировать YCC59_3238CQ1
void start_programming () {
    word_for_ctrl.fields.StartProg = 0x01;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
    usleep(1);
    word_for_ctrl.fields.StartProg = 0x00;
    Xil_Out8(MEM_START_ADDRESS + TR_EN_OTHER_ADDR, word_for_ctrl.word);
}
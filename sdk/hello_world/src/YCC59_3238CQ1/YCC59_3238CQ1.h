
#include <stdio.h>
#include "sleep.h"

typedef struct {
    u8 AT;
    u8 AR;
    u8 PT;
    u8 PR;
    u8 MCT;
    u8 MCR;
} channel_settings_ts;

// Сюда надо передать адрес внутренней памяти модуля програмирующего микруху
// И запуск YCC59_3238CQ1
void init_ycc59_3238cq1(u32 mem_start_address);

// Передаёт в память настройки из массива chan_sets
void set_settings_for_all_channels(channel_settings_ts chan_sets[5]);

// Устанавливает настройки для конкретного канал (от 1 до 5)
void set_settings_for_channel(u8 channel_num, channel_settings_ts chan_sets);

// Возвращает настройки для конкретного канала (от 1 до 5)
channel_settings_ts get_settings_for_channel(u8 channel_num);

// Устанавливает значения для TR1
void set_TR1_value (u8 TR_state);

// Устанавливает значения для TR2 
void set_TR2_value (u8 TR_state);

// Устанавливает значения для EN
void set_EN_value (u8 EN_state);

// Запрограмировать YCC59_3238CQ1
void start_programming ();
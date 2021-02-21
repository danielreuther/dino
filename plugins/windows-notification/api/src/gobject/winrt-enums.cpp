#include "winrt-enums.h"

#define WINRT_GLIB_DEFINE_ENUM_VALUE(value,nick) \
  { value, #value, nick },

#define WINRT_GLIB_DEFINE_ENUM_TYPE(TypeName,type_name,values) \
GType \
type_name ## _get_type (void) \
{ \
  static volatile gsize g_define_id__volatile = 0; \
  if (g_once_init_enter (&g_define_id__volatile)) \
    { \
      static const GEnumValue v[] = { \
        values \
        { 0, NULL, NULL }, \
      }; \
      GType g_define_id = g_enum_register_static (g_intern_static_string (#TypeName), v); \
      g_once_init_leave (&g_define_id__volatile, g_define_id); \
    } \
  return g_define_id__volatile; \
}

WINRT_GLIB_DEFINE_ENUM_TYPE (WinrtDismissedReason, winrt_dismissed_reason,
  WINRT_GLIB_DEFINE_ENUM_VALUE (WINRT_DISMISSED_REASON_ACTIVATED, "activated")
  WINRT_GLIB_DEFINE_ENUM_VALUE (WINRT_DISMISSED_REASON_APPLICATION_HIDDEN, "application-hidden")
  WINRT_GLIB_DEFINE_ENUM_VALUE (WINRT_DISMISSED_REASON_TIMED_OUT, "timed-out"))
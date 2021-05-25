#ifndef WMAP_GLOBAL_H
#define WMAP_GLOBAL_H

#include <QtCore/qglobal.h>

#if defined(WMAP_LIBRARY)
#  define WMAPSHARED_EXPORT Q_DECL_EXPORT
#else
#  define WMAPSHARED_EXPORT Q_DECL_IMPORT
#endif

#endif // WMAP_GLOBAL_H

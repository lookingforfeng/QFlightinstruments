/*****************************************************************************************
* @file
*
* @warning Copyright (C), 2015-2019, Chengdu HaiQing Information Technologies Co., Ltd.
*
* @brief 定义导出api接口符号
*
* @author dujz
*
* @date 2019/12/25
*
****************************************************************************************/
#ifndef TPE_CORE_EXTERN_H
#define TPE_CORE_EXTERN_H

#define DEMEXPORT __declspec(dllexport)
#define DEMIMPORT __declspec(dllimport)

#if defined(DEM_CORE_DLL)
#define DEM_CORE_API DEMEXPORT
#else
#define DEM_CORE_API DEMIMPORT
#endif
#else
#define DEM_CORE_API


#endif // TPE_CORE_EXTERN_H
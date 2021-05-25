#pragma once
#include "extern.h"
#include "DemDriverType.h"
#include <string>

/**
* @brief 初始化,注册指定GDAL文件驱动
* @param[in] type 驱动类型ID，参考文件DemDriverType.h
* @param[in] demFilePath 高程数据文件保存路径. 需带'/'结尾
* @return
* @throw 错误会抛出异常，带异常信息
*/
void DEM_CORE_API HQDTEDReader_init(HQDTEDReader::eDriverType type, std::string demFilePath /* = "" */)throw(std::exception);

/**
* @brief 获取高程值
* @param[in] longitude 经度
* @param[in] latitude 纬度
* @return 高程值[-32767, 32767]
*/
short DEM_CORE_API HQDTEDReader_getAltitude(double longitude, double latitude)throw(std::exception);

/**
* @brief 获取高程数据保存路径
* @return 绝对路径
*/
std::string DEM_CORE_API HQDTEDReader_getDemFilePath();

/**
* @brief 设置保存高程数据路径
* @param[in] DemFilePath 高程数据保存绝对路径
* @return
*/
void DEM_CORE_API HQDTEDReader_setDemFilePath(std::string path);

/**
* @brief 释放模块
* @return
*/
void DEM_CORE_API HQDTEDReader_release();
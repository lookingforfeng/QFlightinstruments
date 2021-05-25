#pragma once
#include "extern.h"
#include "DemDriverType.h"
#include <string>

/**
* @brief ��ʼ��,ע��ָ��GDAL�ļ�����
* @param[in] type ��������ID���ο��ļ�DemDriverType.h
* @param[in] demFilePath �߳������ļ�����·��. ���'/'��β
* @return
* @throw ������׳��쳣�����쳣��Ϣ
*/
void DEM_CORE_API HQDTEDReader_init(HQDTEDReader::eDriverType type, std::string demFilePath /* = "" */)throw(std::exception);

/**
* @brief ��ȡ�߳�ֵ
* @param[in] longitude ����
* @param[in] latitude γ��
* @return �߳�ֵ[-32767, 32767]
*/
short DEM_CORE_API HQDTEDReader_getAltitude(double longitude, double latitude)throw(std::exception);

/**
* @brief ��ȡ�߳����ݱ���·��
* @return ����·��
*/
std::string DEM_CORE_API HQDTEDReader_getDemFilePath();

/**
* @brief ���ñ���߳�����·��
* @param[in] DemFilePath �߳����ݱ������·��
* @return
*/
void DEM_CORE_API HQDTEDReader_setDemFilePath(std::string path);

/**
* @brief �ͷ�ģ��
* @return
*/
void DEM_CORE_API HQDTEDReader_release();
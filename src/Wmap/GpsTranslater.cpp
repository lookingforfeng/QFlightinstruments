#include "GpsTranslater.h"

GpsTranslater::GpsTranslater(QObject *parent)
	: QObject(parent)
{
}

GpsTranslater::~GpsTranslater()
{
}

bool GpsTranslater::gps84_To_Gcj02(const double& lat_wgs84, const double& lon_wgs84, double& lat_gcj, double& lon_gcj)
{
	if (outOfChina(lat_wgs84, lon_wgs84)) {
		lat_gcj = 0;
		lon_gcj = 0;
        return false;
	}
	double dLat = transformLat(lon_wgs84 - 105.0, lat_wgs84 - 35.0);
	double dLon = transformLon(lon_wgs84 - 105.0, lat_wgs84 - 35.0);
	double radLat = lat_wgs84 / 180.0 * pi;
	double magic = qSin(radLat);
	magic = 1 - ee * magic * magic;
	double sqrtMagic = qSqrt(magic);
	dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
	dLon = (dLon * 180.0) / (a / sqrtMagic * qCos(radLat) * pi);
	lat_gcj = lat_wgs84 + dLat;
	lon_gcj = lon_wgs84 + dLon;
    return true;
}

bool GpsTranslater::gcj_To_Gps84(const double& lat_gcj, const double& lon_gcj, double& lat_wgs84, double& lon_wgs84)
{
	double lat_temp, lon_temp;
    if (outOfChina(lat_gcj, lon_gcj)) {
        lat_wgs84 = lat_gcj;
        lon_wgs84 = lon_gcj;
        return false;
    }
	transform(lat_gcj, lon_gcj, lat_temp, lon_temp);
	lon_wgs84 = lon_gcj * 2 - lon_temp;
	lat_wgs84 = lat_gcj * 2 - lat_temp;
    return true;
}

bool GpsTranslater::outOfChina(double lat, double lon)
{
	if (lon < 72.004 || lon > 137.8347)
		return true;
	if (lat < 0.8293 || lat > 55.8271)
		return true;
	return false;
}

double GpsTranslater::transformLat(double x, double y)
{
	double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y
		+ 0.2 * qSqrt(qAbs(x));
	ret += (20.0 * qSin(6.0 * x * pi) + 20.0 * qSin(2.0 * x * pi)) * 2.0 / 3.0;
	ret += (20.0 * qSin(y * pi) + 40.0 * qSin(y / 3.0 * pi)) * 2.0 / 3.0;
	ret += (160.0 * qSin(y / 12.0 * pi) + 320 * qSin(y * pi / 30.0)) * 2.0 / 3.0;
	return ret;
}

double GpsTranslater::transformLon(double x, double y)
{
	double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1
		* qSqrt(qAbs(x));
	ret += (20.0 * qSin(6.0 * x * pi) + 20.0 * qSin(2.0 * x * pi)) * 2.0 / 3.0;
	ret += (20.0 * qSin(x * pi) + 40.0 * qSin(x / 3.0 * pi)) * 2.0 / 3.0;
	ret += (150.0 * qSin(x / 12.0 * pi) + 300.0 * qSin(x / 30.0
		* pi)) * 2.0 / 3.0;
	return ret;
}

void GpsTranslater::transform(const double& lat_in, const double& lon_in, double& lat_out, double& lon_out)
{
	if (outOfChina(lat_in, lon_in)) {
		lat_out = 0;
		lon_out = 0;
		return;
	}
	double dLat = transformLat(lon_in - 105.0, lat_in - 35.0);
	double dLon = transformLon(lon_in - 105.0, lat_in - 35.0);
	double radLat = lat_in / 180.0 * pi;
	double magic = qSin(radLat);
	magic = 1 - ee * magic * magic;
	double sqrtMagic = qSqrt(magic);
	dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
	dLon = (dLon * 180.0) / (a / sqrtMagic * qCos(radLat) * pi);
	lat_out = lat_in + dLat;
	lon_out = lon_in + dLon;
}

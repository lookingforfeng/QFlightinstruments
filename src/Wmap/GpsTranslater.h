#ifndef GpsTranslater_h_
#define  GpsTranslater_h_

#include <QObject>
#include <QtMath>

const QString BAIDU_LBS_TYPE = "bd09ll";

const double pi = 3.1415926535897932384626;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;

class GpsTranslater : public QObject
{
	Q_OBJECT

public:
	GpsTranslater(QObject *parent);
	~GpsTranslater();

	/**
	* 84 to 火星坐标系 (GCJ-02) World Geodetic System ==> Mars Geodetic System
	* @param lat
	* @param lon
	* @return
	*/
    static bool gps84_To_Gcj02(const double& lat_wgs84, const double& lon_wgs84, double& lat_gcj, double& lon_gcj);

	/**
	* 火星坐标系 (GCJ-02) to 84 
	* @param lon 
	* @param lat 
	* @return
	*/
    static bool gcj_To_Gps84(const double& lat_gcj, const double& lon_gcj, double& lat_wgs84, double& lon_wgs84);

private:
	static bool outOfChina(double lat, double lon);
	static double transformLat(double x, double y);
	static double transformLon(double x, double y);
	static void transform(const double& lat_in, const double& lon_in, double& lat_out, double& lon_out);
};
#endif

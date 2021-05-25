#ifndef WMAP_H
#define WMAP_H

#include <QtCore/qglobal.h>
#include <QWidget>
#include "DemReader/Include/DemDriverType.h"
#include <QGeoCoordinate>
#include <QQuickItem>

#if defined(WMAP_LIBRARY)
#  define WMAPSHARED_EXPORT Q_DECL_EXPORT
#include <QQuickItem>
#else
//#  define WMAPSHARED_EXPORT Q_DECL_IMPORT
#  define WMAPSHARED_EXPORT 
#endif

class QGCMapPolygon;
typedef QMap<QString, QVariant> OverLay;
static OverLay default_overlay;

const bool is_maptype_gcj=false;

namespace Ui {
	class Wmap;
}

class WMAPSHARED_EXPORT Wmap : public QWidget
{
	Q_OBJECT

public:
	explicit Wmap(QWidget *parent = 0);
	~Wmap();

	//-----------------------------------------API_begin

    ///
    /// \brief addMarker 向地图中添加图标,可自定义图案
    /// \param name  图标的唯一指代名称，和后续的删除图标的参数必须相同，所以不能重名，重名会收到marker_error信号
    /// \param image_file  图标的唯一指代名称，和后续的删除图标的参数必须相同，所以不能重名，重名会收到marker_error信号
    /// \param lat  纬度
    /// \param lng  经度
    /// \param color  颜色
    /// \param overlay  图层
    ///
	void addMarker(const QString& name, const QString& image_file, const double& lat,
		const double& lng, const QString& color, OverLay& overlay = default_overlay);

	///
	/// \brief addMarker  向地图中添加带编号的图标
	/// \param name
	/// \param index
	/// \param lat
	/// \param lng
	/// \param color      必须以类似  #fcff00   这样的形式
	///
	void addMarker(const QString& name, const int& index, const double& lat,
		const double& lng, const QString& color, OverLay& overlay = default_overlay);

	///
	/// \brief addTextMarker   添加文字显示
	/// \param name
	/// \param text
	/// \param lat
	/// \param lng
	/// \param color
	///
	void addTextMarker(const QString&name, const QString&text, const double&lat, const double&lng,
		const QString&color, OverLay& overlay = default_overlay);

	///
	/// \brief addLine   增加一条空白航线，通过addLine_point（）逐渐增加航点，通过deleteMarker（）删除整条航线
	/// \param name
	/// \param line_width
	/// \param line_color
	///
	QVariant addLine(const QString&name, const double&line_width,
		const QString&line_color, OverLay& overlay = default_overlay);

	///
	/// \brief addLine_point  向航线上增加航点
	/// \param name           航线名字
	/// \param lat
	/// \param lng
	///
	void addLine_point(const QString&name, const double&lat, const double&lng, OverLay& overlay = default_overlay);
	void addLine_point(QVariant line_obj, const double&lat, const double&lng, OverLay& overlay = default_overlay);

	/// version2
	/// \brief deleteLine_point
	/// \param name
	/// \param lat
	/// \param lng
	///
	void deleteLine_point(const QString&name, const double&lat, const double&lng, OverLay& overlay = default_overlay);

	///
	/// \brief addRegion   增加空的多边形区域
	/// \param name
	/// \param border_width
	/// \param border_color
	/// \param fill_color
	/// \param fill_opacity
	///
	void addRegion(const QString&name, const double&border_width, const QString&border_color,
		QString&fill_color, const double&fill_opacity, OverLay& overlay = default_overlay);

	///
	/// \brief addRegion_point  向多边形区域中增加控制点
	/// \param name
	/// \param lat
	/// \param lng
	///
	void addRegion_point(const QString&name, const double&lat, const double&lng, OverLay& overlay = default_overlay);

	///
	/// \brief Wmap::rotateMarker   旋转指定图标，正北为0，顺时针为正，单位为度
	/// \param name
	/// \param angle
	///
	void  rotateMarker(const QString &name, const double &angle, OverLay& overlay = default_overlay);

	///
	/// \brief deleteMarker 删除地图上指定图标
	/// \param name         图标名，见addMarker的name参数
	///
	void deleteMarker(const QString& name, OverLay& overlay = default_overlay);

	///
	/// \brief setMapCenter 设置地图中心点位置
	/// \param lat
	/// \param lng
	///
	void setMapCenter(const double& lat, const double& lng);

	///
	/// \brief getMapCenter   获取地图中心，返回MapCenter信号
	/// \param lat
	/// \param lng
	///
	void getMapCenter(double *lat, double *lng);

	///
	/// \brief setZoomLevel  设置地图的缩放级别，级别越大表示越大，配合getZoomLevel一起使用
	///
	void setZoomLevel(double zoomlevel);

	///
	/// \brief getZoomLevel  获取地图的缩放级别
	/// \return
	///
	double getZoomLevel();

	///
	/// \brief addRectangle   增加一个矩形显示
	/// \param name
	/// \param lat1           左上角
	/// \param lng1
	/// \param lat2           右下角
	/// \param lng2
	/// \param borer_width    边框
	/// \param border_color
	/// \param fill_color     底纹——颜色
	/// \param fill_opacity   底纹——透明度       范围是0-1
	///
	void addRectangle(const QString &name, const double&lat1, const double&lng1, const double&lat2, \
		const double&lng2, const double&borer_width, const QString &border_color, \
		const QString &fill_color, const double&fill_opacity, OverLay& overlay = default_overlay);

	///
	/// \brief Wmap::addCircle   增加圆形显示
	/// \param name
	/// \param lat
	/// \param lng
	/// \param radius
	/// \param borer_width
	/// \param border_color
	/// \param fill_color
	/// \param fill_opacity
	///
	void addCircle(const QString &name, const double&lat, const double&lng, const double&radius, \
		const double&borer_width, const QString &border_color, const QString &fill_color, \
		const double&fill_opacity, OverLay& overlay = default_overlay);

	/// version2
	/// \brief moveMarker
	/// \param name
	/// \param lat
	/// \param lng
	///
	void moveMarker(const QString &name, const double &lat, const double &lng, OverLay& overlay = default_overlay);


	///
	/// \brief setMapType
	/// \param type_num  地图类型：1--街道地图，0--卫星地图，2--混合地图  其余数字会报错
	///
	void  setMapType(const int& type_num);

	///
	///\brief deleteAllMarker 删除所有图标
	///
	void deleteAllMarker(OverLay& overlay = default_overlay);

	void setMarkerHighlight(const QString &name, bool highlight, const QString& color, OverLay& overlay = default_overlay);

	//通过gdal获取高程接口
	/**
	* @brief 初始化,注册指定GDAL文件驱动
	* @param[in] type 驱动类型ID，参考文件DemDriverType.h
	* @param[in] demFilePath 高程数据文件保存路径. 需带'/'结尾
	* @return
	* @throw 错误会抛出异常，带异常信息
	*/
	void DTEDReader_init(HQDTEDReader::eDriverType type, std::string demFilePath)throw(std::exception);

	/**
	* @brief 获取高程值
	* @param[in] longitude 经度
	* @param[in] latitude 纬度
	* @return 高程值[-32767, 32767]
	*/
	short  DTEDReader_getAltitude(double longitude, double latitude)throw(std::exception);

	/**
	* @brief 获取高程数据保存路径
	* @return 绝对路径
	*/
	std::string DTEDReader_getDemFilePath();

	/**
	* @brief 设置保存高程数据路径
	* @param[in] DemFilePath 高程数据保存绝对路径
	* @return
	*/
	void DTEDReader_setDemFilePath(std::string path);

	/**
	* @brief 释放模块
	* @return
	*/
	void DTEDReader_release();

	/**
	 * @brief 显示多边形区域（可改变范围）
	 * @ret
	 */
	void showPolygon();

	/**
	* @brief 隐藏多边形区域（可改变范围）
	* @ret
	*/
	void hidePolygon();

	/**
	* @brief 获取多边形的各个顶点
	* @ret
	*/
	QList<QGeoCoordinate> coordinateList();

	/**
	 * @brief 设置地图整体偏转
	 */
	void setBearing(double bearing);

	//-----------------------------------------API_end
signals:
	void msgFromQml(QString);
	void map_error(QString);
	void measure_distance(double);          //地图测量后，会通过此信号返回测量值
	void clicked_Point(double lat, double lng);  //增加航点后，此信号返回坐标
	void measure_angle(double);
	void marker_clicked(double, double, QString);
	void marker_position_changed(double, double, QString);
	void mapCenterChanged(double lat, double lng);

	private slots:
	void deal_clicked_Point(double lat, double lng); 
	void deal_marker_clicked(double lat, double lng , QString);
	void deal_marker_position_changed(double lat , double lng, QString);
	void deal_mapCenterChanged(double lat, double lng);

private:
	Ui::Wmap *ui;

	bool DuplicationCheck(OverLay& overlay, QString name);

	QQuickItem *map_root_item;
	QMap<QString, QGCMapPolygon *> _mapPolygon;

	QMap<QString, OverLay> overlays_;

    void adaptMapCoordinateSys_input(double& lat,double& lng);
    void adaptMapCoordinateSys_output(double& lat,double& lng);
};

#endif // WMAP_H

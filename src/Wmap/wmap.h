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
    /// \brief addMarker ���ͼ�����ͼ��,���Զ���ͼ��
    /// \param name  ͼ���Ψһָ�����ƣ��ͺ�����ɾ��ͼ��Ĳ���������ͬ�����Բ����������������յ�marker_error�ź�
    /// \param image_file  ͼ���Ψһָ�����ƣ��ͺ�����ɾ��ͼ��Ĳ���������ͬ�����Բ����������������յ�marker_error�ź�
    /// \param lat  γ��
    /// \param lng  ����
    /// \param color  ��ɫ
    /// \param overlay  ͼ��
    ///
	void addMarker(const QString& name, const QString& image_file, const double& lat,
		const double& lng, const QString& color, OverLay& overlay = default_overlay);

	///
	/// \brief addMarker  ���ͼ����Ӵ���ŵ�ͼ��
	/// \param name
	/// \param index
	/// \param lat
	/// \param lng
	/// \param color      ����������  #fcff00   ��������ʽ
	///
	void addMarker(const QString& name, const int& index, const double& lat,
		const double& lng, const QString& color, OverLay& overlay = default_overlay);

	///
	/// \brief addTextMarker   ���������ʾ
	/// \param name
	/// \param text
	/// \param lat
	/// \param lng
	/// \param color
	///
	void addTextMarker(const QString&name, const QString&text, const double&lat, const double&lng,
		const QString&color, OverLay& overlay = default_overlay);

	///
	/// \brief addLine   ����һ���հ׺��ߣ�ͨ��addLine_point���������Ӻ��㣬ͨ��deleteMarker����ɾ����������
	/// \param name
	/// \param line_width
	/// \param line_color
	///
	QVariant addLine(const QString&name, const double&line_width,
		const QString&line_color, OverLay& overlay = default_overlay);

	///
	/// \brief addLine_point  ���������Ӻ���
	/// \param name           ��������
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
	/// \brief addRegion   ���ӿյĶ��������
	/// \param name
	/// \param border_width
	/// \param border_color
	/// \param fill_color
	/// \param fill_opacity
	///
	void addRegion(const QString&name, const double&border_width, const QString&border_color,
		QString&fill_color, const double&fill_opacity, OverLay& overlay = default_overlay);

	///
	/// \brief addRegion_point  ���������������ӿ��Ƶ�
	/// \param name
	/// \param lat
	/// \param lng
	///
	void addRegion_point(const QString&name, const double&lat, const double&lng, OverLay& overlay = default_overlay);

	///
	/// \brief Wmap::rotateMarker   ��תָ��ͼ�꣬����Ϊ0��˳ʱ��Ϊ������λΪ��
	/// \param name
	/// \param angle
	///
	void  rotateMarker(const QString &name, const double &angle, OverLay& overlay = default_overlay);

	///
	/// \brief deleteMarker ɾ����ͼ��ָ��ͼ��
	/// \param name         ͼ��������addMarker��name����
	///
	void deleteMarker(const QString& name, OverLay& overlay = default_overlay);

	///
	/// \brief setMapCenter ���õ�ͼ���ĵ�λ��
	/// \param lat
	/// \param lng
	///
	void setMapCenter(const double& lat, const double& lng);

	///
	/// \brief getMapCenter   ��ȡ��ͼ���ģ�����MapCenter�ź�
	/// \param lat
	/// \param lng
	///
	void getMapCenter(double *lat, double *lng);

	///
	/// \brief setZoomLevel  ���õ�ͼ�����ż��𣬼���Խ���ʾԽ�����getZoomLevelһ��ʹ��
	///
	void setZoomLevel(double zoomlevel);

	///
	/// \brief getZoomLevel  ��ȡ��ͼ�����ż���
	/// \return
	///
	double getZoomLevel();

	///
	/// \brief addRectangle   ����һ��������ʾ
	/// \param name
	/// \param lat1           ���Ͻ�
	/// \param lng1
	/// \param lat2           ���½�
	/// \param lng2
	/// \param borer_width    �߿�
	/// \param border_color
	/// \param fill_color     ���ơ�����ɫ
	/// \param fill_opacity   ���ơ���͸����       ��Χ��0-1
	///
	void addRectangle(const QString &name, const double&lat1, const double&lng1, const double&lat2, \
		const double&lng2, const double&borer_width, const QString &border_color, \
		const QString &fill_color, const double&fill_opacity, OverLay& overlay = default_overlay);

	///
	/// \brief Wmap::addCircle   ����Բ����ʾ
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
	/// \param type_num  ��ͼ���ͣ�1--�ֵ���ͼ��0--���ǵ�ͼ��2--��ϵ�ͼ  �������ֻᱨ��
	///
	void  setMapType(const int& type_num);

	///
	///\brief deleteAllMarker ɾ������ͼ��
	///
	void deleteAllMarker(OverLay& overlay = default_overlay);

	void setMarkerHighlight(const QString &name, bool highlight, const QString& color, OverLay& overlay = default_overlay);

	//ͨ��gdal��ȡ�߳̽ӿ�
	/**
	* @brief ��ʼ��,ע��ָ��GDAL�ļ�����
	* @param[in] type ��������ID���ο��ļ�DemDriverType.h
	* @param[in] demFilePath �߳������ļ�����·��. ���'/'��β
	* @return
	* @throw ������׳��쳣�����쳣��Ϣ
	*/
	void DTEDReader_init(HQDTEDReader::eDriverType type, std::string demFilePath)throw(std::exception);

	/**
	* @brief ��ȡ�߳�ֵ
	* @param[in] longitude ����
	* @param[in] latitude γ��
	* @return �߳�ֵ[-32767, 32767]
	*/
	short  DTEDReader_getAltitude(double longitude, double latitude)throw(std::exception);

	/**
	* @brief ��ȡ�߳����ݱ���·��
	* @return ����·��
	*/
	std::string DTEDReader_getDemFilePath();

	/**
	* @brief ���ñ���߳�����·��
	* @param[in] DemFilePath �߳����ݱ������·��
	* @return
	*/
	void DTEDReader_setDemFilePath(std::string path);

	/**
	* @brief �ͷ�ģ��
	* @return
	*/
	void DTEDReader_release();

	/**
	 * @brief ��ʾ��������򣨿ɸı䷶Χ��
	 * @ret
	 */
	void showPolygon();

	/**
	* @brief ���ض�������򣨿ɸı䷶Χ��
	* @ret
	*/
	void hidePolygon();

	/**
	* @brief ��ȡ����εĸ�������
	* @ret
	*/
	QList<QGeoCoordinate> coordinateList();

	/**
	 * @brief ���õ�ͼ����ƫת
	 */
	void setBearing(double bearing);

	//-----------------------------------------API_end
signals:
	void msgFromQml(QString);
	void map_error(QString);
	void measure_distance(double);          //��ͼ�����󣬻�ͨ�����źŷ��ز���ֵ
	void clicked_Point(double lat, double lng);  //���Ӻ���󣬴��źŷ�������
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

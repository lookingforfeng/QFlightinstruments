#ifndef GpsTranslaterTEST_h_
#define GpsTranslaterTEST_h_

#include <QObject>
#include <QTest>

class GpsTranslaterTEST : public QObject
{
	Q_OBJECT

public:
	GpsTranslaterTEST(QObject *parent);
	~GpsTranslaterTEST();

	private slots:
	void testTranslate_wgs84_to_gcj();
};

#endif

/********************************************************************************
** Form generated from reading UI file 'wmap.ui'
**
** Created by: Qt User Interface Compiler version 5.9.9
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_WMAP_H
#define UI_WMAP_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QWidget>
#include "QtQuickWidgets/QQuickWidget"

QT_BEGIN_NAMESPACE

class Ui_Wmap
{
public:
    QHBoxLayout *horizontalLayout;
    QQuickWidget *quickWidget;

    void setupUi(QWidget *Wmap)
    {
        if (Wmap->objectName().isEmpty())
            Wmap->setObjectName(QStringLiteral("Wmap"));
        Wmap->resize(577, 472);
        horizontalLayout = new QHBoxLayout(Wmap);
        horizontalLayout->setObjectName(QStringLiteral("horizontalLayout"));
        quickWidget = new QQuickWidget(Wmap);
        quickWidget->setObjectName(QStringLiteral("quickWidget"));
        quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);

        horizontalLayout->addWidget(quickWidget);


        retranslateUi(Wmap);

        QMetaObject::connectSlotsByName(Wmap);
    } // setupUi

    void retranslateUi(QWidget *Wmap)
    {
        Wmap->setWindowTitle(QApplication::translate("Wmap", "Form", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class Wmap: public Ui_Wmap {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_WMAP_H

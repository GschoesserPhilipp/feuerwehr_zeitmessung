#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "BleHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<BleHandler>("feuerwehr_zeitmessung", 1, 0, "BleHandler");

    QQmlApplicationEngine engine;


    const QUrl url("qrc:/feuerwehr_zeitmessung/qml/Main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}

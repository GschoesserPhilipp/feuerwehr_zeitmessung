#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "BleHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<BleHandler>("Ble", 1, 0, "BleHandler");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("ble_test", "Main");

    return app.exec();
}

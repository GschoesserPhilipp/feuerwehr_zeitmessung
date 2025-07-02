#ifndef BLUETOOTHHANDLER_H
#define BLUETOOTHHANDLER_H

#include <QObject>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QLowEnergyCharacteristic>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QStringList>


class BleHandler : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariant devicesList READ devicesList NOTIFY devicesListChanged)
    Q_PROPERTY(QStringList groupList READ groupList NOTIFY groupListChanged)

public:
    explicit BleHandler(QObject *parent = nullptr);
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    QVariantList devicesList();
    QStringList groupList() const;

    Q_INVOKABLE void connectToDevice(const QString &address);
    Q_INVOKABLE void disconnectFromDevice();
    Q_INVOKABLE void sendBool();
    Q_INVOKABLE void readGroups();



signals:
    void deviceFound(QString name, QString address);
    void devicesListChanged();

    void connected();
    void disconnected();
    void timeReceived(uint value);
    void messageReceived(QString value);
    void valueReceived(QString value);
    void groupListChanged();



private slots:
    void deviceDiscovered(const QBluetoothDeviceInfo &info);
    void addDevice(const QBluetoothDeviceInfo &info);
    void clearDevices();

    void serviceDiscovered(const QBluetoothUuid &service);
    void serviceScanDone();
    void controllerConnected();
    void controllerDisconnected();
    void controllerError(QLowEnergyController::Error error);
    void serviceStateChanged(QLowEnergyService::ServiceState s);
    void characteristicChanged(const QLowEnergyCharacteristic &c, const QByteArray &value);
    QLowEnergyController* createControllerForAddress(const QString &address);
    void characteristicUpdated(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void characteristicRead(const QLowEnergyCharacteristic &c, const QByteArray &value);
    void onControllerStateChanged(QLowEnergyController::ControllerState newState);


private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
    QLowEnergyController *controller;
    QLowEnergyService *service;
    QLowEnergyCharacteristic timeChar;
    QLowEnergyCharacteristic controlChar;
    QLowEnergyCharacteristic groupChar;
    QVariantList m_devices;
    QStringList m_groupList;
};

#endif // BLUETOOTHHANDLER_H

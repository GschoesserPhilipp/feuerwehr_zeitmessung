#include "BleHandler.h"



BleHandler::BleHandler(QObject *parent) : QObject(parent) {
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &BleHandler::deviceDiscovered);

}

void BleHandler::startScan() {
    qDebug() << "Start Scan";
    clearDevices();
    discoveryAgent->start();
}

void BleHandler::stopScan() {
    discoveryAgent->stop();
    qDebug() << "Stop Scan";
}

void BleHandler::deviceDiscovered(const QBluetoothDeviceInfo &info) {
    addDevice(info);  // Fügt das Gerät zur Liste hinzu
    emit deviceFound(info.name(), info.address().toString());
}


QVariantList BleHandler::devicesList() {
    return m_devices;
}

void BleHandler::addDevice(const QBluetoothDeviceInfo &info) {
    // Überprüfen, ob das Gerät BLE (Bluetooth Low Energy) unterstützt
    if (!(info.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration)) {
        qDebug() << "Kein BLE-Gerät: " << info.name() << info.address().toString();
        return; // Wenn das Gerät kein BLE-Gerät ist, überspringe es
    }

    QVariantMap device;
    device["name"] = info.name();
    device["address"] = info.address().toString();

    // Vermeide Duplikate
    for (const auto &d : std::as_const(m_devices)) {
        if (d.toMap()["address"] == device["address"]) {
            return;
        }
    }

    m_devices.append(device);
    emit devicesListChanged();
    qDebug() << "BLE-Gerät hinzugefügt: " << device["name"] << device["address"];
}

void BleHandler::clearDevices() {
    m_devices.clear();
    emit devicesListChanged();
}


QLowEnergyController* BleHandler::createControllerForAddress(const QString &address) {
    for (const QBluetoothDeviceInfo &info : discoveryAgent->discoveredDevices()) {
        if (info.address().toString() == address) {
            return QLowEnergyController::createCentral(info, this);
        }
    }
    return nullptr;
}

void BleHandler::connectToDevice(const QString &address) {
    controller = createControllerForAddress(address);
    if (!controller) {
        qDebug() << "Kein passendes Gerät gefunden zum Verbinden.";
        return;
    }

    connect(controller, &QLowEnergyController::connected, this, &BleHandler::controllerConnected);
    connect(controller, &QLowEnergyController::disconnected, this, &BleHandler::controllerDisconnected);
    connect(controller, &QLowEnergyController::errorOccurred, this, &BleHandler::controllerError);
    connect(controller, &QLowEnergyController::serviceDiscovered, this, &BleHandler::serviceDiscovered);
    connect(controller, &QLowEnergyController::discoveryFinished, this, &BleHandler::serviceScanDone);

    connect(service, &QLowEnergyService::characteristicRead, this, &BleHandler::characteristicRead);


    qDebug() << "Versuche Verbindung zu Gerät: " << address;
    controller->connectToDevice();
    stopScan();


}

// Diese Methode trennt die Verbindung zum Gerät
void BleHandler::disconnectFromDevice() {
    if (controller) {
        controller->disconnectFromDevice();
        qDebug() << "Disconnected from device.";
    }
}



void BleHandler::serviceDiscovered(const QBluetoothUuid &serviceUuid) {
    qDebug() << "Service gefunden:" << serviceUuid;
}

void BleHandler::serviceScanDone() {
    qDebug() << "Service-Scan abgeschlossen";

    // Beispiel: Ersten Service auswählen
    QList<QBluetoothUuid> services = controller->services();
    if (services.isEmpty()) {
        qDebug() << "Keine Services gefunden.";
        return;
    }

    service = controller->createServiceObject(services.first(), this);
    if (!service) {
        qDebug() << "Service-Objekt konnte nicht erstellt werden.";
        return;
    }

    connect(service, &QLowEnergyService::stateChanged, this, &BleHandler::serviceStateChanged);
    service->discoverDetails();
}

void BleHandler::serviceStateChanged(QLowEnergyService::ServiceState s) {
    if (s != QLowEnergyService::RemoteServiceDiscovered)
        return;

    qDebug() << "Service vollständig entdeckt.";

    const QList<QLowEnergyCharacteristic> chars = service->characteristics();
    for (const auto &c : chars) {
        qDebug() << "Gefundene Charakteristik UUID:" << c.uuid().toString() << "Name:" << c.name();

        // Überprüfe, ob die UUID der Charakteristik mit der gewünschten übereinstimmt
        if (c.uuid().toString() == "{19b10001-e8f2-537e-4f6c-d104768a1214}") {
            timeChar = c;
        }

        // Neue Bedingung für die "write" fähige Charakteristik (Bool senden)
        if (c.uuid().toString() == "{19b10012-e8f2-537e-4f6c-d104768a1214}") {
            controlChar = c;  // Zuweisung der Charakteristik für das Senden von Daten
        }

        if (c.uuid().toString() == "{19b10011-e8f2-537e-4f6c-d104768a1214}") {
            groupChar = c;  // <-- GRUPPEN-CHARAKTERISTIK speichern
        }


    }

    if (!timeChar.isValid()) {
        qDebug() << "Ziel-Charakteristik nicht gefunden.";
        return;
    }

    if (!controlChar.isValid()) {
        qDebug() << "Control-Charakteristik nicht gefunden!";
        return;
    }

    if (!groupChar.isValid()) {
        qDebug() << "Gruppen Charakteristik nicht gefunden!";
    }

    // CCCD manuell angeben
    QLowEnergyDescriptor notifyDesc = timeChar.descriptor(QUuid("00002902-0000-1000-8000-00805f9b34fb"));
    if (notifyDesc.isValid()) {
        service->writeDescriptor(notifyDesc, QByteArray::fromHex("0100")); // Benachrichtigungen aktivieren
    }

    connect(service, &QLowEnergyService::characteristicChanged, this, &BleHandler::characteristicUpdated);
}


void BleHandler::characteristicUpdated(const QLowEnergyCharacteristic &c, const QByteArray &value) {
    qDebug() << "Charakteristik aktualisiert:" << c.uuid().toString() << "Wert:" << value.toHex();

        if (value.size() >= 4) {  // Wenn die Größe der empfangenen Daten mindestens 4 Bytes beträgt
            // Little Endian Interpretation der ersten vier Bytes
            uint32_t number = (static_cast<uint8_t>(value[3]) << 24) |
                              (static_cast<uint8_t>(value[2]) << 16) |
                              (static_cast<uint8_t>(value[1]) << 8) |
                              static_cast<uint8_t>(value[0]);

            // Zahl als QString senden
            emit valueReceived(QString::number(number));
        }
}

void BleHandler::characteristicRead(const QLowEnergyCharacteristic &c, const QByteArray &value) {
    if (c.uuid().toString() != "{19b10001-e8f2-537e-4f6c-d104768a1214}")
        return;

    QString data = QString::fromUtf8(value);
    QStringList gruppen = data.split(";", Qt::SkipEmptyParts);

    if (gruppen != m_groupList) {
        m_groupList = gruppen;
        emit groupListChanged();
    }

    qDebug() << "Gruppen empfangen:" << gruppen;
}

void BleHandler::controllerConnected() {
    qDebug() << "Controller connected!";
    controller->discoverServices();

}


// Diese Methode wird aufgerufen, wenn die Verbindung getrennt wurde
void BleHandler::controllerDisconnected() {
    qDebug() << "BLE-Verbindung wurde getrennt (vermutlich abgebrochen).";

    emit disconnected();
}

// Diese Methode wird aufgerufen, wenn ein Fehler beim Controller auftritt
void BleHandler::controllerError(QLowEnergyController::Error error) {
    qDebug() << "Controller error:" << error;
}

void BleHandler::onControllerStateChanged(QLowEnergyController::ControllerState newState) {
    if (newState == QLowEnergyController::ConnectedState) {
        qDebug() << "Gerät erfolgreich verbunden!";
        emit connected();  // Benutzerdefiniertes Signal für erfolgreiche Verbindung
    }
    else if (newState == QLowEnergyController::UnconnectedState) {
        qDebug() << "Verbindung verloren!";
        emit disconnected();  // Benutzerdefiniertes Signal für Trennung
    }
}


// Diese Methode wird aufgerufen, wenn sich die Werte einer Characteristic ändern
void BleHandler::characteristicChanged(const QLowEnergyCharacteristic &characteristic, const QByteArray &value) {
    qDebug() << "Characteristic" << characteristic.uuid() << "changed to" << value;
    emit valueReceived(value);
}

void BleHandler::sendBool() {
    if (controlChar.isValid()) {
        QByteArray value;
        value.append('\x01');  // Angenommener Wert für true als Byte
        service->writeCharacteristic(controlChar, value);
    } else {
        qDebug() << "Control-Charakteristik nicht gültig!";
    }
}

void BleHandler::readGroups() {
    if (!groupChar.isValid()) {
        qDebug() << "Gruppen-Charakteristik nicht gültig!";
        return;
    }
    service->readCharacteristic(groupChar);
}

QStringList BleHandler::groupList() const {
    return m_groupList;
}

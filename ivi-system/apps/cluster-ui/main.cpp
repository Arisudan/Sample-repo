#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QTimer>
#include <QUdpSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <vsomeip/vsomeip.hpp>
#include <thread>
#include <iostream>
#include <mutex>
#include <cmath>

// --- Cluster Adapter Hardened Class ---
class ClusterAdapter : public QObject {
    Q_OBJECT
    
    // Vehicle State
    Q_PROPERTY(double vehicleSpeed READ vehicleSpeed NOTIFY vehicleSpeedChanged)
    Q_PROPERTY(double engineRpm READ engineRpm NOTIFY engineRpmChanged)
    Q_PROPERTY(double fuelLevel READ fuelLevel NOTIFY fuelLevelChanged)
    Q_PROPERTY(double coolantTemp READ coolantTemp NOTIFY coolantTempChanged)
    
    // Signals
    Q_PROPERTY(QString gear READ gear NOTIFY gearChanged)
    Q_PROPERTY(bool leftIndicator READ leftIndicator NOTIFY leftIndicatorChanged)
    Q_PROPERTY(bool rightIndicator READ rightIndicator NOTIFY rightIndicatorChanged)
    Q_PROPERTY(bool handbrake READ handbrake NOTIFY handbrakeChanged)
    Q_PROPERTY(bool seatbelt READ seatbelt NOTIFY seatbeltChanged)
    Q_PROPERTY(bool battery READ battery NOTIFY batteryChanged)
    Q_PROPERTY(bool engineWarn READ engineWarn NOTIFY engineWarnChanged)
    Q_PROPERTY(bool fog READ fog NOTIFY fogChanged)
    Q_PROPERTY(bool highBeam READ highBeam NOTIFY highBeamChanged)

    // Navigation
    Q_PROPERTY(bool navActive READ navActive NOTIFY navActiveChanged)
    Q_PROPERTY(QString nextTurn READ nextTurn NOTIFY nextTurnChanged)
    Q_PROPERTY(double nextTurnDistance READ nextTurnDistance NOTIFY nextTurnChanged)

public:
    ClusterAdapter(QObject *parent = nullptr) 
        : QObject(parent), 
          m_speed(0), m_rpm(0), m_fuel(0.8), m_temp(90.0),
          m_gear("P"), m_left(false), m_right(false),
          m_handbrake(false), m_seatbelt(true), m_battery(false),
          m_engine(false), m_fog(false), m_highBeam(false),
          m_navActive(false), m_turnDist(0)
    {
        // Debug/Test Harness Socket (UDP 12345)
        m_udpSocket = new QUdpSocket(this);
        if(m_udpSocket->bind(QHostAddress::LocalHost, 12345)) {
            connect(m_udpSocket, &QUdpSocket::readyRead, this, &ClusterAdapter::onUdpMessage);
            std::cout << "[ClusterAdapter] Listening on UDP 12345 for Test Harness..." << std::endl;
        }
    }

    // Getters
    double vehicleSpeed() const { return m_speed; }
    double engineRpm() const { return m_rpm; }
    double fuelLevel() const { return m_fuel; }
    double coolantTemp() const { return m_temp; }
    QString gear() const { return m_gear; }
    bool leftIndicator() const { return m_left; }
    bool rightIndicator() const { return m_right; }
    bool handbrake() const { return m_handbrake; }
    bool seatbelt() const { return m_seatbelt; }
    bool battery() const { return m_battery; }
    bool engineWarn() const { return m_engine; }
    bool fog() const { return m_fog; }
    bool highBeam() const { return m_highBeam; }
    bool navActive() const { return m_navActive; }
    QString nextTurn() const { return m_turnInstruction; }
    double nextTurnDistance() const { return m_turnDist; }

    // Q_INVOKABLE Methods (Callbacks from QML)
    Q_INVOKABLE void setGear(const QString &g) {
        if(m_gear != g) {
            std::cout << "[ClusterAdapter] Request setGear: " << g.toStdString() << std::endl;
            m_gear = g; 
            emit gearChanged();
            // TODO: sending payload to vsomeip if writable service exists
        }
    }

    Q_INVOKABLE void toggleLeftIndicator() {
        m_left = !m_left; 
        if(m_left) m_right = false; 
        emit leftIndicatorChanged(); 
        emit rightIndicatorChanged();
        std::cout << "[ClusterAdapter] Toggle Left Indicator: " << m_left << std::endl;
    }
    
    Q_INVOKABLE void toggleRightIndicator() {
        m_right = !m_right;
        if(m_right) m_left = false; 
        emit rightIndicatorChanged(); 
        emit leftIndicatorChanged(); 
        std::cout << "[ClusterAdapter] Toggle Right Indicator: " << m_right << std::endl;
    }

    // internal setters (thread safe via meta object if needed, or simple atomic)
    // Using invokeMethod in loop ensures thread safety
    void updateSpeed(double s) { if(m_speed!=s) { m_speed=s; emit vehicleSpeedChanged(); } }
    void updateRpm(double r) { if(m_rpm!=r) { m_rpm=r; emit engineRpmChanged(); } }
    void updateGear(QString g) { if(m_gear!=g) { m_gear=g; emit gearChanged(); } }

signals:
    void vehicleSpeedChanged();
    void engineRpmChanged();
    void fuelLevelChanged();
    void coolantTempChanged();
    void gearChanged();
    void leftIndicatorChanged();
    void rightIndicatorChanged();
    void handbrakeChanged();
    void seatbeltChanged();
    void batteryChanged();
    void engineWarnChanged();
    void fogChanged();
    void highBeamChanged();
    void navActiveChanged();
    void nextTurnChanged();

private slots:
    void onUdpMessage() {
        while (m_udpSocket->hasPendingDatagrams()) {
            QNetworkDatagram datagram = m_udpSocket->receiveDatagram();
            QJsonDocument doc = QJsonDocument::fromJson(datagram.data());
            if(doc.isObject()) {
                QJsonObject root = doc.object();
                if(root.contains("speed")) updateSpeed(root["speed"].toDouble());
                if(root.contains("rpm")) updateRpm(root["rpm"].toDouble());
                if(root.contains("gear")) updateGear(root["gear"].toString());
                if(root.contains("nav_active")) { m_navActive = root["nav_active"].toBool(); emit navActiveChanged(); }
                // Expand for all props
            }
        }
    }

private:
    double m_speed;
    double m_rpm;
    double m_fuel;
    double m_temp;
    QString m_gear;
    bool m_left, m_right;
    bool m_handbrake, m_seatbelt, m_battery, m_engine, m_fog, m_highBeam;
    bool m_navActive;
    QString m_turnInstruction;
    double m_turnDist;
    
    QUdpSocket* m_udpSocket;
};

// --- VSOMEIP Integration ---
std::shared_ptr<vsomeip::application> vsomeip_app;
ClusterAdapter* adapter_ptr = nullptr;

void on_speed_signal(const std::shared_ptr<vsomeip::message> &_msg) {
    if(!adapter_ptr) return;
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 2) {
        uint16_t val = (pl->get_data()[0] << 8) | pl->get_data()[1];
        QMetaObject::invokeMethod(adapter_ptr, [val](){ adapter_ptr->updateSpeed(val); });
    }
}
void on_rpm_signal(const std::shared_ptr<vsomeip::message> &_msg) {
    if(!adapter_ptr) return;
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 2) {
        uint16_t val = (pl->get_data()[0] << 8) | pl->get_data()[1];
        QMetaObject::invokeMethod(adapter_ptr, [val](){ adapter_ptr->updateRpm(val); });
    }
}
void on_gear_signal(const std::shared_ptr<vsomeip::message> &_msg) {
    if(!adapter_ptr) return;
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 1) {
        uint8_t val = pl->get_data()[0];
        QString g = "P";
        if (val == 0) g = "P";
        else if (val == 1) g = "R";
        else if (val == 2) g = "N";
        else g = "D"; // Simplification for demo
        QMetaObject::invokeMethod(adapter_ptr, [g](){ adapter_ptr->updateGear(g); });
    }
}

void vsomeip_thread_func() {
    using namespace vsomeip;
    vsomeip_app = runtime::get()->create_application("cluster_ui");
    vsomeip_app->init();
    
    // Subscribe to CAN Service
    vsomeip_app->request_service(0x1234, 0x0001);
    vsomeip_app->register_message_handler(0x1234, 0x0001, 0x8001, on_speed_signal);
    vsomeip_app->register_message_handler(0x1234, 0x0001, 0x8002, on_rpm_signal);
    vsomeip_app->register_message_handler(0x1234, 0x0001, 0x8003, on_gear_signal);

    std::set<eventgroup_t> groups; groups.insert(0x4465);
    vsomeip_app->request_event(0x1234, 0x0001, 0x8001, groups, event_type_e::ET_FIELD);
    vsomeip_app->request_event(0x1234, 0x0001, 0x8002, groups, event_type_e::ET_FIELD);
    vsomeip_app->request_event(0x1234, 0x0001, 0x8003, groups, event_type_e::ET_FIELD);
    
    vsomeip_app->start();
}

int main(int argc, char *argv[])
{
    // Hardware Acceleration preference
    // qputenv("QSG_RHI_BACKEND", "opengl"); // Or "vulkan" depending on Pi4 drivers
    
    QGuiApplication app(argc, argv);
    
    ClusterAdapter adapter;
    adapter_ptr = &adapter;

    QQmlApplicationEngine engine;
    
    // Check if we have the assets, if not, create dummies?
    // User asked to provide assets logic but I cannot create binary Image files here.
    // I will rely on QML Rectangle placeholders if assets missing, or generate SVG.

    // Register Types/Context
    engine.rootContext()->setContextProperty("clusterClient", &adapter);

    const QUrl url(u"qrc:/ClusterUI/ClusterMain.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    // Start VSOMEIP in non-blocking thread
    std::thread v_thread(vsomeip_thread_func);
    v_thread.detach();

    return app.exec();
}
#include "main.moc"

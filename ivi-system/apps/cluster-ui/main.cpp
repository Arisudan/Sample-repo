/*
    ASTER IVI System - Cluster Adapter
    Hardened C++ backend adapter for the Cluster UI.
    Connects VSOMEIP signals to Qt Properties for QML.
*/

#include <QIsGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QTimer>
#include <QDateTime>
#include <QUdpSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <vsomeip/vsomeip.hpp>
#include <thread>
#include <iostream>
#include <mutex>
#include <cmath>

class ClusterAdapter : public QObject {
    Q_OBJECT
    
    // --- Vehicle State ---
    Q_PROPERTY(double vehicleSpeed READ vehicleSpeed NOTIFY vehicleSpeedChanged)
    Q_PROPERTY(double engineRpm READ engineRpm NOTIFY engineRpmChanged)
    Q_PROPERTY(double fuelLevel READ fuelLevel NOTIFY fuelLevelChanged)
    Q_PROPERTY(double coolantTemp READ coolantTemp NOTIFY coolantTempChanged)
    
    // --- Signals & Warnings ---
    Q_PROPERTY(QString gear READ gear NOTIFY gearChanged)
    Q_PROPERTY(bool leftIndicator READ leftIndicator NOTIFY leftIndicatorChanged)
    Q_PROPERTY(bool rightIndicator READ rightIndicator NOTIFY rightIndicatorChanged)
    Q_PROPERTY(bool handbrake READ handbrake NOTIFY warningChanged)
    Q_PROPERTY(bool seatbelt READ seatbelt NOTIFY warningChanged)
    Q_PROPERTY(bool battery READ battery NOTIFY warningChanged)
    Q_PROPERTY(bool engineWarn READ engineWarn NOTIFY warningChanged)
    Q_PROPERTY(bool absWarn READ absWarn NOTIFY warningChanged)
    Q_PROPERTY(bool tpmsWarn READ tpmsWarn NOTIFY warningChanged)
    Q_PROPERTY(bool highBeam READ highBeam NOTIFY lightingChanged)
    Q_PROPERTY(bool fogLight READ fogLight NOTIFY lightingChanged)

    // --- Environment / Navigation ---
    Q_PROPERTY(bool navActive READ navActive NOTIFY navActiveChanged)
    Q_PROPERTY(QString nextTurn READ nextTurn NOTIFY navDataChanged)
    Q_PROPERTY(QString nextTurnDistance READ nextTurnDistance NOTIFY navDataChanged)
    Q_PROPERTY(QString destination READ destination NOTIFY navDataChanged)
    Q_PROPERTY(double outdoorTemp READ outdoorTemp NOTIFY environmentChanged)
    Q_PROPERTY(QString weatherState READ weatherState NOTIFY environmentChanged)

public:
    ClusterAdapter(QObject *parent = nullptr) 
        : QObject(parent), 
          m_speed(0), m_rpm(0), m_fuel(0.75), m_coolant(90.0),
          m_gear("P"), m_left(false), m_right(false),
          m_handbrake(false), m_seatbelt(false), m_battery(false),
          m_engine(false), m_abs(false), m_tpms(false),
          m_highbeam(false), m_fog(false),
          m_navActive(false), m_temp(22.0), m_weather("Sunny"),
          m_destination("CITY CENTER"), m_turnDist("15 KM")
    {
        // UDP Listener for Test Harness
        m_udpSocket = new QUdpSocket(this);
        if(m_udpSocket->bind(QHostAddress::LocalHost, 12345)) {
            connect(m_udpSocket, &QUdpSocket::readyRead, this, &ClusterAdapter::onUdpMessage);
            std::cout << "[ClusterAdapter] LISTENING on UDP 12345 (Test Harness)" << std::endl;
        }
    }

    // -- Q_INVOKABLE Methods (Interaction) --
    Q_INVOKABLE void setGear(const QString &g) {
        if(m_gear != g && (g=="P"||g=="R"||g=="N"||g=="D")) {
            m_gear = g; 
            emit gearChanged();
            std::cout << "-> SetGear: " << g.toStdString() << std::endl;
        }
    }

    Q_INVOKABLE void toggleIndicator(const QString &side) {
        if(side == "left") { m_left = !m_left; if(m_left) m_right = false; }
        else { m_right = !m_right; if(m_right) m_left = false; }
        emit leftIndicatorChanged(); emit rightIndicatorChanged();
    }
    
    Q_INVOKABLE void requestMapCenter() {
        std::cout << "-> Requesting Map Recenter" << std::endl;
        // Logic to send IPC event to Nav service would go here
    }

    // -- Getters --
    double vehicleSpeed() const { return m_speed; }
    double engineRpm() const { return m_rpm; }
    double fuelLevel() const { return m_fuel; }
    double coolantTemp() const { return m_coolant; }
    QString gear() const { return m_gear; }
    bool leftIndicator() const { return m_left; }
    bool rightIndicator() const { return m_right; }
    bool handbrake() const { return m_handbrake; }
    bool seatbelt() const { return m_seatbelt; }
    bool battery() const { return m_battery; }
    bool engineWarn() const { return m_engine; }
    bool absWarn() const { return m_abs; }
    bool tpmsWarn() const { return m_tpms; }
    bool highBeam() const { return m_highbeam; }
    bool fogLight() const { return m_fog; }
    bool navActive() const { return m_navActive; }
    QString nextTurn() const { return m_nextTurn; }
    QString nextTurnDistance() const { return m_turnDist; }
    QString destination() const { return m_destination; }
    double outdoorTemp() const { return m_temp; }
    QString weatherState() const { return m_weather; }

    // -- Thread-Safe Setters --
    void updateSpeed(double s) { if(m_speed!=s){ m_speed=s; emit vehicleSpeedChanged(); } }
    void updateRpm(double r) { if(m_rpm!=r){ m_rpm=r; emit engineRpmChanged(); } }
    void updateGear(QString g) { if(m_gear!=g){ m_gear=g; emit gearChanged(); } }

signals:
    void vehicleSpeedChanged();
    void engineRpmChanged();
    void fuelLevelChanged();
    void coolantTempChanged();
    void gearChanged();
    void leftIndicatorChanged();
    void rightIndicatorChanged();
    void warningChanged();
    void lightingChanged();
    void navActiveChanged();
    void navDataChanged();
    void environmentChanged();

private slots:
    void onUdpMessage() {
        while (m_udpSocket->hasPendingDatagrams()) {
            QNetworkDatagram d = m_udpSocket->receiveDatagram();
            QJsonDocument doc = QJsonDocument::fromJson(d.data());
            if(doc.isObject()) {
                QJsonObject o = doc.object();
                if(o.contains("speed")) updateSpeed(o["speed"].toDouble());
                if(o.contains("rpm")) updateRpm(o["rpm"].toDouble());
                if(o.contains("gear")) updateGear(o["gear"].toString());
                if(o.contains("nav_active")) { m_navActive = o["nav_active"].toBool(); emit navActiveChanged(); }
                if(o.contains("left")) { m_left = o["left"].toBool(); emit leftIndicatorChanged(); }
                if(o.contains("right")) { m_right = o["right"].toBool(); emit rightIndicatorChanged(); }
                if(o.contains("temp")) { m_temp = o["temp"].toDouble(); emit environmentChanged(); }
                if(o.contains("weather")) { m_weather = o["weather"].toString(); emit environmentChanged(); }
            }
        }
    }

private:
    double m_speed, m_rpm, m_fuel, m_coolant;
    QString m_gear;
    bool m_left, m_right;
    bool m_handbrake, m_seatbelt, m_battery, m_engine, m_abs, m_tpms;
    bool m_highbeam, m_fog;
    bool m_navActive;
    QString m_nextTurn, m_turnDist, m_destination;
    double m_temp; 
    QString m_weather;
    
    QUdpSocket* m_udpSocket;
};

// Global pointers for C-style callbacks
std::shared_ptr<vsomeip::application> vsomeip_app;
ClusterAdapter* g_adapter = nullptr;

void on_speed_signal(const std::shared_ptr<vsomeip::message> &_msg) {
    if(!g_adapter) return;
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 2) {
        uint16_t val = (pl->get_data()[0] << 8) | pl->get_data()[1];
        QMetaObject::invokeMethod(g_adapter, [val](){ g_adapter->updateSpeed(val); });
    }
}
// ... (RPM/Gear similar callbacks would be here in full implementation)

void vsomeip_thread_runner() {
    using namespace vsomeip;
    vsomeip_app = runtime::get()->create_application("cluster_ui");
    vsomeip_app->init();
    vsomeip_app->request_service(0x1234, 0x0001);
    vsomeip_app->register_message_handler(0x1234, 0x0001, 0x8001, on_speed_signal);
    // Request events...
    std::set<eventgroup_t> groups; groups.insert(0x4465);
    vsomeip_app->request_event(0x1234, 0x0001, 0x8001, groups, event_type_e::ET_FIELD);
    vsomeip_app->start();
}

int main(int argc, char *argv[]) {
    // Hardware Acceleration for Pi4
    // qputenv("QSG_RHI_BACKEND", "opengl");
    
    QGuiApplication app(argc, argv);
    ClusterAdapter adapter;
    g_adapter = &adapter;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("clusterClient", &adapter);
    
    const QUrl url(u"qrc:/ClusterUI/ClusterMain.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    std::thread v_thread(vsomeip_thread_runner);
    v_thread.detach();

    return app.exec();
}
#include "main.moc"

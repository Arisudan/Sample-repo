#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <QTimer>
#include <vsomeip/vsomeip.hpp>
#include <thread>
#include <iostream>
#include <cmath>

class CarData : public QObject {
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int gear READ gear NOTIFY gearChanged)
    Q_PROPERTY(double fuel READ fuel NOTIFY fuelChanged)
    Q_PROPERTY(double temp READ temp NOTIFY tempChanged)
    Q_PROPERTY(bool leftTurn READ leftTurn NOTIFY leftTurnChanged)
    Q_PROPERTY(bool rightTurn READ rightTurn NOTIFY rightTurnChanged)

public:
    CarData(QObject *parent = nullptr) 
        : QObject(parent), m_speed(0), m_rpm(0), m_gear(0), 
          m_fuel(80), m_temp(90), m_leftTurn(false), m_rightTurn(false) 
    {
        // Simulation Timer for smoothness
        m_simTimer = new QTimer(this);
        connect(m_simTimer, &QTimer::timeout, this, &CarData::simulateLiveBehavior);
        m_simTimer->start(16); // 60 FPS update tick
    }

    double speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    int gear() const { return m_gear; }
    double fuel() const { return m_fuel; }
    double temp() const { return m_temp; }
    bool leftTurn() const { return m_leftTurn; }
    bool rightTurn() const { return m_rightTurn; }

    void setSpeed(double s) { if (m_speed == s) return; m_speed = s; emit speedChanged(); }
    void setRpm(double r) { if (m_rpm == r) return; m_rpm = r; emit rpmChanged(); }
    void setGear(int g) { if (m_gear == g) return; m_gear = g; emit gearChanged(); }
    void setLeftTurn(bool b) { if (m_leftTurn == b) return; m_leftTurn = b; emit leftTurnChanged(); }
    void setRightTurn(bool b) { if (m_rightTurn == b) return; m_rightTurn = b; emit rightTurnChanged(); }

signals:
    void speedChanged();
    void rpmChanged();
    void gearChanged();
    void fuelChanged();
    void tempChanged();
    void leftTurnChanged();
    void rightTurnChanged();

private slots:
    void simulateLiveBehavior() {
        // Interpolate or sim jitter if needed
        // For now, we just rely on setSpeed/setRpm from IPC
        // But let's add some "life" to fuel/temp
        static double time = 0;
        time += 0.01;
        
        // Slow fluctuation for temp
        double newTemp = 90 + std::sin(time * 0.1) * 2;
        if(std::abs(newTemp - m_temp) > 0.1) {
            m_temp = newTemp;
            emit tempChanged();
        }

        // Mock Blinker Logic (if not driven by IPC for now)
        static int blinkTimer = 0;
        blinkTimer++;
        if (blinkTimer > 60) { // Approx 1 sec
             // Toggle logic could go here if we were fully mocking
             blinkTimer = 0;
        }
    }

private:
    double m_speed;
    double m_rpm;
    int m_gear;
    double m_fuel;
    double m_temp;
    bool m_leftTurn;
    bool m_rightTurn;
    QTimer* m_simTimer;
};

std::shared_ptr<vsomeip::application> app;
CarData *carDataPtr = nullptr;

void on_speed_event(const std::shared_ptr<vsomeip::message> &_msg) {
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 2) {
        uint16_t val = (pl->get_data()[0] << 8) | pl->get_data()[1];
        if(carDataPtr) QMetaObject::invokeMethod(carDataPtr, [val](){ carDataPtr->setSpeed(val); });
    }
}

void on_rpm_event(const std::shared_ptr<vsomeip::message> &_msg) {
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 2) {
        uint16_t val = (pl->get_data()[0] << 8) | pl->get_data()[1];
        if(carDataPtr) QMetaObject::invokeMethod(carDataPtr, [val](){ carDataPtr->setRpm(val); });
    }
}

void on_gear_event(const std::shared_ptr<vsomeip::message> &_msg) {
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    if(pl->get_length() >= 1) {
        uint8_t val = pl->get_data()[0];
        if(carDataPtr) QMetaObject::invokeMethod(carDataPtr, [val](){ carDataPtr->setGear(val); });
    }
}

// Mock handler for simulated signals
void vsomeip_thread() {
    app = vsomeip::runtime::get()->create_application("cluster_ui");
    app->init();
    app->request_service(0x1234, 0x0001); 
    
    app->register_message_handler(0x1234, 0x0001, 0x8001, on_speed_event);
    app->register_message_handler(0x1234, 0x0001, 0x8002, on_rpm_event);
    app->register_message_handler(0x1234, 0x0001, 0x8003, on_gear_event);

    std::set<vsomeip::eventgroup_t> groups;
    groups.insert(0x4465);
    app->request_event(0x1234, 0x0001, 0x8001, groups, vsomeip::event_type_e::ET_FIELD);
    app->request_event(0x1234, 0x0001, 0x8002, groups, vsomeip::event_type_e::ET_FIELD);
    app->request_event(0x1234, 0x0001, 0x8003, groups, vsomeip::event_type_e::ET_FIELD);
    
    app->start();
}

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QGuiApplication app(argc, argv);

    CarData carData;
    carDataPtr = &carData;

    QQmlApplicationEngine engine;
    
    engine.rootContext()->setContextProperty("carData", &carData);

    const QUrl url(u"qrc:/ClusterUI/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    std::thread v_thread(vsomeip_thread);
    v_thread.detach();

    return app.exec();
}
#include "main.moc"

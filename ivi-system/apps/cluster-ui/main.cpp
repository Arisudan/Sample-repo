#include <QIsGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QObject>
#include <vsomeip/vsomeip.hpp>
#include <thread>
#include <iostream>

class CarData : public QObject {
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(double rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(int gear READ gear NOTIFY gearChanged)

public:
    CarData(QObject *parent = nullptr) : QObject(parent), m_speed(0), m_rpm(0), m_gear(0) {}

    double speed() const { return m_speed; }
    double rpm() const { return m_rpm; }
    int gear() const { return m_gear; }

    void setSpeed(double s) {
        if (m_speed == s) return;
        m_speed = s;
        emit speedChanged();
    }
    void setRpm(double r) {
        if (m_rpm == r) return;
        m_rpm = r;
        emit rpmChanged();
    }
    void setGear(int g) {
        if (m_gear == g) return;
        m_gear = g;
        emit gearChanged();
    }

signals:
    void speedChanged();
    void rpmChanged();
    void gearChanged();

private:
    double m_speed;
    double m_rpm;
    int m_gear;
};

std::shared_ptr<vsomeip::application> app;
CarData *carDataPtr = nullptr;

void on_speed_event(const std::shared_ptr<vsomeip::message> &_msg) {
    std::shared_ptr<vsomeip::payload> pl = _msg->get_payload();
    // Decode 2 bytes
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

void vsomeip_thread() {
    app = vsomeip::runtime::get()->create_application("cluster_ui");
    app->init();
    app->request_service(0x1234, 0x0001); // CAN Service
    
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
